import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationMap extends StatefulWidget {
  final bool followUser;
  final double? height;

  /// Optional: notify parent whenever lat/lng updates
  final void Function(double lat, double lng)? onLatLng;

  const CurrentLocationMap({
    super.key,
    this.followUser = true,
    this.height,
    this.onLatLng,
  });

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> {
  final _controllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? _mapController;

  StreamSubscription<Position>? _posSub;
  Position? _lastPosition;

  // store latest coords here (as you asked)
  double? lat;
  double? lng;

  // Blue dot + accuracy circle like Google Maps
  final Map<CircleId, Circle> _circles = {};
  static const CircleId _dotCircleId = CircleId('user-dot');
  static const CircleId _accCircleId = CircleId('user-accuracy');

  // Fallback camera (Riyadh)
  static const _fallback = CameraPosition(
    target: LatLng(24.7136, 46.6753),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocationFlow() async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    Position? initial;
    try {
      if (kIsWeb) {
        initial = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } else {
        initial = await Geolocator.getLastKnownPosition();
        initial ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      }
    } catch (_) {}

    if (!mounted) return;

    if (initial != null) {
      _applyPosition(initial); // <— updates lat/lng, UI, camera
      _moveCameraTo(LatLng(initial.latitude, initial.longitude), zoom: 16.5);
    }

    if (widget.followUser) {
      _startPositionStream();
    }
  }

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied. Enable them in Settings.',
            ),
          ),
        );
      }
      return false;
    }

    return serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);
  }

  void _startPositionStream() {
    _posSub?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // meters
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        _applyPosition(pos); // <— updates lat/lng and UI
        _moveCameraTo(LatLng(pos.latitude, pos.longitude));
      },
      onError: (_) {},
    );
  }

  // Centralized place to keep state in sync (lat/lng + blue dot)
  void _applyPosition(Position p) {
    _lastPosition = p;

    // 1) store lat/lng
    setState(() {
      lat = p.latitude;
      lng = p.longitude;
    });

    // 2) notify parent if asked
    if (widget.onLatLng != null) {
      widget.onLatLng!(p.latitude, p.longitude);
    }

    // 3) update dot/accuracy
    _updateUserGraphics(p);
  }

  void _updateUserGraphics(Position p) {
    final userLatLng = LatLng(p.latitude, p.longitude);

    final Circle dot = Circle(
      circleId: _dotCircleId,
      center: userLatLng,
      radius: 6,
      fillColor: const Color(0xFF1A73E8),
      strokeColor: Colors.white,
      strokeWidth: 2,
      zIndex: 2,
    );

    final double acc =
        (p.accuracy.isFinite && p.accuracy > 0) ? p.accuracy : 30;
    final Circle accCircle = Circle(
      circleId: _accCircleId,
      center: userLatLng,
      radius: acc.clamp(20, 80),
      fillColor: const Color(0x331A73E8),
      strokeColor: const Color(0x551A73E8),
      strokeWidth: 1,
      zIndex: 1,
    );

    setState(() {
      _circles[_dotCircleId] = dot;
      _circles[_accCircleId] = accCircle;
    });
  }

  Future<void> _moveCameraTo(LatLng target, {double? zoom}) async {
    if (!_controllerCompleter.isCompleted) {
      try {
        _mapController = await _controllerCompleter.future;
      } catch (_) {
        return;
      }
    }
    final ctrl = _mapController;
    if (ctrl == null) return;

    final update = zoom != null
        ? CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: zoom))
        : CameraUpdate.newLatLng(target);

    try {
      await ctrl.animateCamera(update);
    } catch (_) {}
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
    final p = _lastPosition;
    if (p != null) {
      _moveCameraTo(LatLng(p.latitude, p.longitude), zoom: 16.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = GoogleMap(
      initialCameraPosition: _fallback,
      onMapCreated: _onMapCreated,
      myLocationEnabled: false, // we draw our own dot
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: true,
      circles: Set<Circle>.of(_circles.values),
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: map);
    }
    return map;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class CurrentLocationMap extends StatefulWidget {
  final bool followUser;
  final double? height;
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
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _posSub;

  double? lat;
  double? lng;
  double _currentZoom = 16.0;

  bool _isLoading = true;
  String? _errorMsg;

  // fallback: Riyadh
  static final LatLng _fallback = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _posSub = null;
    super.dispose();
  }

  Future<void> _initLocationFlow() async {
    final ok = await _ensurePermission();
    if (!ok) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Location not available';
        });
      }
      return;
    }

    Position? initial;
    try {
      initial = await Geolocator.getLastKnownPosition();
      initial ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Could not get location';
        });
      }
    }

    if (!mounted) return;

    if (initial != null) {
      _applyPosition(initial);
      _moveCamera(
        LatLng(initial.latitude, initial.longitude),
        zoom: _currentZoom,
      );
      setState(() {
        _isLoading = false;
        _errorMsg = null;
      });
    } else {
      // no initial fix yet → keep spinner, wait for stream
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });
    }

    if (widget.followUser) {
      _startPositionStream();
    }
  }

  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
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
      distanceFilter: 5,
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        if (!mounted) return;

        _applyPosition(pos);
        _moveCamera(LatLng(pos.latitude, pos.longitude));

        // once we have a real GPS point → hide loader & message
        setState(() {
          _isLoading = false;
          _errorMsg = null;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _errorMsg = 'Location stream error';
        });
      },
    );
  }

  void _applyPosition(Position p) {
    if (!mounted) return;

    setState(() {
      lat = p.latitude;
      lng = p.longitude;
    });

    widget.onLatLng?.call(p.latitude, p.longitude);
  }

  void _moveCamera(LatLng target, {double? zoom}) {
    if (!mounted) return;
    try {
      _mapController.move(target, zoom ?? _currentZoom);
    } catch (_) {
      // ignore if map not ready
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _fallback,
        initialZoom: _currentZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none, // disable user interaction
        ),
      ),
      children: [
        // OSM tiles (with place names)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.etqan.app',
        ),

        // marker
        if (lat != null && lng != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat!, lng!),
                width: 44,
                height: 44,
                child: const _NiceUserDot(),
              ),
            ],
          ),
      ],
    );

    final content = Stack(
      children: [
        Positioned.fill(child: map),

        // loading overlay
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.12),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),

        // error / info message
        if (!_isLoading && _errorMsg != null)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: content);
    }
    return content;
  }
}

class _NiceUserDot extends StatelessWidget {
  const _NiceUserDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // glow
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0x331A73E8),
              shape: BoxShape.circle,
            ),
          ),
          // white ring
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          // blue core
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFF1A73E8),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

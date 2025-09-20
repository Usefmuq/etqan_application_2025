import 'dart:async';
import 'package:flutter/material.dart';

enum ToastPlacement { topRight, topCenter, bottomCenter, bottomRight }

enum ToastVariant { success, error, warning, info }

class SmartNotifier {
  SmartNotifier._();

  static void success(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
    ToastPlacement placement = ToastPlacement.topRight,
  }) =>
      _ToastOverlayHost.of(context).show(
        title: title,
        message: message,
        variant: ToastVariant.success,
        duration: duration,
        dismissible: dismissible,
        placement: placement,
      );

  static void error(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
    ToastPlacement placement = ToastPlacement.topRight,
  }) {
    debugPrint("$title $message");
    _ToastOverlayHost.of(context).show(
      title: title,
      message: message,
      variant: ToastVariant.error,
      duration: duration,
      dismissible: dismissible,
      placement: placement,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
    ToastPlacement placement = ToastPlacement.topRight,
  }) =>
      _ToastOverlayHost.of(context).show(
        title: title,
        message: message,
        variant: ToastVariant.warning,
        duration: duration,
        dismissible: dismissible,
        placement: placement,
      );

  static void info(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
    ToastPlacement placement = ToastPlacement.topRight,
  }) =>
      _ToastOverlayHost.of(context).show(
        title: title,
        message: message,
        variant: ToastVariant.info,
        duration: duration,
        dismissible: dismissible,
        placement: placement,
      );
}

/* ------------------------ Overlay host & controller ------------------------ */

class _ToastOverlayHost {
  _ToastOverlayHost._(this._controller, this._entry);

  final _ToastController _controller;
  // ignore: unused_field
  final OverlayEntry _entry;

  static final Map<OverlayState, _ToastOverlayHost> _hosts = {};

  static _ToastController of(BuildContext context) {
    // Make sure we grab a real overlay (root if needed)
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    assert(
        overlay != null, 'No Overlay found in context. Put MaterialApp above.');
    final os = overlay!;

    final existing = _hosts[os];
    if (existing != null) return existing._controller;

    // Create controller now (synchronously), insert overlay that listens to it
    final controller = _ToastController();
    final entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        ignoring: true,
        child: _ToastOverlayWidget(controller: controller),
      ),
    );
    os.insert(entry);
    final host = _ToastOverlayHost._(controller, entry);
    _hosts[os] = host;

    // Cleanup when overlay disappears (rare)
    controller._onEmpty = () {
      // keep entry for future toasts; comment the next 2 lines if you prefer persistent host
      // host._entry.remove();
      // _hosts.remove(os);
    };

    return controller;
  }
}

class _ToastController extends ChangeNotifier {
  final List<_ToastData> _toasts = [];
  VoidCallback? _onEmpty;

  void show({
    required String title,
    String? message,
    required ToastVariant variant,
    required Duration duration,
    required bool dismissible,
    required ToastPlacement placement,
  }) {
    final id = UniqueKey();
    final data = _ToastData(
      id: id,
      title: title,
      message: message,
      variant: variant,
      dismissible: dismissible,
      placement: placement,
    );
    _toasts.add(data);
    notifyListeners();

    data.timer = Timer(duration, () => dismiss(id));
  }

  void dismiss(Key id) {
    final idx = _toasts.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _toasts[idx].timer?.cancel();
    _toasts.removeAt(idx);
    notifyListeners();
    if (_toasts.isEmpty) _onEmpty?.call();
  }
}

/* ------------------------------ Overlay widget ----------------------------- */

class _ToastOverlayWidget extends StatefulWidget {
  const _ToastOverlayWidget({required this.controller});
  final _ToastController controller;

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _ToastOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Alignment _alignmentFor(ToastPlacement p) {
    switch (p) {
      case ToastPlacement.topRight:
        return Alignment.topRight;
      case ToastPlacement.topCenter:
        return Alignment.topCenter;
      case ToastPlacement.bottomCenter:
        return Alignment.bottomCenter;
      case ToastPlacement.bottomRight:
        return Alignment.bottomRight;
    }
  }

  EdgeInsets _paddingFor(ToastPlacement p) {
    const base = EdgeInsets.all(12);
    switch (p) {
      case ToastPlacement.topRight:
        return base.copyWith(top: 12, right: 12);
      case ToastPlacement.topCenter:
        return base.copyWith(top: 12);
      case ToastPlacement.bottomCenter:
        return base.copyWith(bottom: 12);
      case ToastPlacement.bottomRight:
        return base.copyWith(bottom: 12, right: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final toasts = widget.controller._toasts;
    if (toasts.isEmpty) return const SizedBox.shrink();

    final byPlacement = <ToastPlacement, List<_ToastData>>{};
    for (final t in toasts) {
      byPlacement.putIfAbsent(t.placement, () => []).add(t);
    }

    return SafeArea(
      child: Stack(
        children: byPlacement.entries.map((entry) {
          final placement = entry.key;
          final list = entry.value;
          return Align(
            alignment: _alignmentFor(placement),
            child: Padding(
              padding: _paddingFor(placement),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: (placement == ToastPlacement.topRight ||
                        placement == ToastPlacement.bottomRight)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    _ToastCard(
                      key: list[i].id,
                      data: list[i],
                      onClose: () => widget.controller.dismiss(list[i].id),
                    ),
                    if (i < list.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* --------------------------------- Toast UI -------------------------------- */

class _ToastData {
  _ToastData({
    required this.id,
    required this.title,
    required this.variant,
    required this.dismissible,
    required this.placement,
    this.message,
  });

  final Key id;
  final String title;
  final String? message;
  final ToastVariant variant;
  final bool dismissible;
  final ToastPlacement placement;
  Timer? timer;
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    super.key,
    required this.data,
    required this.onClose,
  });

  final _ToastData data;
  final VoidCallback onClose;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 180))
    ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _palette(widget.data.variant);

    return FadeTransition(
      opacity: _fade,
      child: Dismissible(
        key: widget.key!,
        direction: widget.data.dismissible
            ? DismissDirection.endToStart
            : DismissDirection.none,
        onDismissed: (_) => widget.onClose(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: IntrinsicWidth(
            child: Material(
              color: Colors.transparent,
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(colors.icon, color: colors.accent),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.accent,
                              fontSize: 14,
                            ),
                          ),
                          if (widget.data.message != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.data.message!,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.data.dismissible) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: widget.onClose,
                        child:
                            Icon(Icons.close, size: 18, color: colors.accent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ToastPalette _palette(ToastVariant v) {
    switch (v) {
      case ToastVariant.success:
        return const _ToastPalette(
          accent: Color(0xFF1F7A4D),
          background: Color(0xFFE6F4EA),
          border: Color(0xFFB9E2C6),
          icon: Icons.check_circle_rounded,
        );
      case ToastVariant.error:
        return const _ToastPalette(
          accent: Color(0xFF9B1C1C),
          background: Color(0xFFFDE8E8),
          border: Color(0xFFF5C2C2),
          icon: Icons.error_rounded,
        );
      case ToastVariant.warning:
        return const _ToastPalette(
          accent: Color(0xFF8B5E00),
          background: Color(0xFFFFF6E5),
          border: Color(0xFFFFE4B5),
          icon: Icons.warning_amber_rounded,
        );
      case ToastVariant.info:
        return const _ToastPalette(
          accent: Color(0xFF1F4E79),
          background: Color(0xFFE7F0FB),
          border: Color(0xFFBFD6F6),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _ToastPalette {
  const _ToastPalette({
    required this.accent,
    required this.background,
    required this.border,
    required this.icon,
  });

  final Color accent;
  final Color background;
  final Color border;
  final IconData icon;
}

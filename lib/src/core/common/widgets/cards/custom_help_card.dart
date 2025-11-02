import 'package:flutter/material.dart';

enum HelpCardType {
  info,
  warning,
  success,
  error,
}

class CustomHelpCard extends StatelessWidget {
  final HelpCardType type;
  final String title;
  final String? description;
  final IconData? icon;
  final List<Widget>? actions;

  const CustomHelpCard({
    super.key,
    required this.type,
    required this.title,
    this.description,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final _colors = _mapTypeToColors(type, context);

    return Container(
      decoration: BoxDecoration(
        color: _colors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _colors.border, width: 1.1),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _colors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? _colors.defaultIcon,
              color: _colors.icon,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _colors.text.withOpacity(0.9),
                        ),
                  ),
                ],
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _HelpCardColors _mapTypeToColors(HelpCardType type, BuildContext context) {
    switch (type) {
      case HelpCardType.info:
        return _HelpCardColors(
          bg: const Color(0xFFE5F2FF),
          border: const Color(0xFFB7DBFF),
          iconBg: const Color(0xFFD2E8FF),
          icon: const Color(0xFF0B6BCE),
          text: const Color(0xFF0F172A),
          defaultIcon: Icons.info_outline,
        );
      case HelpCardType.warning:
        return _HelpCardColors(
          bg: const Color(0xFFFFF4D8),
          border: const Color(0xFFFFE3A5),
          iconBg: const Color(0xFFFFEAC0),
          icon: const Color(0xFF9A6700),
          text: const Color(0xFF0F172A),
          defaultIcon: Icons.warning_amber_rounded,
        );
      case HelpCardType.success:
        return _HelpCardColors(
          bg: const Color(0xFFE6F6EA),
          border: const Color(0xFFBCE3C5),
          iconBg: const Color(0xFFD6F0DC),
          icon: const Color(0xFF18794E),
          text: const Color(0xFF0F172A),
          defaultIcon: Icons.check_circle_outline,
        );
      case HelpCardType.error:
        return _HelpCardColors(
          bg: const Color(0xFFFEE2E2),
          border: const Color(0xFFFECACA),
          iconBg: const Color(0xFFFECACA),
          icon: const Color(0xFFB91C1C),
          text: const Color(0xFF0F172A),
          defaultIcon: Icons.error_outline,
        );
    }
  }
}

class _HelpCardColors {
  final Color bg;
  final Color border;
  final Color iconBg;
  final Color icon;
  final Color text;
  final IconData defaultIcon;

  _HelpCardColors({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.icon,
    required this.text,
    required this.defaultIcon,
  });
}

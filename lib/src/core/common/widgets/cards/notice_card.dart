import 'package:flutter/material.dart';

enum NoticeType { success, error, warning, info }

class NoticeCard extends StatelessWidget {
  final NoticeType type;
  final String? title;
  final String? message;

  /// Primary action (optional)
  final String? buttonText;
  final VoidCallback? onPressed;

  /// Optional secondary action
  final String? secondaryText;
  final VoidCallback? onSecondaryPressed;

  /// If true, reduces paddings/heights slightly
  final bool dense;

  /// Optional trailing widget (e.g., a close icon)
  final Widget? trailing;

  const NoticeCard({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.buttonText,
    this.onPressed,
    this.secondaryText,
    this.onSecondaryPressed,
    this.dense = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(type, Theme.of(context).brightness);
    final basePadding =
        dense ? const EdgeInsets.all(12) : const EdgeInsets.all(16);
    final gap = SizedBox(height: dense ? 8 : 12);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: palette.border),
      ),
      color: palette.bg,
      child: Stack(
        children: [
          // left accent stripe
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: basePadding.add(const EdgeInsets.only(left: 10)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null ||
                        message != null ||
                        palette.icon != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(palette.icon,
                              color: palette.accent, size: dense ? 20 : 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (title != null)
                                  Text(
                                    title!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: palette.fgStrong,
                                        ),
                                  ),
                                if (title != null && message != null) gap,
                                if (message != null)
                                  Text(
                                    message!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: palette.fg,
                                          height: 1.35,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: 8),
                            trailing!,
                          ],
                        ],
                      ),
                    if ((buttonText != null && onPressed != null) ||
                        (secondaryText != null &&
                            onSecondaryPressed != null)) ...[
                      gap,
                      isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (buttonText != null && onPressed != null)
                                  _PrimaryButton(
                                    text: buttonText!,
                                    onPressed: onPressed!,
                                    color: palette.accent,
                                  ),
                                if (secondaryText != null &&
                                    onSecondaryPressed != null) ...[
                                  const SizedBox(height: 8),
                                  _SecondaryButton(
                                    text: secondaryText!,
                                    onPressed: onSecondaryPressed!,
                                  ),
                                ],
                              ],
                            )
                          : Row(
                              children: [
                                if (buttonText != null && onPressed != null)
                                  _PrimaryButton(
                                    text: buttonText!,
                                    onPressed: onPressed!,
                                    color: palette.accent,
                                  ),
                                if (secondaryText != null &&
                                    onSecondaryPressed != null) ...[
                                  const SizedBox(width: 12),
                                  _SecondaryButton(
                                    text: secondaryText!,
                                    onPressed: onSecondaryPressed!,
                                  ),
                                ],
                                const Spacer(),
                              ],
                            ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _Palette _paletteFor(NoticeType type, Brightness brightness) {
    switch (type) {
      case NoticeType.success:
        return _Palette(
          bg: brightness == Brightness.dark
              ? const Color(0xFF0E2A19)
              : const Color(0xFFE8F5E9),
          border: brightness == Brightness.dark
              ? const Color(0xFF1B5E20)
              : const Color(0xFFBDE4C6),
          accent: const Color(0xFF2E7D32),
          fg: brightness == Brightness.dark
              ? const Color(0xFFCDE7D2)
              : const Color(0xFF1B5E20),
          fgStrong: brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1B5E20),
          icon: Icons.check_circle_rounded,
        );
      case NoticeType.error:
        return _Palette(
          bg: brightness == Brightness.dark
              ? const Color(0xFF2C1517)
              : const Color(0xFFFDECEE),
          border: brightness == Brightness.dark
              ? const Color(0xFF8A1C1C)
              : const Color(0xFFF5B9C0),
          accent: const Color(0xFFD32F2F),
          fg: brightness == Brightness.dark
              ? const Color(0xFFF5D0D3)
              : const Color(0xFF8A1C1C),
          fgStrong: brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF8A1C1C),
          icon: Icons.error_rounded,
        );
      case NoticeType.warning:
        return _Palette(
          bg: brightness == Brightness.dark
              ? const Color(0xFF2C230A)
              : const Color(0xFFFFF8E1),
          border: brightness == Brightness.dark
              ? const Color(0xFF8D6E15)
              : const Color(0xFFEED89A),
          accent: const Color(0xFFF9A825),
          fg: brightness == Brightness.dark
              ? const Color(0xFFFFE7A3)
              : const Color(0xFF6D5710),
          fgStrong: brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF6D5710),
          icon: Icons.warning_amber_rounded,
        );
      case NoticeType.info:
        return _Palette(
          bg: brightness == Brightness.dark
              ? const Color(0xFF0E2430)
              : const Color(0xFFE7F4FF),
          border: brightness == Brightness.dark
              ? const Color(0xFF0D47A1)
              : const Color(0xFFB9DCF7),
          accent: const Color(0xFF1976D2),
          fg: brightness == Brightness.dark
              ? const Color(0xFFCCE6FF)
              : const Color(0xFF0D47A1),
          fgStrong: brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF0D47A1),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _Palette {
  final Color bg;
  final Color border;
  final Color accent;
  final Color fg;
  final Color fgStrong;
  final IconData icon;

  const _Palette({
    required this.bg,
    required this.border,
    required this.accent,
    required this.fg,
    required this.fgStrong,
    required this.icon,
  });
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text(text),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }
}

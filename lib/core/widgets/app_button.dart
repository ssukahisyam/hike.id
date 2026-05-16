import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/color_tokens.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Variant tombol mengikuti DESIGN.md §6.1.
enum AppButtonVariant {
  primary,
  accent,
  secondary,
  ghost,
  danger,
}

enum AppButtonSize {
  /// Default — 48px tinggi, full touch target.
  regular,

  /// Compact — 40px, hanya untuk inline action di list.
  compact,

  /// Hero — 56px, untuk action utama hero (mis. Mulai Hike di home).
  hero,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool isLoading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;

    final Color bg;
    final Color fg;
    final BorderSide? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = s.actionPrimary;
        fg = s.actionPrimaryFg;
        border = null;
      case AppButtonVariant.accent:
        bg = s.actionAccent;
        fg = s.actionAccentFg;
        border = null;
      case AppButtonVariant.secondary:
        bg = s.surface;
        fg = s.textPrimary;
        border = BorderSide(color: s.borderDefault);
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = s.actionPrimary;
        border = null;
      case AppButtonVariant.danger:
        bg = s.surface;
        fg = HColors.danger;
        border = const BorderSide(color: HColors.danger);
    }

    final double height;
    switch (size) {
      case AppButtonSize.regular:
        height = 48;
      case AppButtonSize.compact:
        height = 40;
      case AppButtonSize.hero:
        height = 56;
    }

    final bool disabled = onPressed == null || isLoading;

    final Widget content = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: HSpacing.s2),
              ],
              Text(
                label,
                style: HTypography.labelLg.copyWith(color: fg),
              ),
            ],
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: !disabled,
      child: Opacity(
        opacity: disabled && !isLoading ? 0.4 : 1.0,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(HRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(HRadius.md),
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed?.call();
                  },
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: HSpacing.s5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(HRadius.md),
                border: border != null ? Border.fromBorderSide(border) : null,
              ),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

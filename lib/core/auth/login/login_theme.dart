import 'package:flutter/material.dart';
import 'package:thingsboard_app/config/themes/tb_text_styles.dart';

/// Mirrors the web login page: the page is painted with the primary palette,
/// the sign-in button with the accent palette, and text and icons are light
/// unless login white-labeling turns on "Dark foreground".
ThemeData loginTheme(ThemeData base, {required bool darkForeground}) {
  final foreground = darkForeground ? Colors.black : Colors.white;
  final primary = foreground.withValues(alpha: 0.87);
  final secondary = foreground.withValues(alpha: 0.7);
  final border = foreground.withValues(alpha: 0.38);
  final accent = base.colorScheme.secondary;
  final onAccent =
      ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
          ? Colors.white
          : Colors.black87;

  return base.copyWith(
    scaffoldBackgroundColor: base.primaryColor,
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      onSurface: primary,
    ),
    textTheme: base.textTheme.apply(bodyColor: primary, displayColor: primary),
    iconTheme: base.iconTheme.copyWith(color: secondary),
    dividerTheme: base.dividerTheme.copyWith(color: border),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: foreground.withValues(alpha: 0.3),
      selectionHandleColor: primary,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      labelStyle: TbTextStyles.bodyLarge.copyWith(color: secondary),
      floatingLabelStyle: TbTextStyles.labelSmall.copyWith(color: secondary),
      hintStyle: TbTextStyles.bodyLarge.copyWith(color: secondary),
      prefixIconColor: secondary,
      suffixIconColor: secondary,
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: base.elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStatePropertyAll(accent),
        foregroundColor: WidgetStatePropertyAll(onAccent),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: base.textButtonTheme.style?.copyWith(
        foregroundColor: WidgetStatePropertyAll(primary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: base.outlinedButtonTheme.style?.copyWith(
        foregroundColor: WidgetStatePropertyAll(primary),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
      ),
    ),
  );
}

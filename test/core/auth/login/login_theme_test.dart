import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thingsboard_app/config/themes/tb_theme.dart';
import 'package:thingsboard_app/core/auth/login/login_theme.dart';

// Built inside each widget test: the base theme resolves its Google Fonts,
// and only the widget test zone turns that fetch into a logged failure.
ThemeData baseTheme() => tbTheme(Colors.indigo, Colors.indigo, Colors.amber);

void main() {
  group('loginPageTheme', () {
    testWidgets('paints the page with the primary palette and the sign-in '
        'button with the accent', (_) async {
      final theme = loginPageTheme(baseTheme(), darkForeground: false);

      expect(theme.scaffoldBackgroundColor, Colors.indigo);
      expect(
        theme.elevatedButtonTheme.style!.backgroundColor!.resolve({}),
        Colors.amber,
      );
    });

    testWidgets('uses a light foreground unless dark foreground is requested', (
      _,
    ) async {
      final light = loginPageTheme(baseTheme(), darkForeground: false);
      final dark = loginPageTheme(baseTheme(), darkForeground: true);

      expect(
        light.textTheme.bodyLarge!.color,
        Colors.white.withValues(alpha: 0.87),
      );
      expect(
        dark.textTheme.bodyLarge!.color,
        Colors.black.withValues(alpha: 0.87),
      );
    });

    testWidgets('keeps the disabled look of the sign-in button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: loginPageTheme(baseTheme(), darkForeground: false),
          home: Scaffold(
            body: Column(
              children: [
                const ElevatedButton(onPressed: null, child: Text('disabled')),
                ElevatedButton(onPressed: () {}, child: const Text('enabled')),
              ],
            ),
          ),
        ),
      );

      Color? buttonColor(String label) =>
          tester
              .widget<Material>(
                find
                    .ancestor(
                      of: find.text(label),
                      matching: find.byType(Material),
                    )
                    .first,
              )
              .color;

      expect(buttonColor('enabled'), Colors.amber);
      expect(buttonColor('disabled'), isNot(Colors.amber));
    });
  });
}

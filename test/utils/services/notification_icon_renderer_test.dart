import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thingsboard_app/utils/services/notification_icon_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

  group('NotificationIconRenderer', () {
    test('renders an icon glyph to PNG bytes', () async {
      final bytes = await NotificationIconRenderer.renderPng(
        Icons.warning,
        const Color(0xFFF44336),
      );

      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(pngSignature.length));
      expect(bytes.sublist(0, pngSignature.length), equals(pngSignature));
    });
  });
}

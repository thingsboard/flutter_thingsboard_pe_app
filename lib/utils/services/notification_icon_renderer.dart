import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract final class NotificationIconRenderer {
  static Future<Uint8List?> renderPng(
    IconData icon,
    Color color, {
    double size = 256,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter =
        TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: size,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: color,
            ),
          )
          ..layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

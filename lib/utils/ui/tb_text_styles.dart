import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class TbTextStyles {
  static final titleXs = GoogleFonts.roboto(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.33,
    letterSpacing: .15,
  );

  static final labelLarge = GoogleFonts.roboto(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: .25,
    color: Colors.black.withOpacity(.87),
    height: 1.5,
  );

  static final labelMedium = GoogleFonts.roboto(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: .25,
    color: Colors.black.withOpacity(.87),
    height: 1.4,
  );

  static final bodyLarge = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: .15,
    height: 1.5,
  );

  static final bodyMedium = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: .2,
    color: Colors.black.withOpacity(.54),
    height: 1.4,
  );

  static final bodyRegular = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.5,
    letterSpacing: -0.41,
  );
}

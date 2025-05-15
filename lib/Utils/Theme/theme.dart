import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.poppins().fontFamily,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.black,
    secondary: Color(0xFF556B2F),
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.poppins().fontFamily,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF141414),
    primary: Colors.grey.shade100,
    secondary: Color(0xFF556B2F),
  ),
);

import "package:flutter/material.dart";

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A83AF), primary: const Color(0xFF2A83AF)),
    scaffoldBackgroundColor: const Color(0xFFF6F6F7),
  );
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4DA8DA), brightness: Brightness.dark, primary: const Color(0xFF4DA8DA)),
    scaffoldBackgroundColor: const Color(0xFF111827),
  );
}

// Matrices 5x4 para ColorFilter.matrix (modo oscuro real = inversión RGB).
const kIdentity = <double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
const kSepia = <double>[0.393, 0.769, 0.189, 0, 0, 0.349, 0.686, 0.168, 0, 0, 0.272, 0.534, 0.131, 0, 0, 0, 0, 0, 1, 0];
const kInvert = <double>[-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0];

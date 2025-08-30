import 'package:flutter/material.dart';

/// Premier League temasında uygulama renkleri
class AppColors {
  AppColors._();

  // Premier League ana renkleri
  static const Color primary = Color(0xFF3D195B); // Premier League mor
  static const Color secondary = Color(0xFF00FF87); // Premier League yeşil
  static const Color accent = Color(0xFFFF2882); // Premier League pembe
  
  // Arka plan renkleri
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF16213E);
  
  // Metin renkleri
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color textHint = Color(0xFF6C6C80);
  
  // Durum renkleri
  static const Color success = Color(0xFF00D09C);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);
  static const Color info = Color(0xFF4DABF7);
  
  // Maç sonucu renkleri
  static const Color homeWin = Color(0xFF51CF66);
  static const Color draw = Color(0xFFFFD43B);
  static const Color awayWin = Color(0xFFFF6B6B);
  
  // Gradient renkleri
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3D195B),
      Color(0xFF2A0E3F),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );
  
  // Gölge renkleri
  static const Color shadowColor = Color(0x1A000000);
  static const Color highlightColor = Color(0x0AFFFFFF);
}
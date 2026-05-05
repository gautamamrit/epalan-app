import 'package:flutter/material.dart';

/// ePalan App Color Palette
/// Field Green — earthy, agricultural, rooted in the land
class AppColors {
  AppColors._();

  // Primary Colors (Field Green)
  static const Color primary = Color(0xFF254A2A);       // deep field green — buttons, headers
  static const Color primaryDark = Color(0xFF1A2218);    // near-black green — ink
  static const Color primaryLight = Color(0xFFEAF2DE);   // light green tint
  static const Color primaryAlt = Color(0xFF356D3D);     // lighter green — hover, accents
  static const Color accent = Color(0xFFC35831);         // terracotta — CTAs, highlights
  static const Color accentSoft = Color(0xFFF8E3D4);     // soft terracotta

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);    // page bg — pure neutral gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF254A2A);       // dark cards

  // Status Colors
  static const Color success = Color(0xFF2E7D3C);
  static const Color warning = Color(0xFFB4761A);
  static const Color error = Color(0xFFC44233);
  static const Color info = Color(0xFF2A6E8E);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A2218);    // near-black green — primary text
  static const Color textSecondary = Color(0xFF3A4A36);  // secondary ink
  static const Color textTertiary = Color(0xFF7A8A76);   // muted green
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE5E7E3);          // neutral border
  static const Color divider = Color(0xFFF0F1EE);

  // Specific UI Elements
  static const Color activeCard = Color(0xFF254A2A);
  static const Color inactiveTab = Color(0xFF7A8A76);
  static const Color shadow = Color(0x1A0F1138);

  // Animal Status Colors
  static const Color animalActive = Color(0xFF2E7D3C);
  static const Color animalInactive = Color(0xFF7A8A76);
  static const Color animalOverdue = Color(0xFFC44233);

  // Category Badge Colors
  static const Color broilerBadge = Color(0xFF254A2A);
  static const Color layerBadge = Color(0xFFB4761A);
}

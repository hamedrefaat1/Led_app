import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Backgrounds ───────────────────────────────────────────
  static const Color background        = Color(0xFF0A0A0F);
  static const Color surfaceCard       = Color(0xFF13131A);
  static const Color surfaceElevated   = Color(0xFF1C1C27);

  // ─── Primary Glow (Electric Blue) ──────────────────────────
  static const Color primary           = Color(0xFF4FC3F7); 
  static const Color primaryGlow       = Color(0x554FC3F7); 
  static const Color primaryDark       = Color(0xFF0288D1); 

  // ─── Accent (Neon Purple) ──────────────────────────────────
  static const Color accent            = Color(0xFFBB86FC); 
  static const Color accentGlow        = Color(0x55BB86FC); 

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary       = Color(0xFFEEEEEE); 
  static const Color textSecondary     = Color(0xFF9E9E9E); 
  static const Color textHint          = Color(0xFF616161); 

  // ─── Icons & Borders ───────────────────────────────────────
  static const Color icon              = Color(0xFFBDBDBD);
  static const Color border            = Color(0xFF2A2A3A); 
  static const Color divider           = Color(0xFF1E1E2E);

  // ─── Story Ring Gradient ───────────────────────────────────
  static const List<Color> storyGradient = [
    Color(0xFF4FC3F7),
    Color(0xFFBB86FC),
    Color(0xFF00E5FF),
  ];

  // ─── Like / Actions ────────────────────────────────────────
  static const Color like              = Color(0xFFFF4F6A); 
  static const Color likeGlow          = Color(0x55FF4F6A);

  // ─── Success / Error ───────────────────────────────────────
  static const Color success           = Color(0xFF00E676);
  static const Color error             = Color(0xFFCF6679);
}
import 'package:flutter/material.dart';

/// Kurdistan Tourism brand palette.
///
/// Grounded in the subject, not a generic travel-app default: `ink` reads
/// as the pine forests of the Zagros at dusk, `clay` as Erbil Citadel brick
/// and Halabja pottery, `saffron` as the sun disc on the Kurdistan flag
/// (used sparingly, as the one accent that gets to be loud), and
/// `limestone` as the stone of mountain villages rather than a generic
/// cream. `clay` and `saffron` are deliberately different hues so the
/// palette doesn't collapse into a single terracotta note.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF1E2A22); // primary dark — headers, nav, hero overlays
  static const inkDeep = Color(0xFF141D18); // darkest shade, for the hero gradient floor
  static const limestone = Color(0xFFECE6D4); // primary light background
  static const limestoneWhite = Color(0xFFFAF7EE); // cards / elevated surfaces
  static const clay = Color(0xFFB15A34); // secondary accent — used sparingly (badges, icons)
  static const saffron = Color(0xFFDE9F3D); // primary accent — CTAs, ratings, active states
  static const saffronDeep = Color(0xFF7A4E0C); // text-on-saffron-tint
  static const riverstone = Color(0xFF6F7D74); // secondary/muted text
  static const charcoal = Color(0xFF26231D); // primary body text
  static const divider = Color(0xFFD8CFB4);
  static const danger = Color(0xFFA33B2E);
}

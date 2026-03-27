import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF69974E);
  static const primaryDark = Color(0xFF4A7C3A);
  static const primaryLight = Color(0xFF7DAD5A);
  static const primarySubtle = Color(0xFFEDF5E6);
  static const primaryDeep = Color(0xFF3D6B2E);
  static const primaryGlow = Color(0xFF8BC34A);
  static const primarySurface = Color(0xFFF5F9F2);

  // Backgrounds
  static const background = Color(0xFFF7F7F6);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF8FAFC);
  static const surfaceElevated = Color(0xFFFDFDFC);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF334155);
  static const textMuted = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);

  // Status
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);
  static const successText = Color(0xFF15803D);

  static const warning = Color(0xFFCA8A04);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningText = Color(0xFFA16207);

  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorText = Color(0xFFB91C1C);

  static const info = Color(0xFF2563EB);
  static const infoLight = Color(0xFFDBEAFE);
  static const infoText = Color(0xFF1D4ED8);

  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFF7ED);
  static const orangeText = Color(0xFFC2410C);

  // Borders
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  static const divider = Color(0xFFE2E8F0);

  // Amber
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFFFBEB);
  static const amberBorder = Color(0xFFFBBF24);

  // Shadows (tinted)
  static const shadowPrimary = Color(0x1A69974E);
  static const shadowDark = Color(0x0D1A2B0F);
}

/// 8pt spacing grid
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets screen = EdgeInsets.all(16);
  static const EdgeInsets card = EdgeInsets.all(12);
  static const EdgeInsets cardLg = EdgeInsets.all(16);
}

/// Border radius presets
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;
  static const double pill = 100;
}

/// Category metadata for icons and colors
class CategoryMeta {
  final IconData icon;
  final Color color;
  const CategoryMeta(this.icon, this.color);

  static const Map<String, CategoryMeta> data = {
    'All': CategoryMeta(Icons.grid_view_rounded, AppColors.primary),
    'Vegetables': CategoryMeta(Icons.grass_rounded, Color(0xFF16A34A)),
    'Fruits': CategoryMeta(Icons.apple, Color(0xFFEA580C)),
    'Dairy': CategoryMeta(Icons.water_drop_rounded, Color(0xFF2563EB)),
    'Grains': CategoryMeta(Icons.grain_rounded, Color(0xFFCA8A04)),
    'Proteins': CategoryMeta(Icons.egg_rounded, Color(0xFFDC2626)),
    'Beverages': CategoryMeta(Icons.local_cafe_rounded, Color(0xFF7C3AED)),
    'Organic': CategoryMeta(Icons.eco_rounded, Color(0xFF059669)),
    'Others': CategoryMeta(Icons.category_rounded, Color(0xFF64748B)),
  };

  static CategoryMeta get(String category) =>
      data[category] ?? const CategoryMeta(Icons.category_rounded, AppColors.textHint);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseText = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: baseText.copyWith(
        headlineLarge: baseText.headlineLarge?.copyWith(
          letterSpacing: -0.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          letterSpacing: -0.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          letterSpacing: -0.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          letterSpacing: 0,
          color: AppColors.textSecondary,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          letterSpacing: 0,
          color: AppColors.textSecondary,
        ),
        labelSmall: baseText.labelSmall?.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: GoogleFonts.inter(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }
}

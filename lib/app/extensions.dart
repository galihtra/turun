import 'package:flutter/material.dart';

/// Extension methods for Color class
/// Provides utilities for color conversion and manipulation
extension ColorExtensions on Color {
  /// Converts Color to HEX string
  /// Example: Color(0xFF0000FF) -> "#0000FF"
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${toARGB32().toRadixString(16).toUpperCase()}';
    }
    return '#${toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Converts Color to HEX string without hash
  /// Example: Color(0xFF0000FF) -> "0000FF"
  String toHexWithoutHash({bool includeAlpha = false}) {
    if (includeAlpha) {
      return toARGB32().toRadixString(16).toUpperCase();
    }
    return toARGB32().toRadixString(16).substring(2).toUpperCase();
  }

  /// Gets text color (black or white) that contrasts well with this color
  /// Useful for text on colored backgrounds
  Color getContrastingTextColor() {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Creates a darker version of this color
  /// [amount] should be between 0.0 and 1.0
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Creates a lighter version of this color
  /// [amount] should be between 0.0 and 1.0
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Converts color to RGB string
  /// Example: Color(0xFF0000FF) -> "rgb(0, 0, 255)"
  String toRgbString() {
    final red = (r * 255).toInt();
    final green = (g * 255).toInt();
    final blue = (b * 255).toInt();
    return 'rgb($red, $green, $blue)';
  }

  /// Converts color to RGBA string
  /// Example: Color(0x800000FF) -> "rgba(0, 0, 255, 0.5)"
  String toRgbaString() {
    final red = (r * 255).toInt();
    final green = (g * 255).toInt();
    final blue = (b * 255).toInt();
    return 'rgba($red, $green, $blue, ${a.toStringAsFixed(2)})';
  }

  /// Creates a semi-transparent version of this color
  /// [opacity] should be between 0.0 and 1.0
  Color withAlpha(double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    return withValues(alpha: opacity);
  }
}

/// Extension for creating Color from HEX string
extension ColorFromHex on String {
  /// Converts HEX string to Color
  /// Supports formats: "#RRGGBB", "#AARRGGBB", "RRGGBB", "AARRGGBB"
  /// Example: "#0000FF".toColor() -> Color(0xFF0000FF)
  Color toColor() {
    String hex = replaceAll('#', '');
    
    // Add alpha if not present
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    
    if (hex.length != 8) {
      throw FormatException('Invalid hex color format: $this');
    }
    
    return Color(int.parse('0x$hex'));
  }

  /// Tries to convert HEX string to Color, returns null if invalid
  /// Example: "#0000FF".toColorOrNull() -> Color(0xFF0000FF)
  Color? toColorOrNull() {
    try {
      return toColor();
    } catch (e) {
      return null;
    }
  }
}
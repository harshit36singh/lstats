import 'package:flutter/material.dart';

class AppThemeColors {
  static const Map<String, Color> darkColors = {
    'background': Color(0xFF1A1A1A),
    'surface': Color(0xFF262626),
    'primary': Color(0xFFFFA116),
    'textPrimary': Color(0xFFFFFFFF),
    'textSecondary': Color(0xFFB3B3B3),
    'border': Color(0xFF404040),
    'inputFill': Color(0xFF2A2A2A),
    'easy': Color(0xFF00B8A3),
    'medium': Color(0xFFFFB800),
    'hard': Color(0xFFFF375F),
  };
  
  static const Map<String, Color> lightColors = {
    'background': Color(0xFFF5F5F5),
    'surface': Color(0xFFFFFFFF),
    'primary': Color(0xFFFFA116),
    'textPrimary': Color(0xFF1A1A1A),
    'textSecondary': Color(0xFF666666),
    'border': Color(0xFFE0E0E0),
    'inputFill': Color(0xFFFFFFFF),
    'easy': Color(0xFF00B8A3),
    'medium': Color(0xFFFFB800),
    'hard': Color(0xFFFF375F),
  };

  static Map<String, Color> getColors(bool isDarkMode) {
    return isDarkMode ? darkColors : lightColors;
  }

  // Convenience getters for individual colors
  static Color getBackgroundColor(bool isDarkMode) => 
      isDarkMode ? darkColors['background']! : lightColors['background']!;
  
  static Color getSurfaceColor(bool isDarkMode) => 
      isDarkMode ? darkColors['surface']! : lightColors['surface']!;
  
  static Color getPrimaryColor(bool isDarkMode) => 
      isDarkMode ? darkColors['primary']! : lightColors['primary']!;
  
  static Color getTextPrimaryColor(bool isDarkMode) => 
      isDarkMode ? darkColors['textPrimary']! : lightColors['textPrimary']!;
  
  static Color getTextSecondaryColor(bool isDarkMode) => 
      isDarkMode ? darkColors['textSecondary']! : lightColors['textSecondary']!;
  
  static Color getBorderColor(bool isDarkMode) => 
      isDarkMode ? darkColors['border']! : lightColors['border']!;
  
  static Color getInputFillColor(bool isDarkMode) => 
      isDarkMode ? darkColors['inputFill']! : lightColors['inputFill']!;
  
  static Color getEasyColor(bool isDarkMode) => 
      isDarkMode ? darkColors['easy']! : lightColors['easy']!;
  
  static Color getMediumColor(bool isDarkMode) => 
      isDarkMode ? darkColors['medium']! : lightColors['medium']!;
  
  static Color getHardColor(bool isDarkMode) => 
      isDarkMode ? darkColors['hard']! : lightColors['hard']!;

  // Heatmap colors for calendar
  static Color getHeatmapDefaultColor(bool isDarkMode) => 
      isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE5E5E5);
  
  static Map<int, Color> getHeatmapColorsets(bool isDarkMode) => {
    1: isDarkMode ? const Color(0xFF0E4429) : const Color(0xFF9BE9A8),
    3: isDarkMode ? const Color(0xFF006D32) : const Color(0xFF40C463),
    5: isDarkMode ? const Color(0xFF26A641) : const Color(0xFF30A14E),
    10: getEasyColor(isDarkMode),
  };
}
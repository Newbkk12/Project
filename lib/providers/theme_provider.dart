import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/local_storage.dart';

class ThemeProvider extends ChangeNotifier {
  String _theme = 'dark';
  bool _darkMode = true;
  double _fontSize = 14.0;

  String get theme => _theme;
  bool get darkMode => _darkMode;
  double get fontSize => _fontSize;

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    final settings = getLocalStorageItem('toramSettings');
    if (settings != null && settings.isNotEmpty) {
      try {
        final data = jsonDecode(settings);
        _theme = data['theme'] ?? 'dark';
        _darkMode = data['darkMode'] ?? true;
        _fontSize = data['fontSize'] ?? 14.0;
        notifyListeners();
      } catch (_) {}
    }
  }

  void setTheme(String newTheme) {
    _theme = newTheme;
    _saveSettings();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    _saveSettings();
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _saveSettings();
    notifyListeners();
  }

  void _saveSettings() {
    final settings = getLocalStorageItem('toramSettings');
    Map<String, dynamic> data = {};

    if (settings != null && settings.isNotEmpty) {
      try {
        data = jsonDecode(settings);
      } catch (_) {}
    }

    data['theme'] = _theme;
    data['darkMode'] = _darkMode;
    data['fontSize'] = _fontSize;

    setLocalStorageItem('toramSettings', jsonEncode(data));
  }

  ThemeData getThemeData() {
    Color primaryColor;
    Color backgroundColor;
    Color surfaceColor;
    Color navigationBackground;
    Color cardBackground;

    switch (_theme) {
      case 'blue':
        primaryColor = const Color(0xFF2196F3);
        backgroundColor =
            _darkMode ? const Color(0xFF0D1B2A) : const Color(0xFFE3F2FD);
        surfaceColor =
            _darkMode ? const Color(0xFF1B263B) : const Color(0xFFBBDEFB);
        navigationBackground =
            _darkMode ? const Color(0xFF0A1520) : const Color(0xFFBBDEFB);
        cardBackground =
            _darkMode ? const Color(0xFF162638) : const Color(0xFFE3F2FD);
        break;
      case 'green':
        primaryColor = const Color(0xFF10A37F);
        backgroundColor =
            _darkMode ? const Color(0xFF0A1612) : const Color(0xFFE8F5E9);
        surfaceColor =
            _darkMode ? const Color(0xFF1A2F26) : const Color(0xFFC8E6C9);
        navigationBackground =
            _darkMode ? const Color(0xFF0D1F1A) : const Color(0xFFC8E6C9);
        cardBackground =
            _darkMode ? const Color(0xFF15382B) : const Color(0xFFE8F5E9);
        break;
      case 'dark':
      default:
        primaryColor = const Color(0xFF10A37F);
        backgroundColor =
            _darkMode ? const Color(0xFF192127) : const Color(0xFFF5F5F5);
        surfaceColor =
            _darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        navigationBackground =
            _darkMode ? const Color(0xFF313440) : const Color(0xFFEEEEEE);
        cardBackground =
            _darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    }

    return ThemeData(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: navigationBackground,
        selectedIconTheme: IconThemeData(color: primaryColor, size: 24),
        unselectedIconTheme: IconThemeData(
            color: _darkMode ? Colors.white70 : Colors.black54, size: 24),
        selectedLabelTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: _darkMode ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
        indicatorColor: primaryColor.withValues(alpha: 0.3),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navigationBackground,
        selectedItemColor: primaryColor,
        unselectedItemColor: _darkMode ? Colors.white70 : Colors.black54,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: _darkMode
          ? const Color(0xFF313440)
          : Colors.grey.withValues(alpha: 0.3),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
            fontSize: _fontSize,
            color: _darkMode ? Colors.white : Colors.black87),
        bodyMedium: TextStyle(
            fontSize: _fontSize - 1,
            color: _darkMode ? Colors.white : Colors.black87),
        bodySmall: TextStyle(
            fontSize: _fontSize - 2,
            color: _darkMode ? Colors.white70 : Colors.black54),
        titleLarge: TextStyle(
            fontSize: _fontSize + 6,
            fontWeight: FontWeight.bold,
            color: _darkMode ? Colors.white : Colors.black87),
        titleMedium: TextStyle(
            fontSize: _fontSize + 2,
            fontWeight: FontWeight.w600,
            color: _darkMode ? Colors.white : Colors.black87),
        titleSmall: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w500,
            color: _darkMode ? Colors.white : Colors.black87),
      ),
      colorScheme: ColorScheme(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: primaryColor,
        onSecondary: Colors.white,
        error: const Color(0xFFef4444),
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: _darkMode ? Colors.white : Colors.black87,
      ),
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(
          cardBackground: cardBackground,
          navigationBackground: navigationBackground,
          primaryColor: primaryColor,
        ),
      ],
      fontFamily: 'Kanit',
    );
  }

  Color get primaryColor {
    switch (_theme) {
      case 'blue':
        return const Color(0xFF2196F3);
      case 'green':
        return const Color(0xFF10A37F);
      case 'dark':
      default:
        return const Color(0xFF10A37F);
    }
  }
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color cardBackground;
  final Color navigationBackground;
  final Color primaryColor;

  const CustomColors({
    required this.cardBackground,
    required this.navigationBackground,
    required this.primaryColor,
  });

  @override
  CustomColors copyWith({
    Color? cardBackground,
    Color? navigationBackground,
    Color? primaryColor,
  }) {
    return CustomColors(
      cardBackground: cardBackground ?? this.cardBackground,
      navigationBackground: navigationBackground ?? this.navigationBackground,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      navigationBackground:
          Color.lerp(navigationBackground, other.navigationBackground, t)!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
    );
  }
}

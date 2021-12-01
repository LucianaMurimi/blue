import 'package:flutter/material.dart';

// C0LOURS
//------------------------------------------------------------------------------
const Color accessPrimary = Color(0xFF4c4c4c);
const Color accessPrimaryVariant = Color(0xFF323232);

const Color accessSecondary = Color(0xFF005f81);
const Color accessSecondaryVariant = Color(0xFF003554);

const Color accessErrorRed = Color(0xFFc85300);
const Color accessBlack = Color(0xFF000000);
const Color accessWhite = Color(0xFFffffff);


// THEME DATA
//------------------------------------------------------------------------------
ThemeData accessTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    colorScheme: _accessColorScheme,
    primaryColor: accessPrimary,
    errorColor: accessErrorRed,

    scaffoldBackgroundColor: Colors.white,

    textTheme: _accessTextTheme(base.textTheme),
    primaryTextTheme: _accessTextTheme(base.primaryTextTheme),
    accentTextTheme: _accessTextTheme(base.accentTextTheme),

    textSelectionColor: accessSecondary,

    iconTheme: accessIconTheme(base.iconTheme),
  );
}

// ICON THEME
//------------------------------------------------------------------------------
IconThemeData accessIconTheme(IconThemeData original) {
  return original.copyWith(
    color: accessPrimaryVariant,
  );
}

// TEXT THEME
//------------------------------------------------------------------------------
TextTheme _accessTextTheme(TextTheme base) {
  return base
      .apply(
    fontFamily: 'WorkSansMedium',
  );
}


// COLOR SCHEME
//------------------------------------------------------------------------------
const ColorScheme _accessColorScheme = ColorScheme(
  primary: accessPrimary,
  primaryVariant: accessPrimaryVariant,
  onPrimary: accessBlack,

  secondary: accessSecondary,
  secondaryVariant: accessSecondaryVariant,
  onSecondary: accessWhite,

  surface: accessWhite,
  onSurface: accessBlack,

  background: accessWhite,
  onBackground: accessBlack,

  error: accessErrorRed,
  onError: accessWhite,

  brightness: Brightness.dark,
);



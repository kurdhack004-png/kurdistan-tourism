import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's SDK does not ship Material/Widgets/Cupertino localizations for
/// Central Kurdish (`ckb`). Without them `MaterialLocalizations.of(context)`
/// returns null and every widget that needs it (NavigationBar, TextField,
/// AppBar back button, date pickers ...) throws
/// "Null check operator used on a null value".
///
/// These delegates answer for `ckb` by reusing the Arabic localizations
/// (same script, RTL), so all built-in widgets work in Sorani.
class _CkbMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _CkbMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class _CkbWidgetsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _CkbWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) => false;
}

class _CkbCupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CkbCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}

const List<LocalizationsDelegate<dynamic>> ckbLocalizationDelegates = [
  _CkbMaterialDelegate(),
  _CkbWidgetsDelegate(),
  _CkbCupertinoDelegate(),
];

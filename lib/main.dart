import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/expense_model.dart';
import 'models/income_model.dart';
import 'models/category_model.dart';
import 'package:flutter_gen/gen_l10n/S.dart';
import 'page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode = prefs.getString('locale') ?? 'en';
  runApp(MyApp(savedLocaleCode: savedLocaleCode));
}

class MyApp extends StatefulWidget {
  final String savedLocaleCode;

  MyApp({required this.savedLocaleCode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.savedLocaleCode);
  }

  void _changeLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseModel()),
        ChangeNotifierProvider(create: (context) => IncomeModel()),
        ChangeNotifierProvider(create: (context) => CategoryModel()),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        locale: _locale,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.supportedLocales,
        home: HomePage(onLocaleChange: _changeLocale),
      ),
    );
  }
}

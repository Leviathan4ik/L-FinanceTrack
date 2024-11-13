import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/S.dart';
import 'package:new_proj_test/page/home_page.dart';
import 'package:new_proj_test/page/income_page.dart';
import 'package:new_proj_test/page/settings_page.dart';
import 'package:new_proj_test/page/expense_page.dart';
import 'package:new_proj_test/page/category_page.dart';

class DrawerMenu extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  DrawerMenu({required this.onLocaleChange});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? _username;
  String? _email;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? S.of(context)?.menuDefaultUsername ?? 'User';
      _email = prefs.getString('email') ?? 'user@example.com';
      _avatarPath = prefs.getString('avatarPath');
    });
  }

  Future<void> _navigateToSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SettingsPage(onLocaleChange: widget.onLocaleChange)),
    );
    _loadUserData(); // обновляем данные после возвращения из настроек
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                _username ?? S.of(context)?.menuDefaultUsername ?? 'User',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                _email ?? 'user@example.com',
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                child: _avatarPath == null
                    ? Icon(Icons.person,
                    size: 50, color: Colors.blue.shade700)
                    : null,
              ),
            ),
            _DrawerMenuItem(
              icon: Icons.home,
              title: S.of(context)?.menuHome ?? 'Home',
              onTap: () => _navigateTo(context, HomePage(onLocaleChange: widget.onLocaleChange)),
            ),
            _DrawerMenuItem(
              icon: Icons.settings,
              title: S.of(context)?.menuSettings ?? 'Settings',
              onTap: () => _navigateToSettings(context),
            ),
            _DrawerMenuItem(
              icon: Icons.contact_page,
              title: S.of(context)?.menuIncome ?? 'Income',
              onTap: () => _navigateTo(context, IncomePage()),
            ),
            _DrawerMenuItem(
              icon: Icons.money_off,
              title: S.of(context)?.menuExpense ?? 'Expense',
              onTap: () => _navigateTo(context, ExpensePage()),
            ),
            _DrawerMenuItem(
              icon: Icons.category,
              title: S.of(context)?.menuCategories ?? 'Expense Categories',
              onTap: () => _navigateTo(context, CategoryPage()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

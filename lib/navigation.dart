import 'package:flutter/material.dart';
import 'package:simsoft/NavbarScreens/articles/articles.dart';
import 'package:simsoft/NavbarScreens/dashboard/home.dart';
import 'package:simsoft/NavbarScreens/settings/settings.dart';
import 'package:simsoft/NavbarScreens/users/users.dart';

class MainNavPage extends StatefulWidget {
  final String role;
  const MainNavPage({super.key, required this.role});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdminOrChef = widget.role.toLowerCase() == 'admin' ||
        widget.role.toLowerCase() == 'chef d\'equipe';

    final List<Widget> pages = [
      HomePage(role: widget.role),
      
      ArticlesManagementPage(role : widget.role),
      if (isAdminOrChef) UsersManagementPage(),
      const AccountSettingsPage(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard), label: 'Dashboard'),
          

      const BottomNavigationBarItem(
          icon: Icon(Icons.article), label: 'Articles'),
      if (isAdminOrChef)
        const BottomNavigationBarItem(
            icon: Icon(Icons.group_add), label: 'Utilisateurs'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.settings), label: 'Paramètres'),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}

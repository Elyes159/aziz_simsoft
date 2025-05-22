import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // si tu utilises Firebase
import 'package:simsoft/Auth/login.dart';
import 'package:simsoft/NavbarScreens/articles/articles.dart';
import 'package:simsoft/NavbarScreens/dashboard/dashboard.dart';
import 'package:simsoft/NavbarScreens/menu/home.dart';
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
      if (isAdminOrChef) StatisticsDashboard(),
      HomePage(role: widget.role),
      ArticlesManagementPage(role: widget.role),
      if (isAdminOrChef) const UsersManagementPage(),
      const AccountSettingsPage(),
    ];

    final List<String> titles = [
      if (isAdminOrChef) 'Dashboard',
      'Menu',
      'Articles',
      if (isAdminOrChef) 'Utilisateurs',
      'Paramètres',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
             
              child: Image.asset("assets/images/logo.png" , color: Colors.black,),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (isAdminOrChef)
                    _buildDrawerItem(
                        icon: Icons.chalet_sharp, title: 'Dashboard', index: 0),
                  _buildDrawerItem(
                      icon: Icons.dashboard,
                      title: 'Menu',
                      index: isAdminOrChef ? 1 : 0),
                  _buildDrawerItem(
                      icon: Icons.article,
                      title: 'Articles',
                      index: isAdminOrChef ? 2 : 1),
                  if (isAdminOrChef)
                    _buildDrawerItem(
                        icon: Icons.group_add,
                        title: 'Utilisateurs',
                        index: 3),
                  _buildDrawerItem(
                      icon: Icons.settings,
                      title: 'Paramètres',
                      index: isAdminOrChef ? 4 : 2),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // déconnexion Firebase
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Fermer le drawer
      },
    );
  }
}

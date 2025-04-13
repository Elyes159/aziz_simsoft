import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simsoft/Auth/login.dart';

class HomePage extends StatelessWidget {
  final String role;
  const HomePage({super.key, required this.role});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTechnicien = role.toLowerCase() == "technicien";
    final isMecanicien = role.toLowerCase() == "mecanicien";

    final isAdmin = role.toLowerCase() == "admin";
    final isChef =  role.toLowerCase() == 'chef d\'équipe';

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil ($role)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, right: 10, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bienvenue, vous êtes connecté en tant que $role',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: (isTechnicien || isAdmin || isMecanicien || isChef)
                  ? GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: isTechnicien || isMecanicien
                          ? [
                              _buildHomeButton(
                                icon: Icons.build,
                                label: 'Liste des équipements',
                                onPressed: () {},
                              ),
                              _buildHomeButton(
                                icon: Icons.calendar_today,
                                label: 'Planning d’intervention',
                                onPressed: () {},
                              ),
                              _buildHomeButton(
                                icon: Icons.description,
                                label: 'Mes propres rapports',
                                onPressed: () {},
                              ),
                              _buildHomeButton(
                                icon: Icons.report_problem,
                                label: 'État de Mes demandes',
                                onPressed: () {},
                              ),
                            ]
                          : [
                              _buildHomeButton(
                                icon: Icons.assignment,
                                label: 'Nombre de demandes',
                                onPressed: () {},
                              ),
                              _buildHomeButton(
                                icon: Icons.bar_chart,
                                label: 'État des interventions',
                                onPressed: () {},
                              ),
                              _buildHomeButton(
                                icon: Icons.engineering,
                                label: 'Activité par technicien',
                                onPressed: () {},
                              ),
                              _buildHomeButton(
                                icon: Icons.calendar_today,
                                label: 'Planning global',
                                onPressed: () {},
                              ),
                            ],
                    )
                  : const Center(
                      child: Text(
                        'Aucun contenu disponible pour ce rôle.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            
            
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

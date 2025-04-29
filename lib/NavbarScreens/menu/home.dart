import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simsoft/Auth/login.dart';
import 'package:simsoft/screensDashboard/activ_par_tech/activite.dart';
import 'package:simsoft/screensDashboard/demandesTech.dart/demande.dart';
import 'package:simsoft/screensDashboard/equipements/equipAdmin.dart';
import 'package:simsoft/screensDashboard/equipements/liste_equip.dart';
import 'package:simsoft/screensDashboard/etatInter/etat_inter.dart';
import 'package:simsoft/screensDashboard/planing/admin.dart';
import 'package:simsoft/screensDashboard/planing/calendrier.dart';
import 'package:simsoft/screensDashboard/rapports/techmec.dart';

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
    final isChef = role.toLowerCase() == 'chef d\'equipe';
    final isOuvrier = role.toLowerCase() == 'ouvrier';
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
                      children: _getButtonsForRole(
                        context: context,
                        isTechnicien: isTechnicien,
                        isMecanicien: isMecanicien,
                        isAdmin: isAdmin,
                        isChef: isChef,
                      ),
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

  List<Widget> _getButtonsForRole({
    required BuildContext context,
    required bool isTechnicien,
    required bool isMecanicien,
    required bool isAdmin,
    required bool isChef,
  }) {
    if (isTechnicien || isMecanicien) {
      return [
        _buildHomeButton(
          context: context,
          icon: Icons.build,
          label: 'Liste des équipements',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListeEquipementsPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.calendar_today,
          label: 'Planning d\'intervention',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlanningGlobalPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.description,
          label: 'Mes propres rapports',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateMaintenanceReportPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.report_problem,
          label: 'État de Mes demandes',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DemandeInterventionPage()));
          },
        ),
      ];
    } else if (isAdmin) {
      return [
        _buildHomeButton(
          context: context,
          icon: Icons.manage_search_sharp,
          label: 'Gestion des équipements',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EquipementPage(role: role,)));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.bar_chart,
          label: 'État des interventions',
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EtatInterventionsPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.engineering,
          label: 'Activité par technicien',
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TechnicianActivityPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.calendar_today,
          label: 'Planning global',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateEventPage()));
          },
        ),
      ];
    } else if (isChef){
       return [
         _buildHomeButton(
          context: context,
          icon: Icons.report_problem,
          label: 'État de Mes demandes',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DemandeInterventionPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.manage_search_sharp,
          label: 'Gestion des équipements',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EquipementPage(role: role,)));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.bar_chart,
          label: 'État des interventions',
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EtatInterventionsPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.engineering,
          label: 'Activité par technicien',
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TechnicianActivityPage()));
          },
        ),
        _buildHomeButton(
          context: context,
          icon: Icons.calendar_today,
          label: 'Planning global',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateEventPage()));
          },
        ),
      ];
    }
    return [];
  }

  Widget _buildHomeButton({
    required BuildContext context,
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
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

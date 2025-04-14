import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TechnicianActivityPage extends StatelessWidget {
  const TechnicianActivityPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchTechnicianStats() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: ['technicien', 'mecanicien']).get();

    List<Map<String, dynamic>> results = [];

    for (var user in usersSnapshot.docs) {
      final userId = user.id;
      final userData = user.data();

      final interventionsCount = await FirebaseFirestore.instance
          .collection('demandes_intervention')
          .where('demandeur_id', isEqualTo: userId)
          .get();

      final demandesCount = await FirebaseFirestore.instance
          .collection('maintenance_reports')
          .where('technicien_id', isEqualTo: userId)
          .get();

      results.add({
        'email': userData['email'] ?? 'Inconnu',
        'role': userData['role'] ?? 'technicien',
        'interventions': interventionsCount.size,
        'demandes': demandesCount.size,
      });
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activité des techniciens')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTechnicianStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune activité trouvée.'));
          }

          final data = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final technician = data[index];
              return Card(
                child: ListTile(
                  title: Text(technician['email']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '🛠️ Interventions : ${technician['interventions']}'),
                      Text('📥 Demandes : ${technician['demandes']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

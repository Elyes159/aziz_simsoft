import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EtatInterventionsPage extends StatefulWidget {
  const EtatInterventionsPage({super.key});

  @override
  State<EtatInterventionsPage> createState() => _EtatInterventionsPageState();
}

class _EtatInterventionsPageState extends State<EtatInterventionsPage> {
  Future<Map<String, int>> _fetchStatusCounts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('demandes_intervention')
        .get();

    int enAttente = 0;
    int validees = 0;
    int terminees = 0;

    for (var doc in snapshot.docs) {
      final status = doc['status'];
      if (status == 'en attente') {
        enAttente++;
      } else if (status == 'validee') {
        validees++;
      } else if (status == 'terminee') {
        terminees++;
      }
    }

    return {
      'en_attente': enAttente,
      'validee': validees,
      'terminee': terminees,
    };
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('demandes_intervention')
        .doc(docId)
        .update({'status': newStatus});
    setState(() {}); // pour recharger l'interface
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("État des interventions")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map<String, int>>(
              future: _fetchStatusCounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("Aucune donnée disponible."));
                }

                final data = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatusCard("📥 En attente", data['en_attente'] ?? 0, Colors.orange),
                      const SizedBox(height: 16),
                      _buildStatusCard("✅ Validées", data['validee'] ?? 0, Colors.blue),
                      const SizedBox(height: 16),
                      _buildStatusCard("🏁 Terminées", data['terminee'] ?? 0, Colors.green),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("📋 Liste des demandes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('demandes_intervention')
                  .orderBy('status')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text("🛠️ ${data['equipement_nom'] ?? 'Équipement inconnu'}"),
                        subtitle: Text("Statut : ${data['status']}"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            _updateStatus(doc.id, value);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'validee', child: Text('✅ Valider')),
                            const PopupMenuItem(value: 'terminee', child: Text('🏁 Terminer')),
                            const PopupMenuItem(value: 'refusee', child: Text('❌ Refuser')),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            "$count",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

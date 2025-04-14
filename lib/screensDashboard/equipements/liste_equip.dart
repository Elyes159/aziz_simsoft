import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListeEquipementsPage extends StatelessWidget {
  const ListeEquipementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des équipements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('equipements')
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Aucun équipement enregistré.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final equipement = snapshot.data!.docs[index];
                return Card(
                  child: ListTile(
                    title: Text(equipement['nom']),
                    subtitle: Text(equipement['description']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simsoft/Widgets/CustomButton.dart';

class EquipementPage extends StatefulWidget {
  final String role;
  const EquipementPage({super.key, required this.role});

  @override
  State<EquipementPage> createState() => _EquipementPageState();
}

class _EquipementPageState extends State<EquipementPage> {
  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _description = '';
  bool _isSubmitting = false;

  Future<void> _addEquipement() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('equipements').add({
        'nom': _nom,
        'description': _description,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Équipement ajouté avec succès')),
      );

      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAdminOrChef = widget.role == 'admin' || widget.role == 'chef_equipe';

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des équipements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isAdminOrChef) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nom de l\'équipement'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Veuillez entrer un nom' : null,
                        onSaved: (value) => _nom = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Veuillez entrer une description' : null,
                        onSaved: (value) => _description = value!.trim(),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onTap: _isSubmitting ? () {} : _addEquipement,
                        label: (_isSubmitting ? 'Ajout en cours...' : 'Ajouter'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(),
              ],
              const SizedBox(height: 10),
              const Text(
                "Liste des équipements",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('equipements')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('Aucun équipement enregistré.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
            ],
          ),
        ),
      ),
    );
  }
}

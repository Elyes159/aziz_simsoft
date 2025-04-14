import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simsoft/Widgets/CustomButton.dart';

class CreateMaintenanceReportPage extends StatefulWidget {
  const CreateMaintenanceReportPage({super.key});

  @override
  State<CreateMaintenanceReportPage> createState() =>
      _CreateMaintenanceReportPageState();
}

class _CreateMaintenanceReportPageState
    extends State<CreateMaintenanceReportPage> {
  final _formKey = GlobalKey<FormState>();
  String _equipementId = '';
  String _problemeResolu = '';
  String _interventionEffectuee = '';
  DateTime _dateIntervention = DateTime.now();
  bool _isSubmitting = false;
  List<DocumentSnapshot> _equipements = [];
  String? _selectedEquipementId;
  Future<void> _loadEquipements() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('equipements').get();
    setState(() {
      _equipements = snapshot.docs;
    });
  }

  Future<void> _addMaintenanceReport() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('maintenance_reports').add({
        'equipement_id': _equipementId,
        'probleme_resolu': _problemeResolu,
        'intervention_effectuee': _interventionEffectuee,
        'date_intervention': Timestamp.fromDate(_dateIntervention),
        'created_at': Timestamp.now(),
        'technicien_id': user!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Rapport de maintenance créé avec succès')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _dateIntervention = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateIntervention,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),

    );

    if (pickedDate != null) {
      setState(() {
        _dateIntervention = pickedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEquipements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapports de maintenance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FORMULAIRE
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Équipement'),
                      items: _equipements.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(data['nom'] ?? 'Équipement sans nom'),
                        );
                      }).toList(),
                      value: _selectedEquipementId,
                      onChanged: (value) {
                        setState(() {
                          _selectedEquipementId = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner un équipement'
                          : null,
                      onSaved: (value) => _equipementId = value!,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Problème résolu'),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez décrire le problème résolu'
                          : null,
                      onSaved: (value) => _problemeResolu = value!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Intervention effectuée'),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez décrire l\'intervention effectuée'
                          : null,
                      onSaved: (value) =>
                          _interventionEffectuee = value!.trim(),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Date de l\'intervention'),
                        child: Text(
                          '${_dateIntervention.toLocal()}'.split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onTap: _isSubmitting ? () {} : _addMaintenanceReport,
                      label: _isSubmitting
                          ? "chargements..."
                          : ('Créer le rapport'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Liste des rapports de maintenance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // LISTE DES RAPPORTS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('maintenance_reports')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                        'Aucun rapport de maintenance disponible.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                              "Équipement : ${data['equipement_id'] ?? 'N/A'}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Problème : ${data['probleme_resolu'] ?? ''}"),
                              Text(
                                  "Intervention : ${data['intervention_effectuee'] ?? ''}"),
                              if (data['date_intervention'] != null)
                                Text(
                                  "Date : ${(data['date_intervention'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
                                ),
                            ],
                          ),
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

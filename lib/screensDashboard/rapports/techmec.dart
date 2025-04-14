import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateMaintenanceReportPage extends StatefulWidget {
  const CreateMaintenanceReportPage({super.key});

  @override
  State<CreateMaintenanceReportPage> createState() => _CreateMaintenanceReportPageState();
}

class _CreateMaintenanceReportPageState extends State<CreateMaintenanceReportPage> {
  final _formKey = GlobalKey<FormState>();
  String _equipementId = '';
  String _problemeResolu = '';
  String _interventionEffectuee = '';
  DateTime _dateIntervention = DateTime.now();
  bool _isSubmitting = false;

  // Fonction pour ajouter un rapport de maintenance à Firestore
  Future<void> _addMaintenanceReport() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('maintenance_reports').add({
        'equipement_id': _equipementId,
        'probleme_resolu': _problemeResolu,
        'intervention_effectuee': _interventionEffectuee,
        'date_intervention': Timestamp.fromDate(_dateIntervention),
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapport de maintenance créé avec succès')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _dateIntervention = DateTime.now(); // Réinitialiser la date
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  // Fonction pour sélectionner une date via un calendrier
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateIntervention,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null && pickedDate != _dateIntervention) {
      setState(() {
        _dateIntervention = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un rapport de maintenance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID de l\'équipement concerné'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer un ID d\'équipement' : null,
                onSaved: (value) => _equipementId = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Problème résolu'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez décrire le problème résolu' : null,
                onSaved: (value) => _problemeResolu = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Intervention effectuée'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez décrire l\'intervention effectuée' : null,
                onSaved: (value) => _interventionEffectuee = value!.trim(),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date de l\'intervention'),
                  child: Text(
                    '${_dateIntervention.toLocal()}'.split(' ')[0], // Afficher la date sélectionnée
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _addMaintenanceReport,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Créer le rapport'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

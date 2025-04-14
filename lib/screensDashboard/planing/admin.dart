import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simsoft/Widgets/CustomButton.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  DateTime _eventDate = DateTime.now();
  bool _isSubmitting = false;

  // Fonction pour ajouter un événement à Firestore
  Future<void> _addEvent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('planning').add({
        'event_name': _eventName,
        'date': Timestamp.fromDate(_eventDate),
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement créé avec succès')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _eventDate = DateTime.now(); // Réinitialise la date
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
      initialDate: _eventDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2027),
    );

    if (pickedDate != null && pickedDate != _eventDate) {
      setState(() {
        _eventDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom de l\'événement'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer un nom d\'événement' : null,
                onSaved: (value) => _eventName = value!.trim(),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date de l\'événement'),
                  child: Text(
                    '${_eventDate.toLocal()}'.split(' ')[0], // Afficher la date sélectionnée
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onTap: _isSubmitting ? (){} : _addEvent,
                label: _isSubmitting ?  ("chargements...") :  ('Créer l\'événement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

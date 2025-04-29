import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simsoft/Widgets/CustomButton.dart';

class DemandeInterventionPage extends StatefulWidget {
  const DemandeInterventionPage({super.key});

  @override
  State<DemandeInterventionPage> createState() => _DemandeInterventionPageState();
}

class _DemandeInterventionPageState extends State<DemandeInterventionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEquipement;
  String _probleme = '';
  String _urgence = 'moyenne';
  bool _isSubmitting = false;
  String? _userName;
  String? _userAddress;
  String _additionalField = '';
  List<String> _equipements = [];
  bool _isLoading = true;
  bool _showPreviousRequests = false; // Nouveau booléen pour gérer l'affichage

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadEquipements(),
        _loadUserData(),
      ]);
    } catch (e) {
      debugPrint("Erreur de chargement: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEquipements() async {
    final snapshot = await FirebaseFirestore.instance.collection('equipements').get();
    setState(() {
      _equipements = snapshot.docs.map((doc) => doc['nom'] as String).toList();
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      setState(() {
        _userName = user.email?.split('@').first ?? 'Utilisateur';
        _userAddress = userDoc.data()?['address'] ?? 'Adresse non définie';
      });
    }
  }

  Future<void> _submitDemande() async {
    if (!_formKey.currentState!.validate() || _selectedEquipement == null) {
      return;
    }
    if (_userName == null || _userAddress == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté")),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('demandes_intervention').add({
        'equipement_id': _selectedEquipement,
        'equipement_nom': _selectedEquipement,
        'probleme': _probleme,
        'niveau_urgence': _urgence,
        'status': 'en attente',
        'demandeur_id': user.uid,
        'demandeur_nom': _userName,
        'demandeur_adresse': _userAddress,
        'champ_supplementaire': _additionalField,
        'date_demande': Timestamp.now(),
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande envoyée avec succès")),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedEquipement = null;
        _urgence = 'moyenne';
        _additionalField = '';
      });
    } catch (e) {
      debugPrint("Erreur demande : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Demande d'intervention")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formulaire
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Adresse',
                                  ),
                                  initialValue: _userAddress,
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                  ),
                                  initialValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Référence',
                                  ),
                                  onSaved: (val) => _additionalField = val ?? '',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Équipement concerné'),
                            items: _equipements
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            value: _selectedEquipement,
                            onChanged: (val) => setState(() => _selectedEquipement = val),
                            validator: (val) => val == null
                                ? 'Veuillez choisir un équipement'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Description du problème'),
                            maxLines: 3,
                            onSaved: (val) => _probleme = val ?? '',
                            validator: (val) => val == null || val.isEmpty
                                ? 'Veuillez décrire le problème'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Niveau d\'urgence'),
                            value: _urgence,
                            items: const [
                              DropdownMenuItem(value: 'faible', child: Text('Faible')),
                              DropdownMenuItem(value: 'moyenne', child: Text('Moyenne')),
                              DropdownMenuItem(value: 'élevée', child: Text('Élevée')),
                            ],
                            onChanged: (val) => setState(() => _urgence = val!),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            onTap: _isSubmitting ? () {} : _submitDemande,
                            label: (_isSubmitting ? 'Envoi...' : 'Soumettre'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Section avec bouton pour afficher/masquer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Mes demandes précédentes",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showPreviousRequests = !_showPreviousRequests;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _showPreviousRequests 
                                ? Colors.grey[300] 
                                : Theme.of(context).primaryColor,
                            foregroundColor: _showPreviousRequests 
                                ? Colors.black 
                                : Colors.white,
                          ),
                          child: Text(_showPreviousRequests ? 'Masquer' : 'Afficher'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Affichage conditionnel des demandes
                    if (_showPreviousRequests)
                      StreamBuilder<QuerySnapshot>(
                        stream: userId != null
                            ? FirebaseFirestore.instance
                                .collection('demandes_intervention')
                                .where('demandeur_id', isEqualTo: userId)
                                .orderBy('created_at', descending: true)
                                .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Erreur: ${snapshot.error}');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                "Aucune demande soumise pour le moment.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final demande = snapshot.data!.docs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(demande['equipement_nom']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Nom: ${demande['demandeur_nom'] ?? 'N/A'}"),
                                      Text("Date: ${DateFormat('dd/MM/yyyy').format((demande['created_at'] as Timestamp).toDate())}"),
                                      Text("Urgence: ${demande['niveau_urgence']}"),
                                      Text("Problème: ${demande['probleme']}"),
                                    ],
                                  ),
                                  trailing: Chip(
                                    label: Text(demande['status']),
                                    backgroundColor:
                                        demande['status'] == 'validée'
                                            ? Colors.green.shade100
                                            : demande['status'] == 'refusée'
                                                ? Colors.red.shade100
                                                : Colors.grey.shade300,
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
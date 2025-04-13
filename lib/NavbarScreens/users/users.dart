import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simsoft/Widgets/CustomButton.dart';
import 'package:simsoft/Widgets/customTextfield.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  bool _isLoading = false; // État de chargement

  Future<void> _addUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roleController.text.trim();

    if (email.isEmpty || password.isEmpty || role.isEmpty) return;

    setState(() => _isLoading = true); // Début chargement

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': role,
        'email': email, // 👈 email ajouté ici
      });

      _emailController.clear();
      _passwordController.clear();
      _roleController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur ajouté avec succès')),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }

    setState(() => _isLoading = false); // Fin chargement
  }

  Future<void> _deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      // La suppression dans Firebase Auth nécessite Admin SDK (côté serveur)
    } catch (e) {
      debugPrint('Erreur suppression utilisateur: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllUsers() async {
  final snapshot = await FirebaseFirestore.instance.collection('users').get();
  return snapshot.docs
      .where((doc) => doc.data()['role'] != 'admin')  // Filtrer les admin
      .map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'email': data['email'] ?? 'Email inconnu',
          'role': data['role'] ?? 'Aucun rôle',
        };
      }).toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulaire
            CustomTextFormField(
              controller: _emailController,
              label: "email",
              isPassword: false,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextFormField(
              controller: _passwordController,
              isPassword: true,
              label: ('Mot de passe'),
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextFormField(
              controller: _roleController,
              label: ('Rôle'),
              isPassword: false,
            ),
            const SizedBox(height: 10),
            CustomButton(
              buttonColor: _isLoading ? Colors.grey : Colors.black,
              onTap: _isLoading ? () {} : _addUser,
              label:
                  _isLoading ? 'Ajout en cours...' : 'Ajouter un utilisateur',
            ),

            const Divider(height: 32),

            // Liste des utilisateurs (affichage limité au client connecté)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Aucun utilisateur trouvé.'));
                  }

                  final users = snapshot.data!;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return ListTile(
                        title: Text(user['email']),
                        subtitle: Text('Rôle: ${user['role']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['uid']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

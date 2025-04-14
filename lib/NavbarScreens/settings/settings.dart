import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simsoft/Widgets/customTextfield.dart';
import 'package:simsoft/Widgets/CustomButton.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email mis à jour avec succès.')));
      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty || password.length < 6) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(password);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour avec succès.')));
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres du compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Email actuel : ${user?.email ?? ''}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            CustomTextFormField(controller: _emailController, label: 'Nouvel Email', isPassword: false),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Changer l\'email',
              buttonColor: Colors.black,
              onTap: _isLoading ? (){} : _updateEmail,
            ),

            const Divider(height: 40),

            CustomTextFormField(controller: _passwordController, label: 'Nouveau mot de passe', isPassword: true),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Changer le mot de passe',
              buttonColor: Colors.black,
              onTap: _isLoading ? (){} : _updatePassword,
            ),
          ],
        ),
      ),
    );
  }
}

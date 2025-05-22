import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simsoft/NavbarScreens/menu/home.dart';
import 'package:simsoft/drawer/drawer.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || !doc.data()!.containsKey('role')) {
        return 'Rôle non défini pour cet utilisateur.';
      }

      final role = doc['role'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavPage(role: role),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur inconnue : $e';
    }

    return null;
  }
}

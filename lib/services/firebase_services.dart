import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getUser(BuildContext context) async {
  final List<Map<String, dynamic>> users = [];
  try {
    final QuerySnapshot querySnapshot = await db.collection('user').get();
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final email = (data['email'] ?? '').toString().trim();
      final password = (data['password'] ?? '').toString();
      final name = (data['name'] ?? '').toString();
      final isadmin = data['isadmin'] ?? false;
      final idCarnet = data['id_carnet'] != null
          ? int.tryParse(data['id_carnet'].toString()) ?? 0
          : 0;
      final cedula = data['cedula'] ?? '';
      final dateLogin = data['date_login'] != null && data['date_login'] is Timestamp
          ? (data['date_login'] as Timestamp).toDate()
          : null;
      final uid = doc.id;
          

      final person = {
        'name': name,
        'uid': uid,
        'email': email,
        'password': password,
        'isadmin': isadmin,
        'id_carnet': idCarnet,
        'cedula': cedula,
        'date_login': dateLogin,
      };
      users.add(person);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexion: $e')),
    );
    return [];
  }
  return users;
}

Future<void> addUser(
  String name,
  String email,
  bool isadmin,
  int idCarnet,
  String cedula,
  DateTime dateCreated,
  DateTime dateLogin,
) async {
  await db.collection('user').add({
    'name': name,
    'email': email,
    'isadmin': isadmin,
    'id_carnet': idCarnet,
    'cedula': cedula,
    'date_created': dateCreated,
    'date_login': dateLogin,
  });
}

Future<void> updateUser(
  String name,
  int idCarnet,
  String cedula,

  String uid,
) async {
  await db.collection('user').doc(uid).set({
    'name': name,
    'id_carnet': idCarnet,
    'cedula': cedula,
  });
}

Future<void> updateUserLoginDate(
  DateTime dateLogin,
  String uid,
) async {
  await db.collection('user').doc(uid).update({
    'date_login': dateLogin,
  });
}

Future<void> deleteUser(String uid) async {
  await db.collection('user').doc(uid).delete();
}


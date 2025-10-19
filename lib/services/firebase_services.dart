import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

/// Returns a list of user maps. Ensures `email` and `password` are always
/// present as strings (defaults to empty string when missing). Returns an
/// empty list on error and prints the exception for debugging.
Future<List<Map<String, dynamic>>> getUser() async {
  final List<Map<String, dynamic>> users = [];
  try {
    final QuerySnapshot querySnapshot = await db.collection('user').get();
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      // Normalize fields and provide safe defaults
      final email = (data['email'] ?? '').toString().trim();
      final password = (data['password'] ?? '').toString();
      final name = (data['name'] ?? '').toString();
      final isadmin = data['isadmin'] ?? false;
      final idCarnet = data['id_carnet'] != null
          ? int.tryParse(data['id_carnet'].toString()) ?? 0
          : 0;
      final cedula = data['cedula'] ?? '';

      final person = {
        'name': name,
        'uid': doc.id,
        'email': email,
        'password': password,
        'isadmin': isadmin,
        'id_carnet': idCarnet,
        'cedula': cedula,
      };
      users.add(person);
    }
  } catch (e, st) {
    // Don't throw; return empty list and log for debugging
    print('Error in getUser(): $e\n$st');
    return [];
  }
  return users;
}

Future<void> addUser(
  String name,
  String email,
  String password,
  bool isadmin,
  String id_carnet,
  String cedula,
) async {
  await db.collection('user').add({
    'name': name,
    'email': email,
    'password': password,
    'isadmin': isadmin,
    'id_carnet': int.parse(id_carnet),
    'cedula': cedula,
  });
}

Future<void> updateUser(
  String name,
  String email,
  String password,
  bool isadmin,
  int id_carnet,
  String cedula,
  String uid,
) async {
  await db.collection('user').doc(uid).set({
    'name': name,
    'email': email,
    'password': password,
    'isadmin': isadmin,
    'id_carnet': id_carnet,
    'cedula': cedula,
  });
}

Future<void> deleteUser(String uid) async {
  await db.collection('user').doc(uid).delete();
}

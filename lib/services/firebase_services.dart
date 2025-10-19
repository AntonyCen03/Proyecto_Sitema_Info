import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getUser() async {
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
    print('Error in getUser(): $e\n$st'); // esto lo uso para depurar errores
    return [];
  }
  return users;
}

Future<void> addUser(
  String name,
  String email,
  String password,
  bool isadmin,
  int idCarnet,
  String cedula,
) async {
  await db.collection('user').add({
    'name': name,
    'email': email,
    'password': password,
    'isadmin': isadmin,
    'id_carnet': idCarnet,
    'cedula': cedula,
  });
}

Future<void> updateUser(
  String name,
  String email,
  String password,
  bool isadmin,
  int idCarnet,
  String cedula,
  String uid,
) async {
  await db.collection('user').doc(uid).set({
    'name': name,
    'email': email,
    'password': password,
    'isadmin': isadmin,
    'id_carnet': idCarnet,
    'cedula': cedula,
  });
}

Future<void> deleteUser(String uid) async {
  await db.collection('user').doc(uid).delete();
}

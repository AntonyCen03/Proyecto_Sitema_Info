import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUser() async {
  List user = [];

  QuerySnapshot querySnapshot = await db.collection('user').get();
  for (var doc in querySnapshot.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final person= {
      'name': data['name'],
      'uid': doc.id,
      'email': data['email'],
      'password': data['password'],
      'isadmin': data['isadmin'],
      'id_carnet': int.parse(data['id_carnet'].toString()),
      'cedula': data['cedula'],
    };
    user.add(person);
    }
  return user;
  }

  Future<void> addUser(String name, String email, String password, bool isadmin, String id_carnet, String cedula) async {
    await db.collection('user').add({
      'name': name,
      'email': email,
      'password': password,
      'isadmin': isadmin,
      'id_carnet': int.parse(id_carnet),
      'cedula': cedula,
    });
  }

  Future<void> updateUser(String name, String email, String password, bool isadmin, int id_carnet, String cedula, String uid) async {
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




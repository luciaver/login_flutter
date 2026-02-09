import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

String _filtroRol = 'todos';
bool _isLoading = false;

String get filtroRol => _filtroRol;
bool get isLoading => _isLoading;


void cambiarFiltroRol(String nuevoFiltro) {
_filtroRol = nuevoFiltro;
notifyListeners();
}

// Obtener stream de usuarios según filtro
Stream<QuerySnapshot> obtenerUsuarios() {
if (_filtroRol == 'todos') {
return _firestore.collection('usuarios').snapshots();
} else {
return _firestore
    .collection('usuarios')
    .where('rol', isEqualTo: _filtroRol)
    .snapshots();
}
}

// Agregar usuario
Future<bool> agregarUsuario({
required String nombre,
required String email,
required String password,
required String rol,
required int edad,
required String telefono,
String? posicion,
String? equipo,
}) async {
try {
_isLoading = true;
notifyListeners();

// Crear usuario en Authentication
UserCredential userCredential =
await _auth.createUserWithEmailAndPassword(
email: email,
password: password,
);

Map<String, dynamic> userData = {
'nombre': nombre,
'email': email,
'rol': rol,
'edad': edad,
'telefono': telefono,
};

// Agregar posición solo si es jugador
if (rol == 'jugador' && posicion != null) {
userData['posicion'] = posicion;
}

// Agregar equipo si existe
if (equipo != null && equipo.isNotEmpty) {
userData['equipo'] = equipo;
}

// Guardar datos en Firestore
await _firestore.collection('usuarios').doc(userCredential.user!.uid).set(userData);

_isLoading = false;
notifyListeners();
return true;
} catch (e) {
_isLoading = false;
notifyListeners();
return false;
}
}

// Editar usuario
Future<bool> editarUsuario({
required String userId,
required String nombre,
required String rol,
required int edad,
required String telefono,
String? posicion,
String? equipo,
}) async {
try {
_isLoading = true;
notifyListeners();

// Preparar datos
Map<String, dynamic> userData = {
'nombre': nombre,
'rol': rol,
'edad': edad,
'telefono': telefono,
};

// Agregar posición solo si es jugador
if (rol == 'jugador' && posicion != null) {
userData['posicion'] = posicion;
} else {
// Eliminar posición si ya no es jugador
userData['posicion'] = FieldValue.delete();
}

// Agregar equipo si existe
if (equipo != null && equipo.isNotEmpty) {
userData['equipo'] = equipo;
} else {
userData['equipo'] = FieldValue.delete();
}

await _firestore.collection('usuarios').doc(userId).update(userData);

_isLoading = false;
notifyListeners();
return true;
} catch (e) {
_isLoading = false;
notifyListeners();
return false;
}
}

// Eliminar usuario
Future<bool> eliminarUsuario(String userId) async {
try {
_isLoading = true;
notifyListeners();

await _firestore.collection('usuarios').doc(userId).delete();

_isLoading = false;
notifyListeners();
return true;
} catch (e) {
_isLoading = false;
notifyListeners();
return false;
}
}
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Escuchar cambios en el estado de autenticación
    _auth.authStateChanges().listen((User? user) async {
      print('DEBUG: Estado de autenticación cambió. Usuario: ${user?.uid}');
      
      if (user != null) {
        // Crear UserModel desde Firebase User
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
        _user.value = userModel;
        
        // Cargar datos adicionales desde Firestore
        try {
          print('DEBUG: Cargando datos desde Firestore para usuario: ${user.uid}');
          
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          
          if (doc.exists) {
            print('DEBUG: Documento encontrado en Firestore');
            print('DEBUG: Datos del documento: ${doc.data()}');
            
            // Crear UserModel con todos los datos de Firestore
            Map<String, dynamic> firestoreData = doc.data() as Map<String, dynamic>;
            UserModel completeUserModel = UserModel.fromJson(firestoreData);
            _user.value = completeUserModel;
            
            print('DEBUG: Usuario actualizado con datos completos: ${completeUserModel.toJson()}');
          } else {
            print('DEBUG: No se encontró documento en Firestore para el usuario');
            // Mantener el UserModel básico si no hay datos en Firestore
          }
        } catch (e) {
          print('DEBUG: Error al cargar datos desde Firestore: $e');
        }
      } else {
        _user.value = null;
        print('DEBUG: Usuario no autenticado');
      }
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> signUp(String email, String password, {
    String? nombre,
    String? apellido,
    String? telefono,
    String? direccion,
  }) async {
    try {
      isLoading.value = true;
      print('🔥 Iniciando registro con datos:');
      print('Email: $email');
      print('Nombre: $nombre');
      print('Apellido: $apellido');
      print('Teléfono: $telefono');
      print('Dirección: $direccion');
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Usuario creado en Firebase Auth: ${userCredential.user?.uid}');
      
      // Actualizar el perfil del usuario con el nombre completo
      if (nombre != null && apellido != null) {
        await userCredential.user?.updateDisplayName('$nombre $apellido');
        print('✅ DisplayName actualizado: $nombre $apellido');
      }
      
      // Guardar datos adicionales en Firestore con referencia explícita a la base de datos
      if (userCredential.user != null) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          displayName: nombre != null && apellido != null ? '$nombre $apellido' : null,
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          direccion: direccion,
        );
        
        print('🔥 Guardando en Firestore: ${userModel.toJson()}');
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());
            
        print('✅ Datos guardados en Firestore correctamente');
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ Error de Firebase Auth: ${e.code} - ${e.message}');
      return _getErrorMessage(e.code);
    } catch (e) {
      print('❌ Error general: $e');
      return 'Error inesperado: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Ocurrió un error. Intenta nuevamente';
    }
  }
}

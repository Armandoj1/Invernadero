import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invernadero/models/ia_control.dart';

class IAControlService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<IAControlModel?> getControl(String userId) async {
    try {
      final doc = await _firestore.collection('ia_control').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return IAControlModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener Control IA: $e');
      return null;
    }
  }

  Future<bool> saveControl(String userId, IAControlModel control) async {
    try {
      await _firestore
          .collection('ia_control')
          .doc(userId)
          .set(control.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error al guardar Control IA: $e');
      return false;
    }
  }
}
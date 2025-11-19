import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  static final CollectionReference _productRef =
      FirebaseFirestore.instance.collection('products');

  // CREATE
  static Future<void> addProduct(Map<String, dynamic> data) async {
    await _productRef.add(data);
  }

  // READ (real-time stream)
  static Stream<QuerySnapshot> getProducts() {
    return _productRef.snapshots();
  }

  // UPDATE
  static Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _productRef.doc(id).update(data);
  }

  // DELETE
  static Future<void> deleteProduct(String id) async {
    await _productRef.doc(id).delete();
  }
}

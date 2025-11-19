import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: Color(0xFF8B0000),
      ),
      drawer: const AdminDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // nanti ambil dari Firestore
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.receipt),
              title: Text('Order #00${index + 1}'),
              subtitle: const Text('Status: Diproses'),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Detail'),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_detail_page.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersCollection = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        centerTitle: true,
        backgroundColor: Color(0xFF8B0000),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada pesanan.'));
          }

          final orders = snapshot.data!.docs;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade50,
                child: Text(
                  'Total Pesanan: ${orders.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final orderId = order['orderId'] ?? '-';
                    final name = order['userName'] ?? '-';
                    final status = order['status'] ?? 'Pending';
                    final total = order['totalPrice'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Total: Rp$total'),
                        trailing: Chip(
                          label: Text(status),
                          backgroundColor: _getStatusColor(status),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailPage(orderId: orders[index].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade100;
      case 'processed':
        return Colors.blue.shade100;
      case 'canceled':
        return Colors.grey.shade300;
      default:
        return Colors.orange.shade100;
    }
  }
}

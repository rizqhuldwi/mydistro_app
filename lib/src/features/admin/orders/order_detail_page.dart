import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderDoc = FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        centerTitle: true,
        backgroundColor: Color(0xFF8B0000),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: orderDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data pesanan tidak ditemukan.'));
          }

          final order = snapshot.data!.data() as Map<String, dynamic>;
          final userName = order['userName'] ?? '-';
          final userEmail = order['userEmail'] ?? '-';
          final total = order['totalPrice'] ?? 0;
          final status = order['status'] ?? 'Pending';
          final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
          final createdAt = (order['createdAt'] as Timestamp?)?.toDate();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text('Nama Pemesan: $userName', style: const TextStyle(fontSize: 18)),
                Text('Email: $userEmail'),
                const SizedBox(height: 10),
                Chip(label: Text('Status: $status')),
                const Divider(height: 30),

                const Text(
                  'Produk Dipesan:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...items.map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item['name'] ?? 'Produk'),
                      subtitle: Text('Qty: ${item['qty']} x Rp${item['price']}'),
                    ),
                  );
                }),

                const Divider(height: 30),
                Text('Total: Rp$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (createdAt != null)
                  Text('Dipesan pada: $createdAt', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class OrderDetailPage extends StatefulWidget {
//   final String orderId;

//   const OrderDetailPage({super.key, required this.orderId});

//   @override
//   State<OrderDetailPage> createState() => _OrderDetailPageState();
// }

// class _OrderDetailPageState extends State<OrderDetailPage> {
//   final _firestore = FirebaseFirestore.instance;
//   String? _selectedStatus;
//   bool _isUpdating = false;

//   final List<String> _statusList = [
//     'Pending',
//     'Processed',
//     'Completed',
//     'Canceled',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final orderDoc = _firestore.collection('orders').doc(widget.orderId);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detail Pesanan'),
//         centerTitle: true,
//         backgroundColor: Colors.redAccent,
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: orderDoc.get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Data pesanan tidak ditemukan.'));
//           }

//           final order = snapshot.data!.data() as Map<String, dynamic>;
//           final userName = order['userName'] ?? '-';
//           final userEmail = order['userEmail'] ?? '-';
//           final total = order['totalPrice'] ?? 0;
//           final status = order['status'] ?? 'Pending';
//           final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
//           final createdAt = (order['createdAt'] as Timestamp?)?.toDate();

//           _selectedStatus ??= status;

//           return Padding(
//             padding: const EdgeInsets.all(20),
//             child: ListView(
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.person, color: Colors.redAccent),
//                     const SizedBox(width: 8),
//                     Text(
//                       userName,
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 Text(userEmail),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Total: Rp$total',
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 if (createdAt != null)
//                   Text('Tanggal Pesanan: $createdAt',
//                       style: const TextStyle(color: Colors.grey)),
//                 const Divider(height: 30),

//                 // STATUS SECTION
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Status Pesanan:',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     DropdownButton<String>(
//                       value: _selectedStatus,
//                       items: _statusList.map((status) {
//                         return DropdownMenuItem<String>(
//                           value: status,
//                           child: Text(status),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedStatus = value!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),

//                 if (_isUpdating)
//                   const Center(child: CircularProgressIndicator())
//                 else
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       if (_selectedStatus == null) return;
//                       setState(() => _isUpdating = true);

//                       await orderDoc.update({
//                         'status': _selectedStatus,
//                         'updatedAt': FieldValue.serverTimestamp(),
//                       });

//                       setState(() => _isUpdating = false);

//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Status pesanan diubah menjadi $_selectedStatus'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.redAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     icon: const Icon(Icons.save),
//                     label: const Text('Simpan Perubahan'),
//                   ),
//                 const Divider(height: 30),

//                 const Text(
//                   'Produk Dipesan:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 ...items.map((item) {
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     child: ListTile(
//                       title: Text(item['name'] ?? 'Produk'),
//                       subtitle: Text('Qty: ${item['qty']} x Rp${item['price']}'),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

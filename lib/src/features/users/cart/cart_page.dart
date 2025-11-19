import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Kaos Premium', 'price': 120000, 'qty': 1},
    {'name': 'Celana Chino', 'price': 150000, 'qty': 2},
  ];

  double get total => cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['qty']).toDouble());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keranjang Belanja',
              style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold,
              color: Color(0xFF8B0000), fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle:
                          Text('Rp ${item['price']} x ${item['qty']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF8B0000)),
                        onPressed: () {
                          setState(() => cartItems.removeAt(index));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B0000)),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

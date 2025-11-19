import 'package:flutter/material.dart';
import 'package:projek/src/features/admin/users/user_list_page.dart';
import '../widgets/admin_drawer.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        backgroundColor: Colors.redAccent,
      ),
      drawer: const AdminDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // nanti ambil dari Firestore
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('User ${index + 1}'),
              subtitle: const Text('user@email.com'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserListPage()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

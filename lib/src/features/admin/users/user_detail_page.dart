import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail User'),
        centerTitle: true,
        backgroundColor: Color(0xFF8B0000),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data user tidak ditemukan.'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;
          final name = user['name'] ?? '-';
          final email = user['email'] ?? '-';
          final role = user['role'] ?? '-';
          final phone = user['phoneNumber'] ?? '-';
          final address = user['address'] ?? '-';
          final photoUrl = user['photoUrl'] ?? '';
          final createdAt = (user['createdAt'] as Timestamp?)?.toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(email, style: const TextStyle(fontSize: 16)),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Role'),
                  subtitle: Text(role),
                ),
                if (createdAt != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Dibuat pada'),
                    subtitle: Text(createdAt.toString()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

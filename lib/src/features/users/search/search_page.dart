import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<String> items = [
    'Kaos Premium',
    'Celana Chino',
    'Sepatu Vans',
    'Hoodie Streetwear',
  ];

  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = items
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul MyDistroApp
              const Text(
                'MyDistroApp',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  fontSize: 28,
                  color: Color(0xFF8B0000), // Merah maroon
                ),
              ),
              const SizedBox(height: 32),

              // Kotak pencarian
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF8B0000), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => query = value),
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Cari Produk',
                          hintStyle: TextStyle(
                            color: Color(0xFF8B0000),
                            letterSpacing: 1.2,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.search,
                        color: const Color(0xFF8B0000),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Hasil pencarian
              if (query.isNotEmpty)
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                title: Text(filteredItems[index]),
                                subtitle: const Text("Rp 120.000"),
                                leading: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Color(0xFF8B0000),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

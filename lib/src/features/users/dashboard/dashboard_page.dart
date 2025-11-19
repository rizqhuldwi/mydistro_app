import 'package:flutter/material.dart';
import '../cart/cart_page.dart';
import '../profile/profil_page.dart';
import '../search/search_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int selectedTab = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Map<String, dynamic>> products = [
    {
      "nama": "Kaos Sablon Premium",
      "harga": "Rp 120.000",
      "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761494403/scaled_1000033681_jle1eb.jpg",
      "deskripsi": "Kaos sablon premium dengan bahan katun halus dan desain modern. Nyaman dipakai dan cocok untuk semua gaya kasual.",
    },
    {
      "nama": "Kaos Hitam Polos",
      "harga": "Rp 95.000",
      "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761494403/scaled_1000033681_jle1eb.jpg",
      "deskripsi": "Kaos hitam polos berbahan 100% cotton combed. Adem dan ringan untuk penggunaan sehari-hari.",
    },
    {
      "nama": "Kaos Hitam Oversized",
      "harga": "Rp 130.000",
      "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761494403/scaled_1000033681_jle1eb.jpg",
      "deskripsi": "Kaos putih oversized dengan potongan longgar dan bahan lembut. Cocok untuk gaya streetwear.",
    },
    {
      "nama": "Kaos Distro Limited Edition",
      "harga": "Rp 150.000",
      "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761494403/scaled_1000033681_jle1eb.jpg",
      "deskripsi": "Edisi terbatas! Kaos distro dengan sablon tebal dan detail jahitan rapi. Jumlah sangat terbatas.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const SearchPage(),
      const CartPage(),
      const ProfilPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8B0000),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ==========================
  // HALAMAN HOME DAN KATEGORI
  // ==========================
  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'MyDistroApp',
                    style: TextStyle(
                      color: Color(0xFF8B0000),
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Beranda & Kategori
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => selectedTab = 0),
                    child: Text(
                      'Beranda',
                      style: TextStyle(
                        fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                        color: selectedTab == 0 ? Colors.black : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => setState(() => selectedTab = 1),
                    child: Text(
                      'Kategori',
                      style: TextStyle(
                        fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                        color: selectedTab == 1 ? Colors.black : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            selectedTab == 0 ? _buildBerandaContent() : _buildKategoriContent(),
          ],
        ),
      ),
    );
  }

  // ==================
  // TAMPILAN BERANDA
  // ==================
  Widget _buildBerandaContent() {
    return Column(
      children: [
        // Banner Carousel
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Indicator titik
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF8B0000), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
          ],
        ),

        const SizedBox(height: 16),

        // Grid produk
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product["gambar"],
                        fit: BoxFit.cover,
                        height: 140,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product["nama"],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product["harga"],
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================
  // TAMPILAN KATEGORI
  // ==================
  Widget _buildKategoriContent() {
    final kategoriList = [
      {
        "nama": "Kaos",
        "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761494403/scaled_1000033681_jle1eb.jpg",
      },
      {
        "nama": "Celana",
        "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761495963/scaled_1000033679_vfobeq.jpg",
      },
      {
        "nama": "Sepatu",
        "gambar": "https://res.cloudinary.com/mydistroapp/image/upload/v1761504946/scaled_1000033680_cza3vo.jpg",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: kategoriList.map((kategori) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    kategori['nama']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    kategori['gambar']!,
                    width: 160,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==========================
// HALAMAN DETAIL PRODUK
// ==========================
class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product["nama"]),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product["gambar"],
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product["nama"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product["harga"],
              style: const TextStyle(fontSize: 18, color: Color(0xFF8B0000), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              product["deskripsi"],
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const CartPage())
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Tambahkan ke Keranjang", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

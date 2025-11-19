import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_edit_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId, required Map<String, dynamic> productData, required QueryDocumentSnapshot<Object?> product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _productData;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        setState(() {
          _productData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk tidak ditemukan.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data produk: $e')),
      );
    }
  }

  Future<void> _navigateToEdit() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditPage(productId: widget.productId),
      ),
    );

    if (updated == true) {
      await _loadProductData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data produk diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content:
            const Text('Apakah kamu yakin ingin menghapus produk ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B0000)),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .delete();

        if (mounted) {
          Navigator.pop(context, true); // kembali ke list dan trigger refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus produk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B0000),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.white,
            tooltip: 'Edit Produk',
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            tooltip: 'Hapus Produk',
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productData == null
              ? const Center(child: Text('Produk tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_productData!['imageUrl'] != null &&
                          _productData!['imageUrl']!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _productData!['imageUrl'],
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 250,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 60),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        _productData!['nama'] ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${( _productData!['harga'] ?? 0 ).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if ((_productData!['kategori'] ?? '').isNotEmpty)
                            _buildChip('Kategori: ${_productData!['kategori']}'),
                          if ((_productData!['ukuran'] ?? '').isNotEmpty)
                            _buildChip('Ukuran: ${_productData!['ukuran']}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deskripsi:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _productData!['deskripsi'] ?? '-',
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B0000)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8B0000),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

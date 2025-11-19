import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductEditPage extends StatefulWidget {
  final String productId;
  const ProductEditPage({super.key, required this.productId});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _ukuranController = TextEditingController();

  bool _isLoading = false;
  String? _currentImageUrl;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _namaController.text = data['nama'] ?? '';
          _deskripsiController.text = data['deskripsi'] ?? '';
          _hargaController.text = data['harga']?.toString() ?? '';
          _kategoriController.text = data['kategori'] ?? '';
          _ukuranController.text = data['ukuran'] ?? '';
          _currentImageUrl = data['imageUrl'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data produk: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImageFile = File(picked.path));
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'mydistroapp';
    const uploadPreset = 'mydistroapp';
    const apiUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(resBody);
      return data['secure_url'];
    } else {
      debugPrint('Upload error: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _currentImageUrl;

      // Jika user memilih foto baru → upload ke Cloudinary
      if (_newImageFile != null) {
        final uploadedUrl = await _uploadToCloudinary(_newImageFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'nama': _namaController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'harga': double.tryParse(_hargaController.text.trim()) ?? 0,
        'kategori': _kategoriController.text.trim(),
        'ukuran': _ukuranController.text.trim(),
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate produk: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _kategoriController.dispose();
    _ukuranController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        backgroundColor: Color(0xFF8B0000),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                              image: _newImageFile != null
                                  ? DecorationImage(
                                      image: FileImage(_newImageFile!),
                                      fit: BoxFit.cover)
                                  : (_currentImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(_currentImageUrl!),
                                          fit: BoxFit.cover)
                                      : null),
                            ),
                            child: _currentImageUrl == null &&
                                    _newImageFile == null
                                ? const Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama produk wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration:
                          const InputDecoration(labelText: 'Deskripsi Produk'),
                      validator: (v) =>
                          v!.isEmpty ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hargaController,
                      decoration:
                          const InputDecoration(labelText: 'Harga Produk'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? 'Harga wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _kategoriController,
                      decoration:
                          const InputDecoration(labelText: 'Kategori Produk'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ukuranController,
                      decoration:
                          const InputDecoration(labelText: 'Ukuran Produk'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _updateProduct,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

const String cloudinaryCloudName = 'mydistroapp';
const String cloudinaryUploadPreset = 'mydistroapp';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _uploadedImageUrl;

  bool _isSaving = false;

  final List<String> _kategoriList = ['Kaos', 'Kemeja', 'Hoodie', 'Celana', 'Sepatu'];
  final Map<String, List<String>> _ukuranByKategori = {
    'Kaos': ['S', 'M', 'L', 'XL'],
    'Kemeja': ['S', 'M', 'L', 'XL'],
    'Hoodie': ['S', 'M', 'L', 'XL'],
    'Celana': ['27', '28', '29', '30', '31', '32', '33', '34', '36'],
    'Sepatu': ['38', '39', '40', '41', '42', '43', '44'],
  };

  String? _selectedKategori;
  String? _selectedUkuran;

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = picked;
        });
      }
    } catch (e) {
      debugPrint('pick image error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<String> _uploadImageToCloudinary(XFile image) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = cloudinaryUploadPreset;

    final bytes = await image.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: image.name);
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload gagal: ${response.statusCode} ${response.reasonPhrase}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final secureUrl = data['secure_url'] as String?;
    if (secureUrl == null) throw Exception('URL tidak ditemukan');
    return secureUrl;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null && _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan upload foto produk terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imageUrl = _uploadedImageUrl ?? '';
      if (_selectedImage != null && imageUrl.isEmpty) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
        _uploadedImageUrl = imageUrl;
      }

      final double harga = double.tryParse(_hargaController.text.replaceAll(',', '.')) ?? 0.0;
      await FirebaseFirestore.instance.collection('products').add({
        'nama': _namaController.text.trim(),
        'harga': harga,
        'deskripsi': _deskripsiController.text.trim(),
        'kategori': _selectedKategori ?? '-',
        'ukuran': _selectedUkuran ?? '-',
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil disimpan')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('save product error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF8B0000)),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF8B0000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF8B0000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tambah Produk Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lengkapi informasi produk di bawah ini',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B0000).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: Color(0xFF8B0000),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Foto Produk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Image Preview or Placeholder
                            if (_selectedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: kIsWeb
                                      ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                      : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                                ),
                              )
                            else
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Belum ada foto',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Image Picker Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.photo_library, size: 18),
                                    label: const Text('Galeri'),
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.grey[800],
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.camera_alt, size: 18),
                                    label: const Text('Kamera'),
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B0000),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Product Info Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B0000).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF8B0000),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Informasi Produk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Nama Produk
                            TextFormField(
                              controller: _namaController,
                              decoration: _buildInputDecoration('Nama Produk', Icons.label_outline),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),

                            // Harga
                            TextFormField(
                              controller: _hargaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _buildInputDecoration('Harga (Rp)', Icons.attach_money),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                                final n = double.tryParse(v.replaceAll(',', '.'));
                                if (n == null) return 'Masukkan angka valid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Deskripsi
                            TextFormField(
                              controller: _deskripsiController,
                              maxLines: 3,
                              decoration: _buildInputDecoration('Deskripsi', Icons.description_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B0000).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.category_outlined,
                                    color: Color(0xFF8B0000),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Kategori & Ukuran',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Kategori
                            DropdownButtonFormField<String>(
                              value: _selectedKategori,
                              decoration: _buildInputDecoration('Kategori', Icons.category_outlined),
                              items: _kategoriList.map((kategori) {
                                return DropdownMenuItem(
                                  value: kategori,
                                  child: Text(kategori),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedKategori = value;
                                  _selectedUkuran = null;
                                });
                              },
                              validator: (v) => (v == null || v.isEmpty) ? 'Pilih kategori' : null,
                            ),
                            const SizedBox(height: 16),

                            // Ukuran
                            if (_selectedKategori != null)
                              DropdownButtonFormField<String>(
                                value: _selectedUkuran,
                                decoration: _buildInputDecoration('Ukuran', Icons.straighten),
                                items: (_ukuranByKategori[_selectedKategori] ?? []).map((ukuran) {
                                  return DropdownMenuItem(
                                    value: ukuran,
                                    child: Text(ukuran),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedUkuran = v),
                                validator: (v) => (v == null || v.isEmpty) ? 'Pilih ukuran' : null,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Simpan Produk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

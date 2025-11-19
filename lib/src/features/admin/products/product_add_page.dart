import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:projek/src/features/admin/products/product_detail_page.dart';

// --------------------------------------------------
// ATTENTION: configure these values before running
// - CLOUDINARY_CLOUD_NAME
// - CLOUDINARY_UPLOAD_PRESET (unsigned preset)
// You can also refactor these to use environment variables.
// --------------------------------------------------
const String CLOUDINARY_CLOUD_NAME = 'mydistroapp';
const String CLOUDINARY_UPLOAD_PRESET = 'mydistroapp'; // unsigned preset

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

  // contoh kategori & ukuran
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
    if (CLOUDINARY_CLOUD_NAME.startsWith('<') || CLOUDINARY_UPLOAD_PRESET.startsWith('<')) {
      throw Exception('Please configure CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET in the file.');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload');

    final request = http.MultipartRequest('POST', uri);

    // attach upload preset
    request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;

    // The XFile may or may not have a valid path (web vs mobile). Use bytes safe approach.
    final bytes = await image.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: image.name);
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload gagal: ${response.statusCode} ${response.reasonPhrase} ${response.body}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final secureUrl = data['secure_url'] as String?;
    if (secureUrl == null) throw Exception('Field secure_url tidak ditemukan di response Cloudinary.');
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
    // Upload foto ke Cloudinary (hanya ini yang dikirim keluar)
    String imageUrl = _uploadedImageUrl ?? '';
    if (_selectedImage != null && imageUrl.isEmpty) {
      imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      _uploadedImageUrl = imageUrl;
    }

    // Simpan data produk ke Firestore
    final double harga = double.tryParse(_hargaController.text.replaceAll(',', '.')) ?? 0.0;
    await FirebaseFirestore.instance.collection('products').add({
      'nama': _namaController.text.trim(),
      'harga': harga,
      'deskripsi': _deskripsiController.text.trim(),
      'kategori': _selectedKategori ?? '-',
      'ukuran': _selectedUkuran ?? '-',
      'imageUrl': imageUrl, // URL Cloudinary disimpan di sini
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Color(0xFF8B0000),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Harga
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null) return 'Masukkan angka valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
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
              const SizedBox(height: 12),

              // Ukuran (dynamic)
              if (_selectedKategori != null)
                DropdownButtonFormField<String>(
                  value: _selectedUkuran,
                  decoration: const InputDecoration(
                    labelText: 'Ukuran',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  items: (_ukuranByKategori[_selectedKategori] ?? ['-']).map((ukuran) {
                    return DropdownMenuItem(
                      value: ukuran,
                      child: Text(ukuran),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedUkuran = v),
                  validator: (v) => (v == null || v.isEmpty) ? 'Pilih ukuran' : null,
                ),

              const SizedBox(height: 16),

              // Image picker
              Text('Foto Produk', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pilih dari galeri'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ambil foto'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // preview
              if (_selectedImage != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preview:'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                            : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_uploadedImageUrl != null)
                      Text('Sudah di-upload: $_uploadedImageUrl', style: const TextStyle(fontSize: 12)),
                  ],
                ),

              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// kIsWeb constant helper
bool get kIsWeb {
  // avoid importing flutter foundation to keep this file simple
  // A quick runtime workaround: if Platform is not available, assume web false
  try {
    return identical(0, 0.0);
  } catch (_) {
    return false;
  }
}

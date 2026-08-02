import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../domain/entities/category_entity.dart';
import 'providers/product_provider.dart';
import '../../../core/widgets/custom_dialog.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  static const Color maroonColor = Color(0xFF5D1A1A);
  static const Color redMain = Color(0xFFB40001);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  int? _selectedCategoryId;
  List<CategoryEntity> _categories = [];
  final Set<String> _selectedSizes = {'S', 'M', 'L', 'XL'};
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final productProvider = context.read<ProductProvider>();
      await productProvider.loadCategories();
      if (!mounted) return;
      final categories = productProvider.categories;
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInitializing = false);
      _showMessage('Gagal memuat kategori: $e');
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSizes.isEmpty) {
      AppDialog.showError(context, title: 'Ukuran Belum Dipilih', message: 'Silakan pilih minimal satu ukuran untuk produk.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await productProvider.uploadImage(_imageFile!);
      }

      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());

      await productProvider.addProduct(
        categoryId: _selectedCategoryId,
        name: _nameController.text.trim(),
        price: price,
        stock: stock,
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        sizes: _selectedSizes.toList(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      await AppDialog.showSuccess(
        context,
        title: 'Produk Berhasil Ditambahkan',
        message: 'Produk baru Anda telah berhasil disimpan dan siap dijual.',
        onOk: () => Navigator.pop(context, true),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppDialog.showError(
        context,
        title: 'Gagal Menyimpan Produk',
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator(color: redMain))
                : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _imagePicker(),
                              const SizedBox(height: 24),
                              _buildField(
                                label: 'Nama Produk',
                                hint: 'Contoh: Kemeja Oversize Coklat',
                                icon: Iconsax.box,
                                controller: _nameController,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Nama produk wajib diisi'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              _categoryDropdown(),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      label: 'Harga (Rp)',
                                      hint: '150000',
                                      icon: Iconsax.money,
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Harga wajib diisi';
                                        }
                                        if (int.tryParse(v) == null ||
                                            int.parse(v) <= 0) {
                                          return 'Harga tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildField(
                                      label: 'Stok',
                                      hint: '100',
                                      icon: Iconsax.box_1,
                                      controller: _stockController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Stok wajib diisi';
                                        }
                                        if (int.tryParse(v) == null ||
                                            int.parse(v) < 0) {
                                          return 'Stok tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _buildField(
                                label: 'Deskripsi',
                                hint: 'Jelaskan detail produk...',
                                icon: Iconsax.document_text,
                                controller: _descriptionController,
                                maxLines: 4,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Deskripsi wajib diisi'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              _sizeSelector(),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: maroonColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        maroonColor.withValues(alpha: 0.6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Simpan Produk',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [redMain, Color(0xFF7A0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Produk',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lengkapi informasi produk baru',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.box_add, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: maroonColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.gallery_add,
                    size: 48,
                    color: maroonColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap untuk upload foto produk',
                    style: GoogleFonts.outfit(
                      color: maroonColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Format JPG/PNG, maks. 1200px',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: maroonColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              isExpanded: true,
              icon: Icon(Iconsax.arrow_down_1,
                  color: maroonColor.withValues(alpha: 0.5), size: 18),
              style: GoogleFonts.outfit(color: maroonColor),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sizeSelector() {
    const sizes = ['S', 'M', 'L', 'XL'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ukuran Tersedia',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: maroonColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: sizes.map((size) {
            final selected = _selectedSizes.contains(size);
            return FilterChip(
              label: Text(size, style: GoogleFonts.outfit()),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedSizes.add(size);
                  } else {
                    _selectedSizes.remove(size);
                  }
                });
              },
              selectedColor: maroonColor.withValues(alpha: 0.15),
              checkmarkColor: maroonColor,
              labelStyle: GoogleFonts.outfit(
                color: selected ? maroonColor : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: selected
                    ? maroonColor.withValues(alpha: 0.4)
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: maroonColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: GoogleFonts.outfit(color: maroonColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              color: maroonColor.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(
              icon,
              color: maroonColor.withValues(alpha: 0.5),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: maroonColor.withValues(alpha: 0.25),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

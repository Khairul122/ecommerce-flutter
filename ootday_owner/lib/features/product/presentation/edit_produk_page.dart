import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../domain/entities/category_entity.dart';
import '../domain/entities/product_entity.dart';
import 'providers/product_provider.dart';
import '../../../core/widgets/custom_dialog.dart';

/// Edit produk: hanya field yang didukung `PUT /owner/products/{id}`
/// (name/category/price/stock/description/status). Backend belum mendukung
/// mengganti foto/varian lewat endpoint ini — itu tetap lewat "Tambah Produk".
class EditProdukPage extends StatefulWidget {
  final ProductEntity product;

  const EditProdukPage({super.key, required this.product});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  static const Color maroonColor = Color(0xFF5D1A1A);
  static const Color redMain = Color(0xFFB40001);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  int? _selectedCategoryId;
  late String _status;
  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.round().toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _selectedCategoryId = widget.product.categoryId;
    _status = widget.product.status;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.categories.isEmpty) {
        await productProvider.loadCategories();
      }
      if (!mounted) return;
      setState(() {
        _categories = productProvider.categories;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());

      await context.read<ProductProvider>().updateProduct(widget.product.id, {
        'name': _nameController.text.trim(),
        if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
        'price': price,
        'stock': stock,
        'description': _descriptionController.text.trim(),
        'status': _status,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);
      await AppDialog.showSuccess(
        context,
        title: 'Produk Diperbarui',
        message: 'Perubahan produk berhasil disimpan.',
        onOk: () => Navigator.pop(context, true),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppDialog.showError(context, title: 'Gagal Menyimpan', message: e.toString());
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
                          _buildField(
                            label: 'Nama Produk',
                            icon: Iconsax.box,
                            controller: _nameController,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Nama produk wajib diisi' : null,
                          ),
                          const SizedBox(height: 18),
                          _categoryDropdown(),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  label: 'Harga (Rp)',
                                  icon: Iconsax.money,
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                                    if (int.tryParse(v) == null || int.parse(v) <= 0) {
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
                                  icon: Iconsax.box_1,
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Stok wajib diisi';
                                    if (int.tryParse(v) == null || int.parse(v) < 0) {
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
                            icon: Iconsax.document_text,
                            controller: _descriptionController,
                            maxLines: 4,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
                          ),
                          const SizedBox(height: 18),
                          _statusSwitch(),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroonColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: maroonColor.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Simpan Perubahan',
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
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
                child: Text(
                  'Edit Produk',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _categories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
              isExpanded: true,
              icon: Icon(Iconsax.arrow_down_1, color: maroonColor.withValues(alpha: 0.5), size: 18),
              style: GoogleFonts.outfit(color: maroonColor),
              items: _categories.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusSwitch() {
    final active = _status == 'active';
    return Row(
      children: [
        Expanded(
          child: Text(
            active ? 'Produk aktif (tampil ke pembeli)' : 'Produk nonaktif (disembunyikan)',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor),
          ),
        ),
        Switch(
          value: active,
          activeColor: redMain,
          onChanged: (v) => setState(() => _status = v ? 'active' : 'inactive'),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
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
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: GoogleFonts.outfit(color: maroonColor),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: maroonColor.withValues(alpha: 0.5), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: maroonColor.withValues(alpha: 0.25)),
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

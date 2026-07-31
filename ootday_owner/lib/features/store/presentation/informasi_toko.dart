import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/store_provider.dart';

class InformasiToko extends StatefulWidget {
  const InformasiToko({super.key});

  @override
  State<InformasiToko> createState() => _InformasiTokoState();
}

class _InformasiTokoState extends State<InformasiToko> {
  final Color redMain = const Color(0xFFB40001);
  final Color darkRed = const Color(0xFF7A0000);

  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _loadStore() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<StoreProvider>();
      await provider.loadStore();
      final store = provider.store;
      _namaTokoController.text = store?.storeName ?? '';
      _deskripsiController.text = store?.description ?? '';
      _alamatController.text = store?.address ?? '';
      _whatsappController.text = store?.phone ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat informasi toko: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context.read<StoreProvider>().updateStore(
            storeName: _namaTokoController.text.trim(),
            description: _deskripsiController.text.trim(),
            address: _alamatController.text.trim(),
            phone: _whatsappController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informasi toko berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _inputField(
                            label: 'Nama toko',
                            controller: _namaTokoController,
                          ),
                          const SizedBox(height: 16),
                          _inputField(
                            label: 'Deskripsi Toko',
                            controller: _deskripsiController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _inputField(
                            label: 'Alamat',
                            controller: _alamatController,
                          ),
                          const SizedBox(height: 16),
                          _inputField(
                            label: 'WhatsApp',
                            controller: _whatsappController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 40),
                          _saveButton(),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [redMain, darkRed],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            const Expanded(
              child: Text(
                'Informasi Toko',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 40), // Balance untuk centering
          ],
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: redMain,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
    return Center(
      child: SizedBox(
        width: 180,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: redMain,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

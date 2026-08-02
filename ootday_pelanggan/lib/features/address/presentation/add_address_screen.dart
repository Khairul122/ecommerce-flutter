import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/address_provider.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? address;
  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _provinceController;
  late TextEditingController _zipController;
  late TextEditingController _streetController;
  late TextEditingController _detailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.address?['phone'] ?? '');
    
    // Parsing fullAddress (format tulis: "jalan\nprovinsi kodepos\ndetail")
    // untuk mengembalikan ke field masing-masing saat mode edit.
    String full = widget.address?['fullAddress'] ?? '';
    List<String> lines = full.split('\n');
    _streetController = TextEditingController(text: lines.isNotEmpty ? lines[0] : '');

    String province = '';
    String zip = '';
    if (lines.length > 1) {
      final lastSpace = lines[1].lastIndexOf(' ');
      if (lastSpace != -1) {
        province = lines[1].substring(0, lastSpace);
        zip = lines[1].substring(lastSpace + 1);
      } else {
        province = lines[1];
      }
    }
    _provinceController = TextEditingController(text: province);
    _zipController = TextEditingController(text: zip);
    _detailController = TextEditingController(text: lines.length > 2 ? lines.sublist(2).join('\n') : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _zipController.dispose();
    _streetController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress(bool isMain) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    String fullAddr = '${_streetController.text}\n${_provinceController.text} ${_zipController.text}\n${_detailController.text}';
    final name = _nameController.text;
    final phone = _phoneController.text;

    try {
      final provider = context.read<AddressProvider>();
      if (widget.address != null && widget.address!['id'] != null) {
        // Update existing
        await provider.updateAddress(
          id: widget.address!['id'].toString(),
          name: name,
          phone: phone,
          fullAddress: fullAddr,
          isMain: isMain,
        );
      } else {
        // Add new
        await provider.addAddress(
          name: name,
          phone: phone,
          fullAddress: fullAddr,
          isMain: isMain,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan alamat: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color accentMaroon = Color(0xFFB01D1D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.address != null ? 'Edit Alamat' : 'Tambah alamat',
          style: GoogleFonts.outfit(color: maroonColor, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: INFORMASI PENERIMA
            _buildSectionTitle('Informasi Penerima', maroonColor),
            _buildInputField('*Nama', _nameController, maroonColor),
            _buildInputField('*No.Handphone', _phoneController, maroonColor),
            
            const SizedBox(height: 10),
            
            // SECTION: ALAMAT PENERIMA
            _buildSectionTitle('Alamat Penerima', maroonColor),
            _buildInputField('*Provinsi, Kota/Kabupaten & Kecamatan', _provinceController, maroonColor),
            _buildInputField('*Kode Pos', _zipController, maroonColor),
            _buildInputField('*Nama jalan', _streetController, maroonColor),
            _buildInputField('*Detail', _detailController, maroonColor),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildBottomButton('Simpan', accentMaroon, () => _saveAddress(false)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildBottomButton('Simpan sebagai alamat utama', accentMaroon, () => _saveAddress(true)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

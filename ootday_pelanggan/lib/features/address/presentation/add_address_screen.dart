import 'dart:async';

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
  late TextEditingController _districtSearchController;
  late TextEditingController _zipController;
  late TextEditingController _streetController;
  late TextEditingController _detailController;
  bool _isSaving = false;

  int? _districtId;
  String? _districtName;
  String? _cityName;
  String? _provinceName;

  Timer? _debounce;
  List<Map<String, dynamic>> _districtResults = [];
  bool _searchingDistrict = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.address?['phone'] ?? '');

    _districtId = widget.address?['districtId'] as int?;
    _districtName = widget.address?['districtName']?.toString();
    _cityName = widget.address?['cityName']?.toString();
    _provinceName = widget.address?['provinceName']?.toString();
    _districtSearchController = TextEditingController(text: _districtLabel() ?? '');
    _zipController = TextEditingController(text: widget.address?['postalCode']?.toString() ?? '');

    // Parsing fullAddress (format tulis: "jalan\ndetail") untuk mengembalikan
    // ke field masing-masing saat mode edit.
    String full = widget.address?['fullAddress'] ?? '';
    List<String> lines = full.split('\n');
    _streetController = TextEditingController(text: lines.isNotEmpty ? lines[0] : '');
    _detailController = TextEditingController(text: lines.length > 1 ? lines.sublist(1).join('\n') : '');
  }

  String? _districtLabel() {
    if (_districtName == null) return null;
    return [_districtName, _cityName, _provinceName].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _districtSearchController.dispose();
    _zipController.dispose();
    _streetController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _onDistrictSearchChanged(String keyword) {
    _debounce?.cancel();
    if (_districtName != null && keyword != _districtLabel()) {
      // User mengetik ulang setelah sebelumnya memilih -> reset pilihan lama.
      _districtId = null;
      _districtName = null;
      _cityName = null;
      _provinceName = null;
    }
    if (keyword.trim().length < 3) {
      setState(() => _districtResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searchingDistrict = true);
      try {
        final results = await context.read<AddressProvider>().searchDestinations(keyword.trim());
        if (mounted) setState(() => _districtResults = results);
      } catch (_) {
        if (mounted) setState(() => _districtResults = []);
      } finally {
        if (mounted) setState(() => _searchingDistrict = false);
      }
    });
  }

  void _selectDistrict(Map<String, dynamic> item) {
    setState(() {
      _districtId = item['id'] is int ? item['id'] as int : int.tryParse(item['id'].toString());
      _districtName = item['district_name']?.toString() ?? item['subdistrict_name']?.toString();
      _cityName = item['city_name']?.toString();
      _provinceName = item['province_name']?.toString();
      _districtSearchController.text = _districtLabel() ?? '';
      if ((item['zip_code'] ?? item['postal_code']) != null) {
        _zipController.text = (item['zip_code'] ?? item['postal_code']).toString();
      }
      _districtResults = [];
    });
  }

  Future<void> _saveAddress(bool isMain) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    String fullAddr = '${_streetController.text}\n${_detailController.text}';
    final name = _nameController.text;
    final phone = _phoneController.text;

    try {
      final provider = context.read<AddressProvider>();
      if (widget.address != null && widget.address!['id'] != null) {
        await provider.updateAddress(
          id: widget.address!['id'].toString(),
          name: name,
          phone: phone,
          fullAddress: fullAddr,
          isMain: isMain,
          districtId: _districtId,
          districtName: _districtName,
          cityName: _cityName,
          provinceName: _provinceName,
          postalCode: _zipController.text.isEmpty ? null : _zipController.text,
        );
      } else {
        await provider.addAddress(
          name: name,
          phone: phone,
          fullAddress: fullAddr,
          isMain: isMain,
          districtId: _districtId,
          districtName: _districtName,
          cityName: _cityName,
          provinceName: _provinceName,
          postalCode: _zipController.text.isEmpty ? null : _zipController.text,
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
            _buildDistrictField(maroonColor),
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

  Widget _buildDistrictField(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '*Provinsi, Kota/Kabupaten & Kecamatan',
            style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          TextField(
            controller: _districtSearchController,
            onChanged: _onDistrictSearchChanged,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Ketik nama kecamatan (min. 3 huruf)',
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
              suffixIcon: _searchingDistrict
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          if (_districtResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _districtResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _districtResults[index];
                  final label = [
                    item['district_name'] ?? item['subdistrict_name'],
                    item['city_name'],
                    item['province_name'],
                  ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
                  return ListTile(
                    dense: true,
                    title: Text(label, style: GoogleFonts.outfit(fontSize: 13)),
                    onTap: () => _selectDistrict(item),
                  );
                },
              ),
            ),
        ],
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

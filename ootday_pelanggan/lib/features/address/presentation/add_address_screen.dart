import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../domain/entities/region_entity.dart';
import '../domain/usecases/address_usecases.dart';
import 'providers/address_provider.dart';
import '../../../../core/usecase.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? address;
  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _detailController;

  List<ProvinceEntity> _provinces = [];
  List<CityEntity> _cities = [];

  ProvinceEntity? _selectedProvince;
  CityEntity? _selectedCity;

  bool _isLoadingRegions = false;
  bool _isLoadingCities = false;
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
    _streetController = TextEditingController(text: widget.address?['fullAddress'] ?? '');
    _detailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProvinces());
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingRegions = true);
    try {
      final getProvincesUseCase = context.read<GetProvincesUseCase>();
      final result = await getProvincesUseCase(const NoParams());
      if (mounted) {
        setState(() {
          _provinces = result;
          _isLoadingRegions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRegions = false);
      }
    }
  }

  Future<void> _onProvinceChanged(ProvinceEntity? prov) async {
    if (prov == null) return;
    setState(() {
      _selectedProvince = prov;
      _selectedCity = null;
      _cities = [];
      _isLoadingCities = true;
    });

    try {
      final getCitiesUseCase = context.read<GetCitiesUseCase>();
      final result = await getCitiesUseCase(prov.id);
      if (mounted) {
        setState(() {
          _cities = result;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
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

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama penerima wajib diisi')));
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor handphone wajib diisi')));
      return;
    }
    if (_streetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat lengkap wajib diisi')));
      return;
    }

    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final fullAddr = _streetController.text.trim();

    try {
      final provider = context.read<AddressProvider>();
      if (widget.address != null && widget.address!['id'] != null) {
        await provider.updateAddress(
          id: widget.address!['id'].toString(),
          name: name,
          phone: phone,
          provinceId: _selectedProvince?.id,
          provinceName: _selectedProvince?.name,
          cityId: _selectedCity?.id,
          cityName: _selectedCity != null ? '${_selectedCity!.type} ${_selectedCity!.name}' : null,
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
          provinceId: _selectedProvince?.id,
          provinceName: _selectedProvince?.name,
          cityId: _selectedCity?.id,
          cityName: _selectedCity != null ? '${_selectedCity!.type} ${_selectedCity!.name}' : null,
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
            _buildSectionTitle('Informasi Penerima', maroonColor),
            _buildInputField('*Nama', _nameController, maroonColor),
            _buildInputField('*No. Handphone', _phoneController, maroonColor),

            const SizedBox(height: 10),

            _buildSectionTitle('Wilayah Pengiriman (RajaOngkir)', maroonColor),
            
            // Dropdown Provinsi
            Text('*Provinsi', style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            _isLoadingRegions
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(strokeWidth: 2, color: maroonColor),
                  )
                : DropdownButtonFormField<ProvinceEntity>(
                    value: _selectedProvince,
                    isExpanded: true,
                    hint: Text('Pilih Provinsi', style: GoogleFonts.outfit(fontSize: 14)),
                    items: _provinces
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name, style: GoogleFonts.outfit(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: _onProvinceChanged,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

            const SizedBox(height: 15),

            // Dropdown Kota/Kabupaten
            Text('*Kota / Kabupaten', style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            _isLoadingCities
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(strokeWidth: 2, color: maroonColor),
                  )
                : DropdownButtonFormField<CityEntity>(
                    value: _selectedCity,
                    isExpanded: true,
                    hint: Text(
                      _selectedProvince == null ? 'Pilih Provinsi Terlebih Dahulu' : 'Pilih Kota / Kabupaten',
                      style: GoogleFonts.outfit(fontSize: 14),
                    ),
                    items: _cities
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.fullCityName, style: GoogleFonts.outfit(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: _selectedProvince == null
                        ? null
                        : (city) {
                            setState(() => _selectedCity = city);
                          },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

            const SizedBox(height: 15),

            _buildSectionTitle('Detail Alamat', maroonColor),
            _buildInputField('*Alamat Lengkap (Jalan, RT/RW, No. Rumah)', _streetController, maroonColor, maxLines: 3),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildBottomButton(_isSaving ? 'Menyimpan...' : 'Simpan', accentMaroon, () => _saveAddress(false)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildBottomButton(_isSaving ? 'Menyimpan...' : 'Simpan sebagai utama', accentMaroon, () => _saveAddress(true)),
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
        style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, Color color, {int maxLines = 1}) {
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
            maxLines: maxLines,
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

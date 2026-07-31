import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_address_screen.dart';
import 'providers/address_provider.dart';
import '../domain/entities/address_entity.dart';

class AddressScreen extends StatefulWidget {
  /// Ketika true (dibuka dari checkout_screen.dart), setiap kartu alamat
  /// menampilkan tombol "Pilih Alamat Ini" yang mem-pop layar ini dengan
  /// alamat terpilih, menggantikan alamat hardcode yang sebelumnya dipakai
  /// checkout_screen.dart (temuan audit: alamat pilihan pelanggan diabaikan).
  final bool selectMode;
  const AddressScreen({super.key, this.selectMode = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  /// checkout_screen.dart (belum dimigrasi) masih mengharapkan hasil pop
  /// berupa Map dengan bentuk yang sama seperti `AddressData._mapAddress`,
  /// jadi kontrak Map ini dipertahankan di sini.
  Map<String, dynamic> _toMap(AddressEntity addr) => {
        'id': addr.id,
        'name': addr.name,
        'phone': addr.phone,
        'fullAddress': addr.fullAddress,
        'isMain': addr.isMain,
      };

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFE8E4E4);

    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Alamat',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => context.read<AddressProvider>().loadAddresses(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: addresses.isEmpty
                      ? Center(
                          child: Text('Belum ada alamat tersimpan', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final addr = addresses[index];
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: maroonColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${addr.name} ${addr.phone}',
                                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      if (addr.isMain)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Utama',
                                            style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    addr.fullAddress,
                                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.white30),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddAddressScreen(address: _toMap(addr))
                                            )
                                          );
                                          if (mounted) {
                                            context.read<AddressProvider>().loadAddresses();
                                          }
                                        },
                                        child: _buildActionText('Edit'),
                                      ),
                                      const SizedBox(width: 30),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await context.read<AddressProvider>().deleteAddress(addr.id);
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Gagal menghapus alamat: $e')),
                                              );
                                            }
                                          }
                                        },
                                        child: _buildActionText('Hapus'),
                                      ),
                                      if (widget.selectMode) ...[
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context, _toMap(addr)),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Pilih Alamat Ini',
                                              style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // 2. Bottom Button
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressScreen()));
                      if (mounted) {
                        context.read<AddressProvider>().loadAddresses();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01D1D),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tambah Alamat',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionText(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}

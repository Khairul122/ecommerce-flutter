import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ootday_owner/features/auth/presentation/login.dart';
import 'package:ootday_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:ootday_owner/core/widgets/custom_dialog.dart';

class HapusAkun extends StatefulWidget {
  const HapusAkun({super.key});

  @override
  State<HapusAkun> createState() => _HapusAkunState();
}

class _HapusAkunState extends State<HapusAkun> {
  final Color redMain = const Color(0xFFB40001);
  final Color darkRed = const Color(0xFF7A0000);
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    final bool confirmed = await AppDialog.showConfirm(
      context,
      title: 'Hapus Akun Toko',
      message: 'Apakah Anda yakin ingin menghapus akun? Tindakan ini permanen dan tidak dapat dibatalkan.',
      confirmText: 'Ya, Hapus Akun',
      cancelText: 'Batal',
      confirmColor: Colors.red,
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().deleteAccount();
      if (!mounted) return;
      await AppDialog.showSuccess(
        context,
        title: 'Akun Dihapus',
        message: 'Akun Anda telah berhasil dihapus dari sistem.',
        onOk: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      AppDialog.showError(
        context,
        title: 'Gagal Menghapus Akun',
        message: e.toString(),
      );
    }
  }

  void _confirmDelete() {
    _deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Semua data toko dan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'produk akan dihapus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'permanen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Batalkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _confirmDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: redMain,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: redMain, width: 1),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Hapus Akun',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

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
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Akun',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

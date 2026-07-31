import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import '../../chat/presentation/chat_list_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Ambil data user terbaru dari server (GET /me), menggantikan pembacaan
  // dokumen Firestore 'users/{uid}' yang lama.
  Future<void> _fetchUserData() async {
    try {
      await context.read<AuthProvider>().refreshMe();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Perbaikan audit: sebelumnya tombol ini hanya mengirim email reset
  // password Firebase (tidak benar-benar mengubah apa pun di dalam aplikasi).
  // Sekarang membuka form ubah password nyata yang memanggil
  // PUT /api/me/password.
  Future<void> _showChangePasswordSheet(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isSubmitting = false;
    String? errorText;
    const maroonColor = Color(0xFF5D1A1A);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submit() async {
              if (newController.text.trim().length < 6) {
                setSheetState(() => errorText = 'Password baru minimal 6 karakter');
                return;
              }
              if (newController.text != confirmController.text) {
                setSheetState(() => errorText = 'Konfirmasi password tidak cocok');
                return;
              }
              setSheetState(() {
                isSubmitting = true;
                errorText = null;
              });
              try {
                await context.read<AuthProvider>().changePassword(
                  currentPassword: currentController.text,
                  newPassword: newController.text,
                );
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah')),
                  );
                }
              } catch (e) {
                setSheetState(() {
                  isSubmitting = false;
                  errorText = e.toString();
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ubah Password', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: maroonColor)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password saat ini'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password baru'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Konfirmasi password baru'),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Simpan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color headerBg = Color(0xFFD9D9D9);

    final user = context.watch<AuthProvider>().currentUser;
    final String userEmail = user?.email ?? 'Tidak ada email';

    // Masking phone number
    final String? phone = user?.phone;
    String displayPhone = phone ?? 'Belum Ditambahkan';
    if (phone != null && phone.length > 4) {
      displayPhone = '${phone.substring(0, 4)}******${phone.substring(phone.length - 2)}';
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: headerBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Pengaturan Akun',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
                child: Image.asset(
                  'assets/images/icons msg.png',
                  width: 26,
                  height: 26,
                  color: maroonColor,
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: maroonColor))
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _buildSecurityTile(
                    'Ubah Password',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                    onTap: () => _showChangePasswordSheet(context),
                  ),
                  _buildSecurityTile(
                    'Alamat Email',
                    value: userEmail,
                    valueColor: Colors.blue.withOpacity(0.3),
                  ),
                  _buildSecurityTile('No. Telp', value: displayPhone),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityTile(String title, {Widget? trailing, String? value, Color? valueColor, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          title: Text(
            title,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
          ),
          trailing: trailing ?? (value != null ? Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: valueColor ?? Colors.black26,
              decoration: valueColor != null ? TextDecoration.underline : null,
            ),
          ) : null),
          onTap: onTap ?? () {},
        ),
        const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
      ],
    );
  }
}

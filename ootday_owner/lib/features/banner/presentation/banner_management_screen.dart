import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  static const Color maroonColor = Color(0xFF6B1D2F);

  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/owner/banners');
      if (response != null && response['success'] == true) {
        final List list = response['data'] ?? [];
        if (mounted) {
          setState(() {
            _banners = list.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching owner banners: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBanner(int id) async {
    try {
      final apiService = context.read<ApiService>();
      await apiService.delete('/owner/banners/$id');
      _fetchBanners();
    } catch (e) {
      debugPrint('Error deleting banner: $e');
    }
  }

  void _showAddBannerDialog() {
    final titleController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Banner Promosi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Banner'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'URL Gambar Banner'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
              onPressed: () async {
                if (titleController.text.isEmpty || imageController.text.isEmpty) return;
                final apiService = context.read<ApiService>();
                await apiService.post('/owner/banners', {
                  'title': titleController.text.trim(),
                  'image_url': imageController.text.trim(),
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  _fetchBanners();
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: maroonColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelola Banner Promosi',
          style: GoogleFonts.outfit(color: maroonColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: maroonColor, size: 26),
            onPressed: _showAddBannerDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: maroonColor))
          : _banners.isEmpty
              ? Center(
                  child: Text('Belum ada banner promosi.', style: GoogleFonts.outfit(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _banners.length,
                  itemBuilder: (context, index) {
                    final item = _banners[index];
                    final String imageUrl = item['image_url'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: imageUrl.startsWith('http')
                              ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                              : Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                        ),
                        title: Text(item['title'] ?? 'Banner', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        subtitle: Text(imageUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBanner(item['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

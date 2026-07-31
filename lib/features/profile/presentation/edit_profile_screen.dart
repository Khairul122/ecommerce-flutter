import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _gender = 'Perempuan';

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 30),
                decoration: const BoxDecoration(
                  color: maroonColor,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Ootday',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 48), // Spacer agar judul tetap di tengah
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Profile Picture with Camera Icon
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 62,
                            backgroundImage: AssetImage('assets/images/profile.png'),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // FORM FIELDS
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Username'),
                    _buildRoundedField('Nama'),
                    const SizedBox(height: 20),

                    _buildLabel('Bio'),
                    _buildRoundedField('Isi bio'),
                    const SizedBox(height: 20),

                    _buildLabel('Jenis kelamin'),
                    Row(
                      children: [
                        _buildRadioOption('Perempuan'),
                        const SizedBox(width: 40),
                        _buildRadioOption('Laki laki'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Tanggal Lahir'),
                    _buildUnderlineField('Tgl/Bln/Thn'),
                    const SizedBox(height: 20),

                    _buildLabel('No. Handphone'),
                    _buildUnderlineField('No. handphone'),
                    const SizedBox(height: 20),

                    _buildLabel('Email'),
                    _buildUnderlineField('Email'),
                    
                    const SizedBox(height: 40),
                    // SIMPAN BUTTON
                    Center(
                      child: SizedBox(
                        width: 180,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.outfit(
                              color: maroonColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildRoundedField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.black54, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUnderlineField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: Colors.black54, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        isDense: true,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5D1A1A))),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gender == value ? const Color(0xFF5D1A1A) : const Color(0xFFD9D9D9),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: _gender == value ? const Color(0xFF5D1A1A).withOpacity(0.5) : Colors.black38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

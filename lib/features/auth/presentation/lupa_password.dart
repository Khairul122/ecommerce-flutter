import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ootday_owner/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ootday_owner/features/auth/presentation/providers/auth_provider.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() =>
      _LupaPasswordPageState();
}

class _LupaPasswordPageState
    extends State<LupaPasswordPage> {

  final TextEditingController
      _emailController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {

    final email =
        _emailController.text.trim();

    if (email.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Email wajib diisi",
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      await context.read<AuthProvider>().forgotPassword(email);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {

        showDialog(
          context: context,

          builder: (context) =>
              AlertDialog(

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                      20),
            ),

            title: const Row(
              children: [

                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),

                SizedBox(width: 10),

                Text("Berhasil"),
              ],
            ),

            content: Text(
              "Link reset password sudah dikirim ke\n$email",
            ),

            actions: [

              TextButton(
                onPressed: () {

                  Navigator.pop(
                      context);

                  Navigator.pop(
                      context);
                },

                child: const Text(
                  "OK",

                  style: TextStyle(
                    color:
                        Color(0xff8b0000),

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }

    } on AuthException catch (e) {

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim link reset: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xfff7f2f2),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
            ),

            child: Column(

              children: [

                const SizedBox(height: 20),

                // BACK BUTTON
                Align(

                  alignment:
                      Alignment.centerLeft,

                  child: IconButton(

                    onPressed: () {
                      Navigator.pop(
                          context);
                    },

                    icon: const Icon(
                      Icons.arrow_back,
                      color:
                          Color(0xff7a0000),
                      size: 35,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // ICON CIRCLE
                Container(

                  width: 180,
                  height: 180,

                  decoration:
                      const BoxDecoration(

                    color:
                        Color(0xffe6cccc),

                    shape:
                        BoxShape.circle,
                  ),

                  child: const Center(

                    child: Icon(
                      Icons.lock_outline,

                      size: 75,

                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 55),

                // TITLE
                const Text(

                  "Lupa Password ?",

                  style: TextStyle(

                    fontSize: 42,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Color(0xffa40000),
                  ),
                ),

                const SizedBox(height: 30),

                // DESCRIPTION
                const Text(

                  "Masukkan Email atau nomor telepon Anda\nuntuk menerima link reset password",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(

                    fontSize: 20,

                    color: Colors.grey,

                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 70),

                // TEXTFIELD
                Container(

                  height: 70,

                  decoration:
                      BoxDecoration(

                    color:
                        const Color(
                            0xffd9d9d9),

                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),

                  child: TextField(

                    controller:
                        _emailController,

                    style: const TextStyle(
                      fontSize: 20,
                    ),

                    decoration:
                        const InputDecoration(

                      prefixIcon: Padding(

                        padding:
                            EdgeInsets.only(
                                left: 15,
                                right: 10),

                        child: Icon(
                          Icons.mail_outline,

                          color:
                              Colors.black,

                          size: 35,
                        ),
                      ),

                      prefixIconConstraints:
                          BoxConstraints(
                        minWidth: 70,
                      ),

                      hintText:
                          "Email / Nomor Telepon",

                      hintStyle:
                          TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 20,
                      ),

                      border:
                          InputBorder.none,

                      contentPadding:
                          EdgeInsets.symmetric(
                        vertical: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 55),

                // BUTTON RESET
                SizedBox(

                  width: double.infinity,
                  height: 68,

                  child: ElevatedButton(

                    onPressed:
                        _isLoading
                            ? null
                            : _resetPassword,

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(
                              0xffe1c3c3),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                                25),
                      ),
                    ),

                    child: _isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )

                        : const Text(

                            "Kirim Link Reset",

                            style: TextStyle(

                              fontSize: 22,

                              fontWeight:
                                  FontWeight.bold,

                              color:
                                  Colors.black54,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                // LOGIN TEXT
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(

                      "Ingat Password? ",

                      style: TextStyle(

                        fontSize: 18,

                        color:
                            Colors.grey,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    GestureDetector(

                      onTap: () {
                        Navigator.pop(
                            context);
                      },

                      child: const Text(

                        "Login",

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,

                          color:
                              Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
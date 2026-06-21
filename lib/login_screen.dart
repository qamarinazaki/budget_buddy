import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'app_data_manager.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {

    final prefs =
    await SharedPreferences.getInstance();

    final email =
    prefs.getString('userEmail');

    if (email != null &&
        email.isNotEmpty) {

      AppDataManager.userName =
          prefs.getString('userName') ?? '';

      AppDataManager.userEmail = email;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainDashboard(
            userName:
            prefs.getString('userName') ?? '',
            userEmail: email,
          ),
        ),
      );
    }
  }

  Future<void> _login() async {
    try {
      final credential =
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      AppDataManager.userName =
          credential.user?.displayName ?? 'User';

      AppDataManager.userEmail =
          credential.user?.email ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        AppDataManager.userPhone =
            doc['phone'] ?? '';

        AppDataManager.course =
            doc['course'] ?? '';

        AppDataManager.studyYear =
            doc['studyYear'] ?? '';
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MainDashboard(
                userName:
                credential.user?.displayName ?? 'User',
                userEmail:
                credential.user?.email ?? '',
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login Failed'),
        ),
      );
    }
  }

  void _showRegisterDialog() {

    final nameController =
    TextEditingController();

    final registerEmailController =
    TextEditingController();

    final phoneController =
    TextEditingController();

    final courseController =
    TextEditingController();

    final yearController =
    TextEditingController();

    final passwordController =
    TextEditingController();

    final confirmPasswordController =
    TextEditingController();

    bool obscurePassword = true;
    bool obscureConfirmPassword = true;


    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
            "Student Registration",
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [

                TextField(
                  controller:
                  nameController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    "Full Name",
                  ),
                ),

                TextField(
                  controller:
                  registerEmailController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    "Email",
                  ),
                ),

                TextField(
                  controller:
                  phoneController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    "Phone Number",
                  ),
                ),

                TextField(
                  controller:
                  courseController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    "Course",
                  ),
                ),

                TextField(
                  controller:
                  yearController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    "Study Year",
                  ),
                ),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword =
                          !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureConfirmPassword =
                          !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () async {
                if (passwordController.text !=
                    confirmPasswordController.text) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password and Confirm Password do not match",
                      ),
                    ),
                  );

                  return;
                }
                try {

                  final credential =
                  await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: registerEmailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  await credential.user?.updateDisplayName(
                    nameController.text.trim(),
                  );
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(credential.user!.uid)
                      .set({
                    'name': nameController.text.trim(),
                    'email': registerEmailController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'course': courseController.text.trim(),
                    'studyYear': yearController.text.trim(),
                  });

                  if (!context.mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Account Registered Successfully",
                      ),
                    ),
                  );

                } on FirebaseAuthException catch (e) {

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'Register Failed'),
                    ),
                  );
                }
              },
              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFF020617),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.pink,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Budget Buddy",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // EMAIL

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon:
                      const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD

                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text("LOGIN"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: _showRegisterDialog,
                    child: const Text(
                      "Register Profile",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

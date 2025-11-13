import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final classController = TextEditingController();
  final mobileNoController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> doUserRegistration() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final studentClass = classController.text.trim();
    final mobile = mobileNoController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        studentClass.isEmpty ||
        mobile.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Create custom user record in "user" table
    final user = ParseObject('user')
      ..set('name', name)
      ..set('age', int.tryParse(age))
      ..set('class', int.tryParse(studentClass))
      ..set('mobile', mobile)
      ..set('email', email)
      ..set('password', password);

    final response = await user.save();

    setState(() => isLoading = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Registration Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error?.message ?? "Error"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    size: 70, color: theme.colorScheme.primary),
                const SizedBox(height: 16),

                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                buildInput(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                buildInput(
                  controller: ageController,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 16),

                buildInput(
                  controller: classController,
                  label: 'Class (Standard)',
                  icon: Icons.school_outlined,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 16),

                buildInput(
                  controller: mobileNoController,
                  label: 'Mobile Number',
                  icon: Icons.phone_iphone,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                buildInput(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password with eye toggle
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : doUserRegistration,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable input builder
  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

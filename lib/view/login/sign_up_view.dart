import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/view/login/sign_in_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController textName = TextEditingController();
  TextEditingController textPhone = TextEditingController();
  TextEditingController textEmail = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  TextEditingController textConfirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context); 

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    const Center(
                      child: Text(
                        "Welcome, please Sign Up",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Fields
                    _buildTextField("Username", "Enter your username", textName,
                        TextInputType.text),
                    const SizedBox(height: 20),
                    _buildTextField("Phone Number", "Enter your phone",
                        textPhone, TextInputType.phone),
                    const SizedBox(height: 20),
                    _buildTextField("Email", "Enter your email", textEmail,
                        TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField("Password", "Enter your password",
                        textPassword, TextInputType.visiblePassword,
                        obscureText: true),
                    const SizedBox(height: 20),
                    _buildTextField(
                        "Confirm Password",
                        "Re-enter your password",
                        textConfirmPass,
                        TextInputType.visiblePassword,
                        obscureText: true),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      title: "Sign Up",
                      onPress: () {},
                      color: Colors.white,
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SecondaryButton(
                                title: "Sign In",
                                onPress: () {
                                  Get.to(SignInView());
                                },
                                color: Colors
                                    .green, // Matching the login button color
                              ),
                            ],
                          ),
                        ],
                      ),
                    )

                    // Extra bottom space
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder,
      TextEditingController controller, TextInputType keyboardType,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: placeholder,
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1,
          color: TColor.gray10,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

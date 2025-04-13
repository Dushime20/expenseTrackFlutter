import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/view/home/home_view.dart';
import 'package:untitled/view/main_tab/main_tab_view.dart';
import 'sign_up_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  TextEditingController textEmail = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  bool isRemember = false;

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
                    Center(
                      child: Text(
                        "Welcome! Please Sign In",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.gray80,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    _buildTextField("Email", "Enter your email", textEmail,
                        TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField("Password", "Enter your password",
                        textPassword, TextInputType.visiblePassword,
                        obscureText: true),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isRemember = !isRemember;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isRemember
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank_rounded,
                                size: 15,
                                color: TColor.gray50,
                              ),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  color: TColor.gray50,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot password",
                            style: TextStyle(
                              color: TColor.gray50,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      title: "Sign In",
                      onPress: () {
                        Get.to(const MainTabView());
                      },
                      color: TColor.white,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SecondaryButton(
                          title: "Signup",
                          onPress: () {
                            Get.to(const SignUpView());
                          },
                          color: Colors.green,
                        ),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
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
    var media = MediaQuery.sizeOf(context); // Get media size

    return Scaffold(
      backgroundColor: TColor.gray80, // Background color
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/img/app_logo.png",
                        width: media.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Welcome please SignUp",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'Username',
                      keyboardType: TextInputType.text,
                      controller: textName,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      controller: textPhone,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      controller: textEmail,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      controller: textPassword,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'ConfirmPassword',
                      keyboardType: TextInputType.visiblePassword,
                      controller: textConfirmPass,
                    ),
                    // const SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Container(
                    //         height: 4,
                    //         margin: const EdgeInsets.symmetric(horizontal: 2),
                    //         decoration: BoxDecoration(color: TColor.gray70),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
                    // Text(
                    //   "Use 8 or more characters with a mix of letters, numbers & symbols.",
                    //   style: TextStyle(fontSize: 12, color: TColor.gray50, fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(height: 50),
                    PrimaryButton(
                      title: "SignUp",
                      onPress: () {},
                      color: TColor.blue900,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Do you already have an account?",
                        style: TextStyle(fontSize: 12, color: TColor.gray50, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SecondaryButton(
                      title: "SignIn",
                      onPress: () {
                        Get.to(SignInView());
                      },
                      color: TColor.white,
                    ),
                    const SizedBox(height: 40), // Add space at bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/view/main_tab/main_tab_view.dart';

import 'sign_up_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignInView> {

  TextEditingController textEmail = TextEditingController();
  TextEditingController textPassword = TextEditingController();
  bool isRemember = false;

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
                        "Welcome Please SignIn",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      controller: textEmail, titleAlign: null,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      title: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      controller: textPassword, titleAlign: null,
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: (){
                          setState(() {
                            isRemember= !isRemember;
                          });

                        },
                            child: Row(
                              children: [
                                Icon(
                                  isRemember?Icons.check_box:Icons.check_box_outline_blank_rounded,size: 15, color: TColor.gray50,),
                              Text(
                              "Remember me", style: TextStyle(color: TColor.gray50, fontSize: 14),
                            )
                              ],
                            )),
                        TextButton(onPressed: (){

                        },
                            child: Text(
                              "forgot password", style: TextStyle(color: TColor.primary20, fontSize: 14),
                            ))
                      ],
                    ),
                    const SizedBox(height: 100),
                    PrimaryButton(
                      title: "SignIn",
                      onPress: () {
                        Get.to(MainTabView());
                      },
                      color: TColor.blue900,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "If you don't have account yet?",
                        style: TextStyle(fontSize: 12, color: TColor.gray50, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SecondaryButton(
                      title: "Signup",
                      onPress: () {
                        Get.to(SignUpView());
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/home/home_view.dart';
import 'package:untitled/view/main_tab/main_tab_view.dart';
import '../../controller/app_initialization_controller.dart';

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
  bool isLoading = false;
  final box = GetStorage();

  @override
  void dispose(){
  super.dispose();
  textEmail.dispose();
  textPassword.dispose();

  }
// sign in user
  void signInUser() async {
    // Validate empty fields
    if (textEmail.text.isEmpty || textPassword.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all the fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> res = await AuthenticationService().loginUser(  // ✅ Changed type from String to Map
      email: textEmail.text,
      password: textPassword.text,
    );

    setState(() {
      isLoading = false;
    });

    if (res['status'] == "success") {  //  Checking 'status' field from Map
      String uid = res['uid'];
      String? email = res['email'];

      // Save to GetStorage
      box.write('uid', uid);
      box.write('email', email ?? '');
      box.write('isLoggedIn', true);

      /// Now that login succeeded, fetch all the data
      final appInitController = Get.put(AppInitializationController());
      await appInitController.initialize();

      //print("fetched data");
      Get.snackbar(
        "Success",
        "Sign in completed successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.to(() => const MainTabView());
    } else {
      Get.snackbar(
        "Error",
        res['message'],  //  Show specific error from the Map
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      print("error occurred here");
      print(res['message']);
    }
  }


  // forget password
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // TextButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       isRemember = !isRemember;
                        //     });
                        //   },
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         isRemember
                        //             ? Icons.check_box
                        //             : Icons.check_box_outline_blank_rounded,
                        //         size: 15,
                        //         color: TColor.gray50,
                        //       ),
                        //       Text(
                        //         "Remember me",
                        //         style: TextStyle(
                        //           color: TColor.gray50,
                        //           fontSize: 14,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        TextButton(

                          onPressed: () {
                            myDialogBox(context);
                          },
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
                        signInUser();
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
                            Get.to(()=>const SignUpView());
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

  void myDialogBox(BuildContext context){
    showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(20)
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Forget Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),

              SizedBox(height: 20,),
              TextField(
                controller: textEmail,
                decoration:
                InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter the email to reset password",
                  hintText: "eg my@gmail.com",
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async{
                  await auth.sendPasswordResetEmail(email: textEmail.text).then((value){
                    //if success show this
                    Get.snackbar("Success", "we have sent you the reset password link to you email id, please check it",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,);
                  }).onError((error, stackTrace){
                    //if not success show this
                    Get.snackbar(
                      "Error",
                      error.toString(),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                  });

                  Navigator.pop(context);
                  textEmail.clear();
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.line,
                ),
                child: Text(
                  "Send",
                  style: TextStyle(
                    color: TColor.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            ],
          ),
        ),

      );
    });
  }
}




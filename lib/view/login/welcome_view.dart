import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/view/login/sign_in_view.dart';
import 'package:untitled/view/login/sign_up_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }
  @override
  Widget build(BuildContext context) {

    var media= MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,

        children: [
          Positioned.fill( // This ensures the image takes the full screen
            child: Image.asset(
              "assets/img/money.jpg",
              fit: BoxFit.cover, // Ensures the image covers the whole screen
            ),
          ),
          SafeArea(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/img/app_logo.png", width: media.width*0.5, fit: BoxFit.cover,),
                const Spacer(),
                Text("Every penny counts! Let's build better spending habits.",
                    textAlign: TextAlign.center,style: TextStyle(color: TColor.white,fontSize: 14,fontWeight: FontWeight.bold),),
                const SizedBox(
                  height: 30,
                ),
                PrimaryButton(title: 'Get Started', onPress: () {
                  Get.to(SignUpView());
                }, color: TColor.blue500,),

                const SizedBox(
                  height: 30,
                ),
                SecondaryButton(title: 'I have an Account', onPress: () {
                  Get.to(SignInView());
                }, color: TColor.white,),
              ],

            ),
          )
          )
        ],
      ),
    );
  }
}

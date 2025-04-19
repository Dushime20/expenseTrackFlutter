import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/controller/categoryController.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/firebase_option.dart';
import 'package:untitled/view/login/welcome_view.dart';
 


void main() async{

  // Initialize Firebase


  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: firebaseOptions);
  //register controller
   Get.put(HomeController());
   Get.put(CategoryController());
   Get.put(BudgetController());
   runApp(const MyApp());
  // runApp(
  //   DevicePreview(builder: (context) =>const MyApp())
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: TColor.primary,
          surface: TColor.gray80,
          primary: TColor.primary,
          primaryContainer: TColor.gray60,
          secondary: TColor.secondary,
        ),
        useMaterial3: false,
      ),
      home: const WelcomeView(),
    );
  }
}

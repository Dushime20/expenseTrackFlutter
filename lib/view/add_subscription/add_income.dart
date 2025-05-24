import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';

import 'package:untitled/controller/home_controller.dart';


class AddIncomeView extends StatefulWidget {
  const AddIncomeView({super.key});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {

  final HomeController homeCtrl = Get.put(HomeController());


  List subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];


  //Added loading flag
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

  }

  void handleSubmit() async {


    if (homeCtrl.descriptionCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a name",
          colorText: TColor.secondary);
      return;
    }


    if (homeCtrl.amountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a amount",
          colorText: TColor.secondary);
      return;
    }
    // Start loading
    setState(() {
      _isLoading = true;
    });

    final addIncome = await homeCtrl.addIncome();

    // Stop loading
    setState(() {
      _isLoading = false;
    });
    if(addIncome){

      Get.snackbar("Success", "Transaction added successfully",
          colorText: TColor.line);

      Navigator.pop(context);
    }


    // Reset state
    setState(() {

      homeCtrl.descriptionCtrl.clear();
      homeCtrl.amountCtrl.clear();

    });
  }


  @override
  Widget build(BuildContext context) {

    // Ensure initialization happens when the screen is built
    //

    var media = MediaQuery.sizeOf(context);
    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        backgroundColor: TColor.back,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header & Carousel
              Container(
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25))),
                child: SafeArea(
                  child: Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Image.asset("assets/img/back.png",
                                        width: 25,
                                        height: 25,
                                        color: TColor.gray30))
                              ],
                            ),
                            const SizedBox(width: 20),
                            Row(
                              children: [
                                Text(
                                  "Add new income",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.gray80,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: media.width,
                        height: media.width * 0.5,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            autoPlay: false,
                            aspectRatio: 1,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.65,
                            enlargeFactor: 0.4,
                            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                          ),
                          itemCount: subArr.length,
                          itemBuilder: (context, index, _) {
                            var sObj = subArr[index];
                            return Container(
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      sObj["icon"],
                                      width: media.width * 0.4,
                                      height: media.width * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    sObj["name"],
                                    style: TextStyle(
                                        color: TColor.gray60,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),



              // Description Field
              Padding(
                  padding:
                  const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: RoundedTextField(
                      title: "name",
                      titleAlign: TextAlign.center,
                      controller: homeCtrl.descriptionCtrl)),

              // Amount Section
              Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),

                  child: RoundedTextField(
                      title: "Amount",
                      titleAlign: TextAlign.center,
                      controller: homeCtrl.amountCtrl)),


              // Add Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add new income",  // Change button text when loading
                  onPress: _isLoading ? () {} : handleSubmit,    //  Disable button when loading
                  color: TColor.white,
                  isLoading: _isLoading,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}

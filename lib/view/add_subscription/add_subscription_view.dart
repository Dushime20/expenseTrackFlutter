import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/categoryController.dart';
import 'package:untitled/controller/home_controller.dart';

import '../../common_widget/image_button.dart';
import '../../controller/app_initialization_controller.dart';

class AddSubScriptionView extends StatefulWidget {
  const AddSubScriptionView({super.key});

  @override
  State<AddSubScriptionView> createState() => _AddSubScriptionViewState();
}

class _AddSubScriptionViewState extends State<AddSubScriptionView> {
  final CategoryController categoryCtrl = Get.put(CategoryController());
  final HomeController homeCtrl = Get.put(HomeController());

  double amountVal = 0.0;
  String? selectedCategoryName;
  String? selectedCategoryId;

  List subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];

  @override
  void initState() {
    super.initState();
    categoryCtrl.filterCategoryByName(""); // Load all categories initially
  }
  void handleSubmit() async {
    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      Get.snackbar("Error", "Please select a category",
          colorText: TColor.secondary);
      return;
    }

    if (homeCtrl.descriptionCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a description",
          colorText: TColor.secondary);
      return;
    }

    await homeCtrl.addExpenses(categoryId: selectedCategoryId!);

    Get.snackbar("Success", "Transaction added successfully",
        colorText: TColor.line);

    // Reset state
    setState(() {
      amountVal = 0.0;
      homeCtrl.descriptionCtrl.clear();
      selectedCategoryId = null;
      selectedCategoryName = null;
    });
  }
  void handleAdd() async {
    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      Get.snackbar("Error", "Please select a category",
          colorText: TColor.secondary);
      return;
    }

    if (homeCtrl.descriptionCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a description",
          colorText: TColor.secondary);
      return;
    }

    await homeCtrl.addIncome(categoryId: selectedCategoryId!);

    Get.snackbar("Success", "Transaction added successfully",
        colorText: TColor.line);

    // Reset state
    setState(() {
      amountVal = 0.0;
      homeCtrl.descriptionCtrl.clear();
      selectedCategoryId = null;
      selectedCategoryName = null;
    });
  }


  @override
  Widget build(BuildContext context) {

    // Ensure initialization happens when the screen is built
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

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
                                  "Add new income \nor expense",
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

              // Category Dropdown
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: GetBuilder<CategoryController>(
                  builder: (catCtrl) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextField(
                        //   decoration: InputDecoration(
                        //     hintText: 'Search category',
                        //     prefixIcon: Icon(Icons.search),
                        //     border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(12)),
                        //   ),
                        //   onChanged: (val) {
                        //     catCtrl.filterCategoryByName(val);
                        //   },
                        // ),

                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          hint: Text('Select Category', style: TextStyle(color: TColor.gray60)),
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: catCtrl.categoryList.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Text(cat.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                              selectedCategoryName = catCtrl.categoryList
                                  .firstWhere((cat) => cat.id == value)
                                  .name;
                            });
                          },
                        ),

                      ],
                    );
                  },
                ),
              ),

              // Description Field
              Padding(
                  padding:
                  const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: RoundedTextField(
                      title: "Description",
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
                  title: "Add new expenses",
                  onPress: () async {
                     handleSubmit();
                    setState(() {
                      amountVal = 0.0;
                    });
                  },
                  color: TColor.white,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: "Add new income",
                  onPress: () async {
                    handleAdd();
                    setState(() {
                      amountVal = 0.0;
                    });
                  },
                  color: TColor.white,
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

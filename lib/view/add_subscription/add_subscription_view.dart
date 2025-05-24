import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/income_segment_button.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/expense_controller.dart';

import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/model/spending/spending.dart';
import 'package:untitled/view/add_subscription/add_income.dart';
import 'package:untitled/view/add_subscription/add_spending.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';

import '../../common_widget/segment_button.dart';



class AddSubScriptionView extends StatefulWidget {
  const AddSubScriptionView({super.key});

  @override
  State<AddSubScriptionView> createState() => _AddSubScriptionViewState();
}

class _AddSubScriptionViewState extends State<AddSubScriptionView> {

  bool isIncome = true;
  List subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];



  final ExpenseController expenseCtrl = Get.put(ExpenseController());



  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

  }


  String? selectedCategory;

  void handleSubmit() async {

    print("add expense button is clicked");



    if (expenseCtrl.categoryCtrl.text.trim().isEmpty || expenseCtrl.amountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a description",
          colorText: TColor.secondary);
      return;
    }
    setState(() {
      _isLoading = true;
    });
     final addExpense = await expenseCtrl.addExpense();
    setState(() {
      _isLoading = false;
    });
    if(addExpense){
      Get.snackbar("Success", "Transaction added successfully",
          colorText: TColor.line);

          Get.to(()=>SpendingBudgetsView());
      // Reset state
      setState(() {

        expenseCtrl.categoryCtrl.clear();
        expenseCtrl.amountCtrl.clear();
      });

    }

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
                                  "Set your expense category",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.gray80,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
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
             SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // margin on both sides
                // child: Container(
                //   alignment: Alignment.center, // center content inside container
                //   padding: const EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //     color: TColor.back,
                //     borderRadius: BorderRadius.circular(16),
                //     border: Border.all(color: Colors.grey.shade300),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       InkWell(
                //         onTap: () {
                //           Get.to(() => const AddSpendingView());
                //         },
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //           decoration: BoxDecoration(
                //             border: Border.all(color: TColor.line),
                //             color: TColor.back,
                //             borderRadius: BorderRadius.circular(16),
                //           ),
                //           child: const Text(
                //             "Add your subCategory",
                //             style: TextStyle(
                //               color: Colors.black87,
                //               fontSize: 12,
                //               fontWeight: FontWeight.w600,
                //             ),
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 20),
                //       InkWell(
                //         onTap: () {
                //           Get.to(() => const AddIncomeView());
                //         },
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //           decoration: BoxDecoration(
                //             border: Border.all(color: TColor.line),
                //             color: TColor.back,
                //             borderRadius: BorderRadius.circular(16),
                //           ),
                //           child: const Text(
                //             "Add your income",
                //             style: TextStyle(
                //               color: Colors.black87,
                //               fontSize: 12,
                //               fontWeight: FontWeight.w600,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                child:  Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  height: 45,
                  width: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: IncomeSegmentButton(
                          title: 'Add subCategory',
                          onPress: () {
                            setState(() {
                              Get.to(() => const AddSpendingView());
                              
                            });
                          },
                        

                        ),
                      ),
                      Expanded(
                        child: IncomeSegmentButton(
                          title: 'add Income',
                          onPress: () {
                            setState(() {
                              Get.to(() => const AddIncomeView());
                              
                            });
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
                      title: "category",
                      titleAlign: TextAlign.center,
                      controller: expenseCtrl.categoryCtrl
                  )),

              // Amount Section
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),

                  child: RoundedTextField(
                      title: "Amount",
                      titleAlign: TextAlign.center,
                      controller: expenseCtrl.amountCtrl
                  )),


              // Add Buttons

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add new Expense",
                  onPress: _isLoading ? () {}: handleSubmit,
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

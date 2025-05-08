import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/report/expense_report.dart';
import 'package:untitled/report/income_report.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/login/edit_profile.dart';
import 'package:untitled/view/login/sign_in_view.dart';


import '../../common/color_extension.dart';
import '../../common_widget/icon_item_row.dart';
import '../../report/budget_report.dart';
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}
class _SettingsViewState extends State<SettingsView> {
  bool isActive = false;
  final AuthenticationService authService = AuthenticationService();

  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    final userData = await authService.getCurrentUserData();
    print("fetched user, ${userData}");
    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? 'No Name';
        userEmail = userData['email'] ?? 'No Email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.back,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset("assets/img/back.png",
                            width: 25, height: 25, color: TColor.gray30))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(color: TColor.gray80, fontSize: 16),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/u1.png",
                  width: 70,
                  height: 70,
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: TColor.gray60,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userEmail,
                  style: TextStyle(
                    color: TColor.gray60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Get.to(()=> EditProfileView());
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: TColor.border.withOpacity(0.15),
                  ),
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Edit profile",
                  style: TextStyle(
                      color: TColor.gray60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Text(
                      "Report",
                      style: TextStyle(
                          color: TColor.gray60,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TColor.border.withOpacity(0.1),
                      ),
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        IconItemRow(
                          title: "Expense Report",

                          value: "save",
                          onTap: () async{
                            final generator = ExpensePdfGenerator();
                            await generator.generateAndSaveExpenseReport();
                          },
                        ),
                        SizedBox(height: 30,),

                        IconItemRow(
                          title: "Income Report",

                          value: "save",
                          onTap: () async{
                            final generator = IncomePdfGenerator();
                            await generator.generateAndSaveIncomeReport();
                          },
                        ),
                        SizedBox(height: 30,),
                        IconItemRow(
                          title: "Budget Report",

                          value: "save",
                          onTap: () async{
                            final generator = BudgetPdfGenerator();
                            await generator.generateAndSaveBudgetReport();
                          },
                        ),

                        
                      ],
                    ),
                  ),

                 SizedBox(height: 30,),

                  TextButton(onPressed: () async{
                    await AuthenticationService().signOut();
                    Get.to(const SignInView());
                  }, child:
                  Text("Logout",style: TextStyle(color: TColor.gray70, fontSize: 16),)),

                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

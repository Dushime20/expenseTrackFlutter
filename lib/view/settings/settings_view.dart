import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/login/sign_in_view.dart';


import '../../common/color_extension.dart';
import '../../common_widget/icon_item_row.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isActive = false;

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
            const SizedBox(
              height: 20,
            ),
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
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Code For Any",
                  style: TextStyle(
                      color: TColor.gray60,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                )
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "codeforany@gmail.com",
                  style: TextStyle(
                      color: TColor.gray60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {},
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
                    padding: const EdgeInsets.only(top: 15, bottom: 8),
                    child: Text(
                      "General",
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
                          title: "Password",
                          value: "change password",
                          onTap: (){},
                        ),

                        IconItemRow(
                          title: "Theme",

                          value: "Dark",
                          onTap: (){},
                        ),

                      ],
                    ),
                  ),

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

                          value: "Date",
                          onTap: (){},
                        ),

                        IconItemRow(
                          title: "Income Report",

                          value: "Average",
                          onTap: (){},
                        ),
                        IconItemRow(
                          title: "Budget Report",

                          value: "Average",
                          onTap: (){},
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

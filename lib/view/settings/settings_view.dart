import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/theme_controller.dart';
import 'package:untitled/report/expense_report.dart';
import 'package:untitled/report/income_report.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/login/edit_profile.dart';
import 'package:untitled/view/login/sign_in_view.dart';

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
  late ThemeController themeController;

  String selectedTheme = "";

  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();

    fetchCurrentUser();
    themeController = Get.find<ThemeController>();
  }

  Future<void> fetchCurrentUser() async {
    final userData = await authService.getCurrentUserData();
    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? 'No Name';
        userEmail = userData['email'] ?? 'No Email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textColor = theme.textTheme.bodyMedium?.color;
    var backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Settings",
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Icon(Icons.person, size: 70, color: textColor?.withOpacity(0.6)),
            const SizedBox(height: 8),
            Text(
              userName,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: TextStyle(
                color: textColor?.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Get.to(() => const EditProfileView());
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.15),
                  ),
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Edit profile",
                  style: TextStyle(
                      color: textColor,
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
                  sectionTitle("Report", textColor),
                  themedContainer(
                    theme,
                    Column(
                      children: [
                        IconItemRow(
                          title: "Expense Report",
                          value: "save",
                          onTap: () async {
                            final generator = ExpensePdfGenerator();
                            await generator.generateAndSaveExpenseReport();
                          },
                        ),
                        const SizedBox(height: 20),
                        IconItemRow(
                          title: "Income Report",
                          value: "save",
                          onTap: () async {
                            final generator = IncomePdfGenerator();
                            await generator.generateAndSaveIncomeReport();
                          },
                        ),
                        const SizedBox(height: 20),
                        IconItemRow(
                          title: "Budget Report",
                          value: "save",
                          onTap: () async {
                            final generator = BudgetPdfGenerator();
                            await generator.generateAndSaveBudgetReport();
                          },
                        ),
                      ],
                    ),
                  ),
                  sectionTitle("Theme", textColor),
                  themedContainer(
                    theme,
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Light Mode'),
                          value: 'Light',
                          groupValue: selectedTheme,
                          onChanged: (value) {
                            setState(() {
                              selectedTheme = value!;
                              themeController.setThemeMode(ThemeMode.light);
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Dark Mode'),
                          value: 'Dark',
                          groupValue: selectedTheme,
                          onChanged: (value) {
                            setState(() {
                              selectedTheme = value!;
                              themeController.setThemeMode(ThemeMode.dark);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.logout, color: textColor),
                      TextButton(
                          onPressed: () async {
                            await AuthenticationService().signOut();
                            Get.to(const SignInView());
                          },
                          child: Text(
                            "Logout",
                            style: TextStyle(color: textColor, fontSize: 16),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            color: color, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget themedContainer(ThemeData theme, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

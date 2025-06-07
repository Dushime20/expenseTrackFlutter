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
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = theme.disabledColor; // For grayed out text / line colors
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardBackground = theme.cardColor;

    return Scaffold(
      backgroundColor: TColor.back, // you may consider theme.scaffoldBackgroundColor here
      appBar: AppBar(
        title: Text(
          "Tracking Expense",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.foregroundColor ?? Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.white,
        elevation: 2,
        iconTheme: theme.appBarTheme.iconTheme ?? const IconThemeData(color: Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    SizedBox(
                      height: 400,
                      child: Card(
                        color: cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expense Tracker Features",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildTimelineItem(
                                        title: "Step 1: Expense Tracking",
                                        description:
                                            "Easily log and categorize your expenses, set monthly budgets, and get real-time alerts when you're close to overspending.",
                                        textColor: textColor,
                                        grayColor: grayColor,
                                      ),
                                      _buildTimelineItem(
                                        title: "Step 2: Budget Setup",
                                        description:
                                            "Set realistic financial goals and stay on track with customized budget plans that keep your spending in check.",
                                        textColor: textColor,
                                        grayColor: grayColor,
                                      ),
                                      _buildTimelineItem(
                                        title: "Step 3: Financial Insights",
                                        description:
                                            "Gain full visibility into your expenses with detailed reports and visual charts to make informed money decisions.",
                                        textColor: textColor,
                                        grayColor: grayColor,
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      title: 'Get Started',
                      onPress: () {
                        Get.to(const SignUpView());
                      },
                      color: TColor.white,
                    ),
                    const SizedBox(height: 20),
                    SecondaryButton(
                      title: 'I have an Account',
                      onPress: () {
                        Get.to(const SignInView());
                      },
                      color: TColor.line,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required Color textColor,
    required Color grayColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.radio_button_checked, size: 14, color: Colors.green.shade600),
            Container(height: 80, width: 2, color: Colors.green.shade600),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, width: 2, color: grayColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: grayColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

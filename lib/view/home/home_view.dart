import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/custom_arc_painter.dart';
import 'package:untitled/common_widget/income_home_row.dart';
import 'package:untitled/common_widget/segment_button.dart';
import 'package:untitled/common_widget/status_button.dart';
import 'package:untitled/common_widget/up_coming_bill_row.dart';
import 'package:untitled/view/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isIncome = true;

  List incomeArr = [
    {
      "name": "Monthly Salary",
      "icon": "assets/img/salary.jpeg",
      "price": "100,000"
    },
    {"name": "Bonuses", "icon": "assets/img/bonus.jpeg", "price": "30,000"},
    {
      "name": "Overtime Pay",
      "icon": "assets/img/overtime.jpeg",
      "price": "20,000"
    },
    {
      "name": "Teaching Allowances",
      "icon": "assets/img/allowence.jpeg",
      "price": "50,000"
    },
  ];

  List billArr = [
    {
      "name": "Housing & Utilities",
      "date": DateTime(2025, 05, 1),
      "price": "100,000"
    },
    {
      "name": "Food & Groceries",
      "date": DateTime(2025, 05, 1),
      "price": "30,000"
    },
    {
      "name": "Transportation",
      "date": DateTime(2025, 05, 1),
      "price": "20,000"
    },
    {
      "name": "Communication & Subscriptions",
      "date": DateTime(2025, 05, 1),
      "price": "50,000"
    },
    {
      "name": "Family & Dependents",
      "date": DateTime(2025, 05, 1),
      "price": "50,000"
    },
    {
      "name": "Health & Insurance",
      "date": DateTime(2025, 05, 1),
      "price": "50,000"
    },
    {
      "name": "Miscellaneous & Personal Expenses",
      "date": DateTime(2025, 05, 1),
      "price": "50,000"
    },
    {
      "name": "Debt & Financial Commitments",
      "date": DateTime(2025, 05, 1),
      "price": "50,000"
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: media.width * 0.8,
              decoration: BoxDecoration(
                color: TColor.back,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: media.width * 0.01),
                        width: media.width * 0.6,
                        height: media.width * 0.6,
                        child: CustomPaint(
                          painter: CustomArcPainter(end: 220),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 20),
                        child: Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsView(),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                "assets/img/settings.png",
                                width: 25,
                                height: 25,
                                color: TColor.gray60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "1,235 Frw",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "This month Expenses",
                        style: TextStyle(
                          color: TColor.gray60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: TColor.border),
                            color: TColor.back,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "See your budget",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Replace this inside the Stack (the one under the Container)
                  Positioned(
                    bottom: 5,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        _buildStatCard("Active Expense", "50"),
                        const SizedBox(width: 8),
                        _buildStatCard("High Expense", "20k Frw"),
                        const SizedBox(width: 8),
                        _buildStatCard("Lowest Expense", "5.99 Frw"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Toggle buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              height: 45,
              width: 250,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: TColor.back,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentButton(
                      title: 'Our Income',
                      onPress: () {
                        setState(() {
                          isIncome = false;
                        });
                      },
                      isActive: !isIncome,
                    ),
                  ),
                  Expanded(
                    child: SegmentButton(
                      title: 'Upcoming bills',
                      onPress: () {
                        setState(() {
                          isIncome = true;
                        });
                      },
                      isActive: isIncome,
                    ),
                  ),
                ],
              ),
            ),

            // Conditional content
            if (!isIncome)
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: incomeArr.length,
                itemBuilder: (context, index) {
                  var incObj = incomeArr[index] as Map? ?? {};
                  return IncomeHomeRow(onPress: () {}, incObj: incObj);
                },
              ),

            if (isIncome)
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: billArr.length,
                itemBuilder: (context, index) {
                  var sObj = billArr[index] as Map? ?? {};
                  return UpcomingBillRow(sObj: sObj, onPressed: () {});
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: TColor.back,
          border: Border.all(color: TColor.gray10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: TColor.gray40, fontSize: 10),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/theme_controller.dart';

import '../../common_widget/income_barchat.dart';
import '../../common_widget/income_home_row.dart';
import '../../common_widget/segment_button.dart';
import '../../common_widget/up_coming_bill_row.dart';
import '../../common_widget/expense_barchat.dart';
import '../../view/add_subscription/update_expense.dart';
import '../../view/add_subscription/update_income_view.dart';
import '../../view/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  bool isIncome = true;
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ThemeController themeController = Get.find();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBackground = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).primaryColor;

    return GetBuilder<HomeController>(builder: (ctrl) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Enhanced Header Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      TColor.gray60.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Enhanced Header with Welcome Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Text(
                                    "Welcome back!",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Text(
                                    "Financial Overview",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsView(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.settings_outlined,
                                  size: 24,
                                  color: grayColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Enhanced Central Content
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Monthly Expense
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: cardBackground.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: grayColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Obx(() => Text(
                                          "${spendingCtrl.totalAmountSpending.value.toStringAsFixed(2)} Frw",
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Monthly Expenses",
                                      style: TextStyle(
                                        color: grayColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Monthly Income
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: cardBackground.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: grayColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Obx(() => Text(
                                          "${ctrl.totalIncome.value.toStringAsFixed(0)} Frw",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Monthly Income",
                                      style: TextStyle(
                                        color: grayColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Enhanced Statistics Cards
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              Obx(() => _buildEnhancedStatCard(
                                  "Total",
                                  spendingCtrl.totalSpendingCount.value.toString(),
                                  Icons.receipt_long_outlined,
                                  cardBackground,
                                  textColor,
                                  grayColor,
                                  Colors.orange)),
                              const SizedBox(width: 8),
                              Obx(() => _buildEnhancedStatCard(
                                  "Lowest",
                                  "${spendingCtrl.lowestSpending.value.toStringAsFixed(0)}",
                                  Icons.trending_down_outlined,
                                  cardBackground,
                                  textColor,
                                  grayColor,
                                  Colors.green)),
                              const SizedBox(width: 8),
                              Obx(() => _buildEnhancedStatCard(
                                  "Highest",
                                  "${spendingCtrl.highestSpending.value.toStringAsFixed(0)}",
                                  Icons.trending_up_outlined,
                                  cardBackground,
                                  textColor,
                                  grayColor,
                                  Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Enhanced Toggle Buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: grayColor.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentButton(
                        title: 'Expenses',
                        onPress: () {
                          setState(() {
                            isIncome = true;
                          });
                        },
                        isActive: isIncome,
                      ),
                    ),
                    Expanded(
                      child: SegmentButton(
                        title: 'Income',
                        onPress: () {
                          setState(() {
                            isIncome = false;
                          });
                        },
                        isActive: !isIncome,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Content Section with Enhanced Styling
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (!isIncome)
                      Obx(() {
                        if (ctrl.income.isEmpty) {
                          return _buildEmptyState(
                            "No Income This Month",
                            "Start tracking your income to see insights here.",
                            Icons.attach_money_outlined,
                            textColor,
                            grayColor,
                          );
                        }
                        return _buildContentSection(
                          title: "Income Overview",
                          child: Column(
                            children: [
                              Container(
                                height: 300,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: IncomeBarChart(),
                                ),
                              ),
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: ctrl.income.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final income = ctrl.income[index];
                                  return _buildEnhancedListItem(
                                    child: IncomeHomeRow(
                                      sObj: {
                                        "id": income.id,
                                        "name": income.name,
                                        "date": income.date,
                                        "price": income.amount.toString()
                                      },
                                      onPressed: () {},
                                      onUpdate: () {
                                        Get.to(() => UpdateIncomeView(id: income.id!));
                                      },
                                      onDelete: () => _showDeleteDialog(
                                        context,
                                        "income",
                                        () => ctrl.deleteIncome(income.id!),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          textColor: textColor,
                          cardBackground: cardBackground,
                        );
                      }),

                    if (isIncome)
                      Obx(() {
                        if (spendingCtrl.spending.isEmpty) {
                          return _buildEmptyState(
                            "No Expenses This Month",
                            "Start tracking your expenses to see insights here.",
                            Icons.receipt_outlined,
                            textColor,
                            grayColor,
                          );
                        }

                        return _buildContentSection(
                          title: "Expense Overview",
                          child: Column(
                            children: [
                              Container(
                                height: 300,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ExpenseBarChart(),
                                ),
                              ),
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: spendingCtrl.spending.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final spent = spendingCtrl.spending[index];
                                  return _buildEnhancedListItem(
                                    child: UpcomingBillRow(
                                      sObj: {
                                        "id": spent['id'],
                                        "name": spent['name'],
                                        "date": (spent['date'] as Timestamp).toDate(),
                                        "price": spent['amount'].toString()
                                      },
                                      onUpdate: () {
                                        Get.to(() => UpdateExpenseView(spent['id']));
                                      },
                                      onDelete: () => _showDeleteDialog(
                                        context,
                                        "expense",
                                        () => spendingCtrl.deleteSpending(spent['id']),
                                      ),
                                      onPressed: () {},
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          textColor: textColor,
                          cardBackground: cardBackground,
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEnhancedStatCard(
    String title,
    String value,
    IconData icon,
    Color background,
    Color textColor,
    Color grayColor,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: grayColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 14,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: grayColor,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  fontSize: 12,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required Widget child,
    required Color textColor,
    required Color cardBackground,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildEnhancedListItem({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    Color textColor,
    Color grayColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: grayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 48,
              color: grayColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: grayColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String type, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Confirm Deletion",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Are you sure you want to delete this $type?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}
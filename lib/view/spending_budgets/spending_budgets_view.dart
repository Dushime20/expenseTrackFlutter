import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common_widget/budgets_row.dart';
import 'package:untitled/common_widget/custom_arc_180_painter.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/view/add_subscription/add_subscription_view.dart';
import 'package:untitled/view/budget/add_budget_screen.dart';
import 'package:untitled/view/budget/update_budget_screen.dart';

class SpendingBudgetsView extends StatefulWidget {
  const SpendingBudgetsView({super.key});

  @override
  State<SpendingBudgetsView> createState() => _SpendingBudgetsViewState();
}

class _SpendingBudgetsViewState extends State<SpendingBudgetsView>
    with TickerProviderStateMixin {
  final ExpenseController expenseCtrl = Get.put(ExpenseController());
  bool _dialogShown = false;
  BuildContext? _dialogContext;

  // Animation controllers - make them nullable initially
  AnimationController? _mainController;
  AnimationController? _arcController;
  AnimationController? _cardController;

  // Animations - make them nullable initially
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController!,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController!,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController!,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _mainController?.forward();
    _arcController?.forward();

    // Delay card animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController?.forward();
    });
  }

  @override
  void dispose() {
    _mainController?.dispose();
    _arcController?.dispose();
    _cardController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final primaryColor = theme.primaryColor;

    return GetBuilder<BudgetController>(builder: (ctrl) {
      final bool hasBudget = ctrl.budgetList.isNotEmpty;
      final bObj = hasBudget ? ctrl.budgetList.first : null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final total = ctrl.totalBudgetAmount.value;
        final used = ctrl.usedBudgetAmount.value;

        if (total > 0) {
          final percentUsed = (used / total) * 100;

          if (percentUsed >= 75 && !_dialogShown) {
            _dialogShown = true;
            _showBudgetAlert(context, percentUsed);
          } else if (_dialogShown &&
              percentUsed < 75 &&
              _dialogContext != null) {
            Navigator.of(_dialogContext!).pop();
            _dialogShown = false;
            _dialogContext = null;
          }
        }
      });

      return Scaffold(
        backgroundColor: backgroundColor,
        body: _fadeAnimation == null
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading while animations initialize
            : AnimatedBuilder(
                animation: _fadeAnimation!,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation!.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation!.value),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            // Header with gradient
                            _buildHeader(context, primaryColor),

                            // Budget Arc Section
                            _buildBudgetArc(context, ctrl, media),

                            const SizedBox(height: 30),

                            // Budget Card
                            _buildEnhancedBudgetCard(ctrl, bObj, context),

                            const SizedBox(height: 30),

                            // Expense History Section
                            _buildExpenseHistoryHeader(context),

                            const SizedBox(height: 15),

                            // Expense List
                            _buildEnhancedExpenseList(),

                            const SizedBox(height: 20),

                            // Add Category Button
                            _buildEnhancedAddCategoryButton(context),

                            const SizedBox(height: 110),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Budget Overview",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track your spending habits",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetArc(
      BuildContext context, BudgetController ctrl, Size media) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _arcController == null
                  ? SizedBox(
                      width: media.width * 0.6,
                      height: media.width * 0.25,
                    )
                  : AnimatedBuilder(
                      animation: _arcController!,
                      builder: (context, child) {
                        return SizedBox(
                          width: media.width * 0.6,
                          height: media.width * 0.25,
                          child: CustomPaint(
                            painter: CustomArcPainter(
                              totalBudget: ctrl.totalBudgetAmount.value,
                              usedBudget: ctrl.usedBudgetAmount.value,
                              end: (ctrl.totalBudgetAmount.value == 0)
                                  ? 0
                                  : ((ctrl.usedBudgetAmount.value /
                                              ctrl.totalBudgetAmount.value)
                                          .clamp(0.0, 1.0) *
                                      _arcController!.value),
                            ),
                          ),
                        );
                      },
                    ),
              Column(
                children: [
                  const SizedBox(height: 10),
                  Obx(() => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          "${ctrl.totalBudgetAmount.value.toStringAsFixed(0)} Rwf",
                          key: ValueKey(ctrl.totalBudgetAmount.value),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    "Total Budget",
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Budget Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  "Used",
                  "${ctrl.usedBudgetAmount.value.toStringAsFixed(0)} Rwf",
                  Icons.trending_up,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  "Remaining",
                  "${ctrl.remainingBudgetAmount.value.toStringAsFixed(0)} Rwf",
                  Icons.account_balance,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBudgetCard(
      BudgetController ctrl, dynamic bObj, BuildContext context) {
    if (_scaleAnimation == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
        child: _buildBudgetCardContent(ctrl, bObj, context),
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation!.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: _buildBudgetCardContent(ctrl, bObj, context),
          ),
        );
      },
    );
  }

  Widget _buildBudgetCardContent(
      BudgetController ctrl, dynamic bObj, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Budget Management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your spending limits and track progress",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),
              onSelected: (value) {
                if (value == 'update' && bObj != null) {
                  DateTime _toDate(dynamic value) {
                    if (value is Timestamp) return value.toDate();
                    if (value is DateTime) return value;
                    return DateTime.now();
                  }

                  Get.to(() => UpdateBudgetScreen(
                        budgetId: bObj['id'] ?? '',
                        initialAmount: bObj['amount'] ?? 0.0,
                        initialStartDate: _toDate(bObj['startDate']),
                        initialEndDate: _toDate(bObj['endDate']),
                      ));
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'update',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Update Budget'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddBudgetScreen()),
            icon: const Icon(Icons.add),
            label: const Text("Manage Budget"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseHistoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Expense Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedExpenseList() {
    return Obx(() {
      if (expenseCtrl.expenseStatusList.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // ← ADD THIS BACK
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.category_outlined,
                size: 48,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "No Categories Yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Add your first expense category to start tracking",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: expenseCtrl.expenseStatusList.map((bObj) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BudgetsRow(
                bObj: bObj,
                onPressed: () {},
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildEnhancedAddCategoryButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: DottedBorder(
          dashPattern: const [8, 4],
          strokeWidth: 2,
          borderType: BorderType.RRect,
          radius: const Radius.circular(20),
          color: theme.primaryColor.withOpacity(0.3),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Get.to(() => const AddSubScriptionView()),
              child: Container(
                height: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.05),
                      theme.primaryColor.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Add New Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetAlert(BuildContext context, double percentUsed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Budget Alert'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have used ${percentUsed.toStringAsFixed(1)}% of your total budget.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Consider reviewing your spending to stay within budget.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(_dialogContext!).pop();
                _dialogShown = false;
                _dialogContext = null;
              },
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }
}

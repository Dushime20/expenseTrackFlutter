import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:untitled/view/add_subscription/add_subscription_view.dart';
import 'package:untitled/view/settings/settings_view.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';
import 'package:untitled/view/home/home_view.dart';

import '../../common/color_extension.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  PageStorageBucket pageStorageBucket = PageStorageBucket();
  Widget currentTabView = const HomeView();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageStorage(
            bucket: pageStorageBucket,
            child: currentTabView,
          ),

          // Fixed Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: TColor.back,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Home Tab
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectTab = 0;
                          currentTabView = const HomeView();
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/img/home.png",
                            width: 24,
                            height: 24,
                            color: selectTab == 0 ? TColor.line : TColor.gray60,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Home",
                            style: TextStyle(
                              color: selectTab == 0 ? TColor.line : TColor.gray60,
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ),

                    // Budget Tab
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectTab = 1;
                          currentTabView = const SpendingBudgetsView();
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/img/budgets.png",
                            width: 24,
                            height: 24,
                            color: selectTab == 1 ? TColor.line : TColor.gray60,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Budget",
                            style: TextStyle(
                              color: selectTab == 1 ? TColor.line : TColor.gray60,
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ),

                    // Add Tab
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectTab = 2;
                          currentTabView = const AddSubScriptionView();
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_box_outlined,
                            size: 24,
                            color: selectTab == 2 ? TColor.line : TColor.gray60,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Add Expense",
                            style: TextStyle(
                              color: selectTab == 2 ? TColor.line : TColor.gray60,
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ),

                    // Settings Tab
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectTab = 3;
                          currentTabView = const SettingsView();
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings,
                            size: 24,
                            color: selectTab == 3 ? TColor.line : TColor.gray60,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Settings",
                            style: TextStyle(
                              color: selectTab == 3 ? TColor.line : TColor.gray60,
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

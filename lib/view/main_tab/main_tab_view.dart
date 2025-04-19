import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/view/add_subscription/add_subscription_view.dart';
import 'package:untitled/view/search/search_screen.dart';
import 'package:untitled/view/settings/settings_view.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';

import '../../common/color_extension.dart';

import '../home/home_view.dart';

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
      body: Stack(children: [
        PageStorage(bucket: pageStorageBucket, child: currentTabView),
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: TColor.back, // background color
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectTab = 0;
                                    currentTabView = const HomeView();
                                  });
                                },
                                icon: Image.asset(
                                  "assets/img/home.png",
                                  width: 20,
                                  height: 20,
                                  color: selectTab == 0
                                      ? TColor.line
                                      : TColor.gray60,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectTab = 1;
                                    currentTabView =
                                        const SpendingBudgetsView();
                                  });
                                },
                                icon: Image.asset(
                                  "assets/img/budgets.png",
                                  width: 20,
                                  height: 20,
                                  color: selectTab == 1
                                     ? TColor.line
                                      : TColor.gray60,
                                ),
                              ),
                              const SizedBox(width: 50, height: 50),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectTab = 2;
                                    currentTabView = const SettingsView();
                                  });
                                },
                                icon: Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: selectTab == 2
                                      ? TColor.line
                                      : TColor.gray60,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectTab = 3;
                                    currentTabView = const SearchScreen();
                                  });
                                },
                                icon: Icon(
                                  Icons.search,
                                  size: 24,
                                  color: selectTab == 3
                                    ? TColor.line
                                      : TColor.gray60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(const AddSubScriptionView());
                      },
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: TColor.line,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}

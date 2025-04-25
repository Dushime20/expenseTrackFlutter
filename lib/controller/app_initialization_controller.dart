import 'package:get/get.dart';

import 'budgetController.dart';
import 'categoryController.dart';
import 'home_controller.dart';

class AppInitializationController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final BudgetController budgetController = Get.find<BudgetController>();

  // Method to initialize all the controllers
  Future<void> initialize() async {
    await homeController.fetchIncome();
    await homeController.fetchExpense();
    await homeController.fetchExpenseStatus();
    await homeController.fetchMonthlyIncomeAndExpense();
    await homeController.loadExpenseStats();

    await budgetController.fetchBudget();
    await budgetController.getCurrentMonthBudgetStatus();
    await budgetController.loadBudgetStatus();
    await budgetController.loadBudgetsByCategory();

    await categoryController.fetchCategory();
  }
}

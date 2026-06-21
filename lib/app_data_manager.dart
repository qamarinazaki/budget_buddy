import 'package:flutter/material.dart';

class AppDataManager {

  // =========================
  // FINANCIAL DATA
  // =========================

  static double totalIncome = 0;
  static double totalExpense = 0;
  static double totalSaving = 0;

  // =========================
// PROFILE DATA
// =========================

  static String userName = "";
  static String userEmail = "";
  static String userPassword = "";
  static String userPhone = "";
  static String course = "";
  static String studyYear = "";
  static double monthlyBudget = 0;
  static String financialGoal = "";

  // =========================
// BUDGET DATA
// =========================

  static double foodBudget = 0;
  static double transportBudget = 0;
  static double entertainmentBudget = 0;
  static double educationBudget = 0;
  static double medicalBudget = 0;
  static double othersBudget = 0;

  static List<Map<String, dynamic>> incomeRecords = [];
  static List<Map<String, dynamic>> expenseRecords = [];
  static List<Map<String, dynamic>> savingGoals = [];

  // =========================
  // REWARDS DATA
  // =========================

  static ValueNotifier<int> rewardPoints = ValueNotifier(0);

  static ValueNotifier<List<String>> claimedVouchers =
  ValueNotifier([]);
  static ValueNotifier<List<String>> usedVouchers =
  ValueNotifier([]);

  static List<String> unlockedBadges = [];

  // =========================
  // INCOME
  // =========================

  static void addIncome(
      String source,
      double amount,
      ) {
    totalIncome += amount;

    incomeRecords.add({
      "source": source,
      "amount": amount,
    });

    rewardPoints.value += 5;

    _checkBadges();
  }

  // =========================
  // EXPENSE
  // =========================

  static void addExpense(
      String category,
      double amount,
      ) {

    totalExpense += amount;

    expenseRecords.add({
      "category": category,
      "amount": amount,
      "date": DateTime.now(),
    });

    rewardPoints.value += 1;

    _checkBadges();
  }

  // =========================
  // SAVING GOALS
  // =========================

  static void addSavingGoal(
      String name,
      double target,
      double saved,
      ) {
    totalSaving += saved;

    savingGoals.add({
      "name": name,
      "target": target,
      "saved": saved,
    });

    rewardPoints.value += 10;

    _checkBadges();
  }

  // =========================
  // UPDATE EXPENSE
  // =========================

  static void updateExpense(
      double amount,
      ) {
    totalExpense = amount;
  }

  // =========================
  // CAMPUS DEALS
  // =========================

  static void claimVoucher(String voucherCode) {

    if (!claimedVouchers.value.contains(voucherCode)) {

      claimedVouchers.value = [
        ...claimedVouchers.value,
        voucherCode,
      ];

      rewardPoints.value += 10;

      _checkBadges();
    }
  }
  static void useVoucher(String voucherCode) {

    if (!usedVouchers.value.contains(voucherCode)) {

      usedVouchers.value = [
        ...usedVouchers.value,
        voucherCode,
      ];
    }
  }

  // =========================
  // BADGES
  // =========================

  static void _checkBadges() {

    if (rewardPoints.value >= 50 &&
        !unlockedBadges.contains("Budget Boss")) {

      unlockedBadges.add("Budget Boss");
    }

    if (rewardPoints.value >= 100 &&
        !unlockedBadges.contains("Vault Master")) {

      unlockedBadges.add("Vault Master");
    }

    if (rewardPoints.value >= 150 &&
        !unlockedBadges.contains("Value Voyage")) {

      unlockedBadges.add("Value Voyage");
    }
  }

  // =========================
  // RESET DATA
  // =========================

  static void resetAllData() {

    totalIncome = 0;
    totalExpense = 0;
    totalSaving = 0;

    //userName = "";
    //userEmail = "";
    //userPassword = "";
    //userPhone = "";
    //course = "";
    //studyYear = "";
    //monthlyBudget = 0;
    //financialGoal = "";

    foodBudget = 0;
    transportBudget = 0;
    entertainmentBudget = 0;
    educationBudget = 0;
    medicalBudget = 0;
    othersBudget = 0;

    rewardPoints.value = 0;

    incomeRecords.clear();
    expenseRecords.clear();
    savingGoals.clear();

    claimedVouchers.value = [];
    usedVouchers.value = [];
    unlockedBadges.clear();
  }
}
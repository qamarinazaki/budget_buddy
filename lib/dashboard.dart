import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'budget_plan.dart';
import 'expense_tracker.dart';
import 'income_tracker.dart';
import 'app_data_manager.dart';

class BudgetBuddyDashboard extends StatefulWidget {
  final String userName;
  final String userEmail;

  const BudgetBuddyDashboard({
    super.key,
    this.userName = 'User',
    this.userEmail = 'user@example.com'
  });

  @override
  State<BudgetBuddyDashboard> createState() => _BudgetBuddyDashboardState();
}

class _BudgetBuddyDashboardState extends State<BudgetBuddyDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .get();

    final incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .get();

    final savingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saving_goals')
        .get();

    AppDataManager.totalIncome = 0;

    for (var doc in incomeSnapshot.docs) {
      AppDataManager.totalIncome +=
          (doc['amount'] as num).toDouble();
    }

    AppDataManager.totalExpense = 0;

    for (var doc in expenseSnapshot.docs) {
      AppDataManager.totalExpense +=
          (doc['amount'] as num).toDouble();
    }

    AppDataManager.totalSaving = 0;

    for (var doc in savingSnapshot.docs) {
      AppDataManager.totalSaving +=
          (doc['saved'] as num).toDouble();
    }

    AppDataManager.savingGoals.clear();

    for (var doc in savingSnapshot.docs) {
      AppDataManager.savingGoals.add({
        "id": doc.id,
        "name": doc["name"],
        "target": doc["target"],
        "saved": doc["saved"],
      });
    }

    if (!mounted) return;

    setState(() {});
  }

  double get totalBudget {
    return AppDataManager.foodBudget +
        AppDataManager.transportBudget +
        AppDataManager.entertainmentBudget +
        AppDataManager.educationBudget +
        AppDataManager.medicalBudget +
        AppDataManager.othersBudget;
  }

  double get budgetUsage {
    return totalBudget == 0
        ? 0
        : AppDataManager.totalExpense /
        totalBudget;
  }

  String get budgetPercent {
    double percent =
    budgetUsage > 1 ? 1 : budgetUsage;

    return '${(percent * 100).toStringAsFixed(0)}%';
  }

  double get savingUsage {
    return AppDataManager.totalIncome == 0
        ? 0
        : AppDataManager.totalSaving /
        AppDataManager.totalIncome;
  }

  String get savingPercent {
    return '${(savingUsage * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'BUDGET buddy',
          style: GoogleFonts.permanentMarker(
            color: Colors.orangeAccent,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFAD1457),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildStudentHeader(),

            // 1. Current Balance Card
            _buildBalanceCard(),

            const SizedBox(height: 8),

            // 2. Stats Grid (Income, Expense, Savings, Goals) - All Clickable
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
                children: [
                  _buildStatCard(
                    context,
                    'Income',
                    'RM ${AppDataManager.totalIncome.toStringAsFixed(2)}',
                    Icons.arrow_downward_rounded,
                    Colors.green,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IncomeTracker())),
                  ),
                  _buildStatCard(
                    context,
                    'Expense',
                    'RM ${AppDataManager.totalExpense.toStringAsFixed(2)}',
                    Icons.arrow_upward_rounded,
                    Colors.red,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseTrackerPage())),
                  ),
                  _buildStatCard(
                    context,
                    'Savings',
                    'RM ${AppDataManager.totalSaving.toStringAsFixed(2)}',
                    Icons.savings_rounded,
                    Colors.orange,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const BudgetPage(
                          scrollToGoals: true,
                        ),
                      ),
                    ),
                  ),
                  _buildStatCard(
                    context,
                    'Goals',
                    AppDataManager.savingGoals.length.toString(),
                    Icons.flag_rounded,
                    Colors.purple,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const BudgetPage(
                          scrollToGoals: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Financial Progress Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Financial Progress',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Progress Bars (Also clickable to Budget Planner)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetPage())),
              child: _buildProgressCard(
                'Budget Usage',
                budgetUsage,
                budgetPercent,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const BudgetPage(
                    scrollToGoals: true,
                  ),
                ),
              ),
              child: _buildProgressCard(
                'Savings Progress',
                savingUsage,
                savingPercent,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  Widget _buildStudentHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        10,
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 28,
            backgroundColor:
            const Color(0xFFAD1457),
            child: Text(
              widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  'Welcome Back,',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.userName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.userEmail,
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${AppDataManager.course} • Year ${AppDataManager.studyYear}',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB6C1),
            Color(0xFFC2185B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAD1457).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Balance',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'RM ${(AppDataManager.totalIncome -
                AppDataManager.totalExpense).toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress, String percent) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                percent,
                style: GoogleFonts.inter(
                  color: const Color(0xFFAD1457),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFFCE4EC),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD81B60)),
            ),
          ),
        ],
      ),
    );
  }
}
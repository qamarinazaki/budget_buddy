import 'package:flutter/material.dart';
import 'app_data_manager.dart';

class BudgetBuddyDashboard extends StatelessWidget {
  const BudgetBuddyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    double balance =
        AppDataManager.totalIncome - AppDataManager.totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFC2185B),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "RM ${balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: _buildSummaryCard(
                  "Income",
                  "RM ${AppDataManager.totalIncome.toStringAsFixed(2)}",
                  Icons.arrow_downward,
                  Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildSummaryCard(
                  "Expense",
                  "RM ${AppDataManager.totalExpense.toStringAsFixed(2)}",
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: _buildSummaryCard(
                  "Savings",
                  "RM ${AppDataManager.totalSaving.toStringAsFixed(2)}",
                  Icons.savings,
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildSummaryCard(
                  "Goals",
                  "${AppDataManager.savingGoals.length}",
                  Icons.flag,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          _buildSectionTitle("Financial Progress"),

          const SizedBox(height: 15),

          _buildProgressCard(
            title: "Budget Usage",
            progress: AppDataManager.totalIncome == 0
                ? 0
                : (AppDataManager.totalExpense /
                AppDataManager.totalIncome)
                .clamp(0.0, 1.0),
            color: Colors.redAccent,
          ),

          const SizedBox(height: 15),

          _buildProgressCard(
            title: "Savings Progress",
            progress: AppDataManager.totalIncome == 0
                ? 0
                : (AppDataManager.totalSaving /
                AppDataManager.totalIncome)
                .clamp(0.0, 1.0),
            color: Colors.green,
          ),

          const SizedBox(height: 25),

          _buildSectionTitle("Financial Summary"),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Column(
              children: [

                _summaryRow(
                  "Income Records",
                  "${AppDataManager.incomeRecords.length}",
                ),

                const Divider(),

                _summaryRow(
                  "Saving Goals",
                  "${AppDataManager.savingGoals.length}",
                ),

                const Divider(),

                _summaryRow(
                  "Current Savings",
                  "RM ${AppDataManager.totalSaving.toStringAsFixed(2)}",
                ),

                const Divider(),

                _summaryRow(
                  "Current Balance",
                  "RM ${balance.toStringAsFixed(2)}",
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildSectionTitle("Recent Activity"),

          const SizedBox(height: 15),

          _activityCard(
            Icons.check_circle,
            "Income Added",
            Colors.green,
          ),

          _activityCard(
            Icons.account_balance_wallet,
            "Budget Updated",
            Colors.orange,
          ),

          _activityCard(
            Icons.savings,
            "Saving Goal Updated",
            Colors.purple,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFC2185B),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(title),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            color: color,
            backgroundColor: Colors.grey.shade200,
          ),

          const SizedBox(height: 8),

          Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _activityCard(
      IconData icon,
      String title,
      Color color,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'analytics_report.dart';
import 'community_tips_forum.dart';
import 'income_tracker.dart';

void main() {
  runApp(const BudgetBuddyApp());
}

class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Buddy'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text(
                'Manage Your Money Wisely',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildNavButton(
                context,
                icon: Icons.add_chart,
                label: 'Income Tracker',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IncomeTracker()),
                ),
              ),
              const SizedBox(height: 16),
              _buildNavButton(
                context,
                icon: Icons.analytics,
                label: 'View Analytics & Reports',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalyticsReport()),
                ),
              ),
              const SizedBox(height: 16),
              _buildNavButton(
                context,
                icon: Icons.forum,
                label: 'Community Tips Forum',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityTipsForum()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

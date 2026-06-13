import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'budget_plan.dart';
import 'community_tips_forum.dart';
import 'bill_reminder.dart';
import 'expense_tracker.dart';
import 'income_tracker.dart';
import 'campus_deals.dart';
import 'reward.dart';
import 'analytics_report.dart';
import 'setting.dart';

void main() {
  runApp(const BudgetBuddyApp());
}

class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Buddy',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildHomePage()
          : _selectedIndex == 1
          ? const ExpenseTrackerPage()
          : _selectedIndex == 2
          ? const BudgetPage()
          : _buildMorePage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFB6C1),
        selectedItemColor: const Color(0xFFC2185B),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Expense",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Budget",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: "More",
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Budget Buddy",
          style: TextStyle(
            color: Color(0xFFC2185B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFC2185B),
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Welcome Back 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Student Financial Assistant",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Student Profile
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Student User"),
                subtitle: const Text(
                  "Software Engineering • Year 3",
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Financial Quote
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '"Small savings today create bigger opportunities tomorrow."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Financial Snapshot
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
              child: const Column(
                children: [

                  Text(
                    "Financial Snapshot",
                    style: TextStyle(
                      color: Color(0xFFC2185B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      Column(
                        children: [
                          Icon(Icons.account_balance_wallet),
                          SizedBox(height: 5),
                          Text("RM 1200"),
                          Text("Balance"),
                        ],
                      ),

                      Column(
                        children: [
                          Icon(Icons.savings),
                          SizedBox(height: 5),
                          Text("RM 500"),
                          Text("Savings"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Upcoming Bills
            Card(
              child: Column(
                children: const [

                  ListTile(
                    leading: Icon(
                      Icons.wifi,
                      color: Colors.orange,
                    ),
                    title: Text("Internet"),
                    subtitle: Text("Due: 25 June"),
                  ),

                  Divider(),

                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Colors.red,
                    ),
                    title: Text("Room Rental"),
                    subtitle: Text("Due: 30 June"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Recent Activity
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
              child: const Column(
                children: [

                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      color: Color(0xFFC2185B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Income Added"),
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                    ),
                    title: Text("Budget Updated"),
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.purple,
                    ),
                    title: Text("Saving Goal Updated"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildMorePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "More",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.add_chart,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Income Tracker"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IncomeTracker(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Bill Reminder"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BillReminderPage(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.local_offer,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Campus Deals"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CampusDealsPage(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.forum,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Community Forum"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CommunityTipsForum(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Dashboard"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BudgetBuddyDashboard(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.analytics,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Analytics Report"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnalyticsReport(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.card_giftcard,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Rewards"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RewardsPage(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Profile"),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.settings,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

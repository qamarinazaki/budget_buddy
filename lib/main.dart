import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';


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
import 'profile.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return MainDashboard(
              userName: snapshot.data?.displayName ?? 'User',
              userEmail: snapshot.data?.email ?? '',
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {

  final String userName;
  final String userEmail;

  const MainDashboard({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<MainDashboard> createState() =>
      _MainDashboardState();
}
class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? BudgetBuddyDashboard(
        userName: widget.userName,
        userEmail: widget.userEmail,
      )
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
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
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

  Widget _buildMorePage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "More",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.analytics,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Analytics & Report"),
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

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.person,
                color: Color(0xFFC2185B),
              ),
              title: const Text("Profile"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

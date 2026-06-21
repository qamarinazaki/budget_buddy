import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool smartReminder = true;
  bool communityAlerts = false;
  bool billReminderNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
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
        padding: const EdgeInsets.all(20),
        children: [

                  const Text(
                    "PREFERENCES",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),


                  SwitchListTile(
                    activeColor: const Color(0xFFD81B60),
                    title: const Text(
                      "Smart Budget Reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: const Text(
                      "Receive triggers when overspending",
                    ),
                    value: smartReminder,
                    onChanged: (v) {
                      setState(() {
                        smartReminder = v;
                      });
                    },
                  ),

                  SwitchListTile(
                    activeColor: const Color(0xFFD81B60),
                    title: const Text(
                      "Community Alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: const Text(
                      "Get notifications on forum topics",
                    ),
                    value: communityAlerts,
                    onChanged: (v) {
                      setState(() {
                        communityAlerts = v;
                      });
                    },
                  ),
          SwitchListTile(
            activeColor: const Color(0xFFD81B60),
            title: const Text(
              "Bill Reminder Notifications",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: const Text(
              "Receive reminders for upcoming bills",
            ),
            value: billReminderNotifications,
            onChanged: (v) {
              setState(() {
                billReminderNotifications = v;
              });
            },
          ),

                  const Divider(height: 40),

                  const Text(
                    "DATA & BACKUP",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.download,
              color: Color(0xFFD81B60),
            ),
            title: const Text(
              "Export Expense Report",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFD81B60),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Expense report exported successfully",
                  ),
                ),
              );
            },
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.delete_outline,
              color: Color(0xFFD81B60),
            ),
            title: const Text(
              "Reset All Data",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFD81B60),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Reset All Data"),
                  content: const Text(
                    "Are you sure you want to delete all records?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {

                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {

                          final snapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('claimed_vouchers')
                              .get();

                          for (var doc in snapshot.docs) {
                            await doc.reference.delete();
                          }
                        }

                        AppDataManager.resetAllData();

                        if (!context.mounted) return;

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "All data has been reset",
                            ),
                          ),
                        );
                      },
                      child: const Text("Reset"),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 40),

          const Text(
            "ABOUT",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.info_outline,
              color: Color(0xFFD81B60),
            ),
            title: const Text(
              "About BudgetBuddy",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFD81B60),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text("About BudgetBuddy"),
                  content: Text(
                    "BudgetBuddy is a personal finance management application designed to help students track expenses, manage savings goals, monitor budgets and redeem rewards.",
                  ),
                ),
              );
            },
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.verified_outlined,
              color: Color(0xFFD81B60),
            ),
            title: const Text(
              "App Version 1.0",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFD81B60),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text("Version"),
                  content: Text("BudgetBuddy v1.0"),
                ),
              );
            },
          ),
                ],
              ),
            );
  }

  Widget _settingTile(
      IconData icon,
      String title,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: const Color(0xFFD81B60),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD81B60),
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFD81B60),
      ),
    );
  }
}
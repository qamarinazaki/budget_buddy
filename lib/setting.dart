import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool smartReminder = true;
  bool communityAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EEF1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFD81B60),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.menu, color: Colors.white, size: 30),
                    Spacer(),
                    Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _settingTile(
                    Icons.lock_outline,
                    "Change Password",
                  ),

                  _settingTile(
                    Icons.person_outline,
                    "Update Profile",
                  ),

                  const Divider(height: 40),

                  const Text(
                    "PREFERENCES",
                    style: TextStyle(
                      color: Color(0xFFD81B60),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _settingTile(
                    Icons.category_outlined,
                    "MANAGE CATEGORIES",
                  ),

                  SwitchListTile(
                    activeColor: const Color(0xFFD81B60),
                    title: const Text(
                      "Smart Budget Reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
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
                        color: Color(0xFFD81B60),
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

                  const Divider(height: 40),

                  const Text(
                    "DATA & BACKUP",
                    style: TextStyle(
                      color: Color(0xFFD81B60),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _settingTile(
                    Icons.download,
                    "Export Expense Report (CSV)",
                  ),

                  _settingTile(
                    Icons.delete_outline,
                    "Reset All Data",
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD81B60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "LOG OUT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
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
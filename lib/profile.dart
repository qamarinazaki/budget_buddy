import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'account_manager.dart';
import 'login_screen.dart';
import 'dashboard.dart';


class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  void _showPersonalDetails(BuildContext context) {
    final user = AccountManager.currentAccount;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Personal Details',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildDetailItem('Full Name', user.name, Icons.person_outline),
              _buildDetailItem('Email Address', user.email, Icons.email_outlined),
              _buildDetailItem('Phone Number', user.phone, Icons.phone_outlined),
              _buildDetailItem('Password', '••••••••', Icons.lock_outline),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  void _showRegistrationDetails(
      BuildContext context) {

    final user =
        AccountManager.currentAccount;

    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor:
      const Color(0xFF0F172A),
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return Container(
          padding:
          const EdgeInsets.all(30),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white10,
                    borderRadius:
                    BorderRadius
                        .circular(
                      10,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              Text(
                'Registration Details',
                style:
                GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              _buildDetailItem(
                'Course',
                user.course,
                Icons.school_outlined,
              ),

              _buildDetailItem(
                'Study Year',
                user.studyYear,
                Icons.calendar_today_outlined,
              ),

              const SizedBox(
                height: 40,
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child:
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(
                        context,
                      ),
                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    Colors
                        .orangeAccent,
                    foregroundColor:
                    Colors.black,
                  ),
                  child: const Text(
                    'Close',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.orangeAccent, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
              Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSignOutOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sign Out', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                title: const Text('Sign out this account', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await AccountManager.signOutThisAccount();
                  if (!context.mounted) return;
                  if (AccountManager.allAccounts.isNotEmpty) {
                    final nextUser = AccountManager.currentAccount!;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BudgetBuddyDashboard(
                          userName: nextUser.name,
                          userEmail: nextUser.email,
                        ),
                      ),
                          (route) => false,
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_remove_outlined, color: Colors.redAccent),
                title: const Text('Sign out all accounts', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await AccountManager.signOutAllAccounts();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAccountSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Switch Account', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ...AccountManager.allAccounts.map((acc) {
                bool isCurrent = acc.email == userEmail;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.white10, child: Text(acc.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                  title: Text(acc.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(acc.email, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: isCurrent ? const Icon(Icons.check_circle, color: Colors.greenAccent) : null,
                  onTap: () async {
                    if (!isCurrent) {
                      int idx = AccountManager.allAccounts.indexOf(acc);
                      await AccountManager.switchAccount(idx);
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen(userName: acc.name, userEmail: acc.email)),
                            (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                );
              }),
              const Divider(color: Colors.white10, height: 32),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.add, color: Colors.black)),
                title: const Text('Add Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(
      BuildContext context) {

    final passwordController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Change Password",
          ),
          content: TextField(
            controller:
            passwordController,
            obscureText: true,
            decoration:
            const InputDecoration(
              labelText:
              "New Password",
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                final messenger =
                ScaffoldMessenger.of(
                  context,
                );

                if (passwordController
                    .text
                    .length <
                    6) {

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password must be at least 6 characters.",
                      ),
                    ),
                  );
                  return;
                }

                try {

                  await FirebaseAuth
                      .instance
                      .currentUser
                      ?.updatePassword(
                    passwordController
                        .text,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                  );

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password updated successfully.",
                      ),
                    ),
                  );

                } catch (e) {

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Failed to update password.",
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: Colors.black,
            ),
            onPressed: () =>
                _showPersonalDetails(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      /*drawer: AppDrawer(userName: userName, userEmail: userEmail, currentRoute: 'profile'),*/
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: _buildGlow(Colors.purpleAccent.withValues(alpha: 0.15), 400)),
          Positioned(bottom: 100, left: -100, child: _buildGlow(Colors.blueAccent.withValues(alpha: 0.1), 400)),

          SafeArea(
            child: CustomScrollView(
              slivers: [


                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _showAccountSwitcher(context),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5), width: 2),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: CircleAvatar(radius: 60, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ariff')),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _showAccountSwitcher(context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(20)),
                              child: Text('PRO MEMBER', style: GoogleFonts.inter(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(userName, style: GoogleFonts.inter(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
                      Text(userEmail, style: GoogleFonts.inter(color: Colors.black, fontSize: 14)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMenuTile(
                        Icons.person_outline_rounded,
                        'Personal Details',
                        'Name, Email, Phone',
                        Colors.blueAccent,
                        onTap: () => _showPersonalDetails(context),
                      ),
                      _buildMenuTile(
                        Icons.lock_outline,
                        'Change Password',
                        'Update your account password',
                        Colors.redAccent,
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      _buildMenuTile(
                        Icons.edit_note,
                        'Registration Details',
                        'Course & Study Year',
                        Colors.orangeAccent,
                        onTap: () =>
                            _showRegistrationDetails(context),
                      ),

                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(colors: [Colors.redAccent.withValues(alpha: 0.1), Colors.transparent]),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _showSignOutOptions(context),
                          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                          label: Text('SIGN OUT', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])));
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white , borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)), Text(subtitle, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12))])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
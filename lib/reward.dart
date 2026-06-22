import 'package:flutter/material.dart';
import 'app_data_manager.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

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
          "Rewards",
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
            children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFD81B60),
                          child: Text(
                            AppDataManager.userName.isNotEmpty
                                ? AppDataManager.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          AppDataManager.userName,
                          style: TextStyle(
                            color: Color(0xFFD81B60),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),

                    ValueListenableBuilder<int>(
                      valueListenable: AppDataManager.rewardPoints,
                      builder: (context, points, child) {
                        return Text(
                          "$points Points",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD81B60),
                          ),
                        );
                      },
                    ),

                    ValueListenableBuilder<int>(
                      valueListenable: AppDataManager.rewardPoints,
                      builder: (context, points, child) {
                        return LinearProgressIndicator(
                          value: points / 150,
                          minHeight: 16,
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFFD81B60),
                          backgroundColor: Colors.white,
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "CURRENT ACHIEVEMENTS",
                      style: TextStyle(
                        color: Color(0xFFD81B60),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 30),

              ValueListenableBuilder<List<String>>(
                valueListenable: AppDataManager.unlockedBadges,
                builder: (context, badges, child) {
                  return Column(
                    children: badges.map((badge) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _achievement(
                          badge,
                          1.0,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

                    const SizedBox(height: 60),

              const Text(
                "REWARD VOUCHERS",
                style: TextStyle(
                  color: Color(0xFFD81B60),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 20),

              ValueListenableBuilder<List<String>>(
                valueListenable: AppDataManager.claimedVouchers,
                builder: (context, vouchers, child) {
                  return Column(
                    children: vouchers.map((voucher) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _voucherCard(
                          context,
                          Icons.card_giftcard,
                          voucher,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 40),

              const Text(
                "POINT REDEMPTION",
                style: TextStyle(
                  color: Color(0xFFD81B60),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 20),

              _rewardItem(
                context,
                "RM5 Voucher",
                50,
              ),

              _rewardItem(
                context,
                "RM10 Voucher",
                100,
              ),
          ],
        ),
      ),
    );
  }

  Widget _achievement(String title, double value) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFD81B60),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: value,
          minHeight: 12,
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFD81B60),
          backgroundColor: Colors.white,
        ),
      ],
    );
  }

  Widget _voucherCard(
      BuildContext context,
      IconData icon,
      String title,
      ) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: AppDataManager.usedVouchers,
      builder: (context, usedVouchers, child) {

        bool used = usedVouchers.contains(title);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: used
                ? Colors.grey.shade300
                : const Color(0xFFF3C4D4),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFD81B60),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFD81B60),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: used
                    ? null
                    : () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Voucher Code"),
                      content: Text(
                        "Show this voucher code:\n\n$title",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Close"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            AppDataManager.useVoucher(title);
                            Navigator.pop(context);
                          },
                          child: const Text("Use"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  used ? "Used" : "Use",
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _rewardItem(
      BuildContext context,
      String title,
      int pointsNeeded,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title ($pointsNeeded Points)",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD81B60),
              ),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD81B60),
            ),
            onPressed: () {

              if (AppDataManager.rewardPoints.value <
                  pointsNeeded) {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Not enough points",
                    ),
                  ),
                );

                return;
              }

              AppDataManager.rewardPoints.value -=
                  pointsNeeded;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "$title claimed successfully",
                  ),
                ),
              );
            },
            child: const Text(
              "Claim",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
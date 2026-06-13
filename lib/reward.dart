import 'package:flutter/material.dart';
import 'app_data_manager.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

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
                      "Rewards",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFD81B60),
                          child: Icon(Icons.person,
                              color: Colors.white, size: 40),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "FAKHRIL HAIKAL",
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

                    Column(
                      children: AppDataManager.unlockedBadges.map((badge) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _achievement(
                            badge,
                            1.0,
                          ),
                        );
                      }).toList(),
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
                          Icons.card_giftcard,
                          voucher,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
                  ],
                ),
              ),
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

  Widget _voucherCard(IconData icon, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3C4D4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFD81B60)),
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
    );
  }
}
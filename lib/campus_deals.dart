import 'package:flutter/material.dart';
import 'app_data_manager.dart';

class CampusDealsPage extends StatefulWidget {
  const CampusDealsPage({super.key});

  @override
  State<CampusDealsPage> createState() => _CampusDealsPageState();
}

class Deal {
  final String title;
  final String description;
  final String category;
  final String voucher;
  final IconData icon;
  final double x;
  final double y;
  final String distance;
  bool isClaimed;

  Deal({
    required this.title,
    required this.description,
    required this.category,
    required this.voucher,
    required this.icon,
    required this.x,
    required this.y,
    required this.distance,
    this.isClaimed = false,
  });
}

class _CampusDealsPageState extends State<CampusDealsPage> {
  String selectedCategory = "All";
  Deal? selectedDeal;

  final List<Deal> campusDeals = [
    Deal(
      title: "Campus Cafe",
      description: "10% Student Discount",
      category: "Food",
      voucher: "CAFE10",
      icon: Icons.restaurant,
      x: 0.25,
      y: 0.30,
      distance: "120m",
    ),
    Deal(
      title: "Printing Shop",
      description: "RM0.05 per page",
      category: "Printing",
      voucher: "PRINT5",
      icon: Icons.print,
      x: 0.55,
      y: 0.45,
      distance: "80m",
    ),
    Deal(
      title: "Laundry Service",
      description: "Wash 5kg Free Dry",
      category: "Laundry",
      voucher: "WASH5",
      icon: Icons.local_laundry_service,
      x: 0.75,
      y: 0.25,
      distance: "250m",
    ),
    Deal(
      title: "Bus Transit",
      description: "RM1 Student Fare",
      category: "Transit",
      voucher: "BUS1",
      icon: Icons.directions_bus,
      x: 0.40,
      y: 0.70,
      distance: "300m",
    ),
  ];

  void _redeemVoucher(Deal deal) {

    AppDataManager.claimVoucher(
      deal.voucher,
    );
    setState(() {
      deal.isClaimed = true;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Voucher Claimed"),
        content: Text(
          "Voucher Code:\n\n${deal.voucher}"
              "\n\n+10 Reward Points"
              "\n\nUse this voucher at ${deal.title}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Deal> filteredDeals = selectedCategory == "All"
        ? campusDeals
        : campusDeals
        .where((d) => d.category == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F5),
      appBar: AppBar(
        title: const Text(
          "Campus Deals",
          style: TextStyle(
            color: Color(0xFFC2185B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                _filterChip("All"),
                _filterChip("Food"),
                _filterChip("Printing"),
                _filterChip("Laundry"),
                _filterChip("Transit"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          _buildMap(),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredDeals.length,
              itemBuilder: (context, index) {
                return _buildDealCard(filteredDeals[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String category) {
    bool active = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(category),
        selected: active,
        selectedColor: const Color(0xFFD81B60),
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) {
          setState(() {
            selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BBD0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD81B60),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 30,
            ),
          ),

          ...campusDeals.map((deal) {
            bool selected = selectedDeal == deal;

            return Positioned(
              left: deal.x * 300,
              top: deal.y * 140,
              child: Icon(
                Icons.location_on,
                color: selected
                    ? Colors.red
                    : const Color(0xFFD81B60),
                size: selected ? 35 : 25,
              ),
            );
          }),

          if (selectedDeal != null)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Distance: ${selectedDeal!.distance}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDealCard(Deal deal) {
    bool selected = selectedDeal == deal;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: deal.isClaimed
            ? Colors.grey.shade400
            : selected
            ? const Color(0xFFC2185B)
            : const Color(0xFFD81B60),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(
          deal.icon,
          color: Colors.white,
          size: 40,
        ),
        title: Text(
          deal.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          deal.description,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: Icon(
          deal.isClaimed
              ? Icons.check_circle
              : Icons.card_giftcard,
          color: Colors.white,
        ),
        onTap: () {
          setState(() {
            selectedDeal = deal;
          });
        },
        onLongPress: () {
          _redeemVoucher(deal);
        },
      ),
    );
  }
}
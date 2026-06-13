import 'package:flutter/material.dart';
import 'app_data_manager.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController noteController =
  TextEditingController();

  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();
  DateTime selectedMonth = DateTime.now();

  final List<String> categories = [
    "Food",
    "Transport",
    "Printing",
    "Entertainment",
    "Others",
  ];
  final List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /*Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(
          picked.year,
          picked.month,
        );
      });
    }
  }*/

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;

      case "Transport":
        return Icons.directions_car;

      case "Printing":
        return Icons.print;

      case "Entertainment":
        return Icons.movie;

      case "Others":
        return Icons.category;

      default:
        return Icons.receipt_long;
    }
  }
  List<Map<String, dynamic>> get filteredExpenses {
    return AppDataManager.expenseRecords.where((expense) {
      DateTime expenseDate = expense["date"];

      return expenseDate.month == selectedMonth.month &&
          expenseDate.year == selectedMonth.year;
    }).toList();
  }



  double get monthlyTotalExpense {
    double total = 0;

    for (var expense in filteredExpenses) {
      total += expense["amount"];
    }

    return total;
  }

  void _saveExpense() {
    if (amountController.text.isEmpty) return;

    double amount =
        double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return;

    AppDataManager.expenseRecords.add({
      "category": selectedCategory,
      "amount": amount,
      "date": selectedDate,
      "note": noteController.text,
    });

    AppDataManager.totalExpense += amount;

    AppDataManager.rewardPoints.value += 1;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Expense Saved (+1 Reward Point)",
        ),
      ),
    );

    setState(() {
      amountController.clear();
      noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EEF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        title: const Text(
          "Expense Tracker",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Expense Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
              ),
            ),


            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount (RM)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFD81B60),
                ),
                onPressed: _saveExpense,
                child: const Text(
                  "Save Expense",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EC),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFD81B60),
                ),
              ),
              child: Row(
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFFD81B60),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                          selectedMonth.year,
                          selectedMonth.month - 1,
                        );
                      });
                    },
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Expense Month",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFD81B60),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                          selectedMonth.year,
                          selectedMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFFD81B60),
                ),
                title: const Text(
                  "Total Expenses",
                ),
                subtitle: Text(
                  "RM ${monthlyTotalExpense.toStringAsFixed(2)}",
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount:
                filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense =
                  filteredExpenses[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        const Color(0xFFD81B60).withOpacity(0.15),
                        child: Icon(
                          getCategoryIcon(expense["category"]),
                          color: const Color(0xFFD81B60),
                        ),
                      ),

                      title: Text(
                        expense["category"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          Text(
                            "${expense["date"].day}/${expense["date"].month}/${expense["date"].year}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),

                          Text(
                            "RM ${expense["amount"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .get();

    AppDataManager.expenseRecords.clear();

    for (var doc in snapshot.docs) {
      AppDataManager.expenseRecords.add({
        "category": doc["category"],
        "amount": (doc["amount"] as num).toDouble(),
        "date": (doc["date"] as Timestamp).toDate(),
        "note": doc["note"] ?? "",
      });
    }

    if (!mounted) return;

    setState(() {});
  }

  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();
  DateTime selectedMonth = DateTime.now();

  final List<String> categories = [
    "Food",
    "Transportation",
    "Entertainment",
    "Education",
    "Medical",
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


  IconData getCategoryIcon(String category) {
    switch (category) {

      case "Food":
        return Icons.restaurant;

      case "Transportation":
        return Icons.directions_car;

      case "Entertainment":
        return Icons.movie;

      case "Education":
        return Icons.school;

      case "Medical":
        return Icons.local_hospital;

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

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add({
        'category': selectedCategory,
        'amount': amount,
        'date': Timestamp.fromDate(selectedDate),
        'note': noteController.text,
      });
    }

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
  void _showAddExpenseDialog() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Expense"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [


                const SizedBox(height: 12),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount (RM)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),

                const SizedBox(height: 12),

                InkWell(
                  onTap: () async {
                    DateTime? pickedDate =
                    await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                    setState(() {
                    selectedDate = pickedDate;
                    });
                    }

                  },

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius:
                      BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: "Note",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {

                _saveExpense();

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [

              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                ),
                onPressed: () {
                  setState(() {
                    selectedMonth = DateTime(
                      selectedMonth.year - 1,
                      selectedMonth.month,
                    );
                  });

                  Navigator.pop(context);
                  _showMonthPicker();
                },
              ),

              Text(
                selectedMonth.year.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                ),
                onPressed: () {
                  setState(() {
                    selectedMonth = DateTime(
                      selectedMonth.year + 1,
                      selectedMonth.month,
                    );
                  });

                  Navigator.pop(context);
                  _showMonthPicker();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {

                bool selected =
                    selectedMonth.month == index + 1;

                return GestureDetector(
                  onTap: () {

                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        index + 1,
                      );
                    });

                    Navigator.pop(context);
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFB6C1)
                          : Colors.transparent,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),

                    child: Center(
                      child: Text(
                        monthNames[index]
                            .substring(0, 3),
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.black,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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

        title: const Text(
          "Expense Tracker",
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFB6C1),
                    Color(0xFFC2185B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAD1457)
                        .withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Expenses for ${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),


                  const SizedBox(height: 12),

                  Text(
                    "RM ${monthlyTotalExpense.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Records",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            filteredExpenses.length.toString(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white24,
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Month",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            monthNames[selectedMonth.month - 1],
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),

            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Select Month",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                InkWell(
                  onTap: _showMonthPicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: Text(
                            "${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Records",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [

                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                          const Color(0xFFD81B60)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            getCategoryIcon(
                              expense["category"],
                            ),
                            color: const Color(0xFFD81B60),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                expense["category"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "${expense["date"].day}/${expense["date"].month}/${expense["date"].year}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [

                            Text(
                              "-RM ${expense["amount"].toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  AppDataManager
                                      .expenseRecords
                                      .remove(expense);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text("ADD EXPENSE"),
      ),
    );
  }
}
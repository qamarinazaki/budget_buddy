import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_data_manager.dart';

class IncomeTracker extends StatefulWidget {
  const IncomeTracker({super.key});

  @override
  State<IncomeTracker> createState() => _IncomeTrackerState();
}

class _IncomeTrackerState extends State<IncomeTracker> {
  DateTime _selectedMonth = DateTime.now();
  
  // Making this static ensures the data persists throughout the app session
  // even when you navigate away from this page and come back.
  static final List<Map<String, dynamic>> _incomes = [];

  final List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  List<Map<String, dynamic>> get _filteredIncomes {
    return _incomes.where((income) {
      DateTime date = income['date'];
      return date.year == _selectedMonth.year && date.month == _selectedMonth.month;
    }).toList();
  }

  double get _totalMonthlyIncome {
    return _filteredIncomes.fold(
      0.0,
          (total, item) => total + item['amount'],
    );
  }
  Future<void> loadIncome() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {

      final snapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('income')
          .orderBy(
        'date',
        descending: true,
      )
          .get();

      _incomes.clear();
      AppDataManager.incomeRecords.clear();

      for (var doc in snapshot.docs) {

        final incomeData = {
          'id': doc.id,
          'source': doc['source'],
          'amount': doc['amount'],
          'date': (doc['date'] as Timestamp).toDate(),
        };

        _incomes.add(incomeData);

        AppDataManager.incomeRecords.add({
          'source': doc['source'],
          'amount': doc['amount'],
          'date': (doc['date'] as Timestamp).toDate(),
        });
      }

      if (!mounted) return;

      setState(() {});

    } catch (e) {

      debugPrint(
        'Error loading income: $e',
      );
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    int tempYear = _selectedMonth.year;
    DateTime now = DateTime.now();

    final int? pickedMonth = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setDialogState(() => tempYear--),
                  ),
                  Text('$tempYear', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: tempYear >= now.year 
                      ? null 
                      : () => setDialogState(() => tempYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                height: 250,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    int month = index + 1;
                    bool isFutureMonth = tempYear > now.year || (tempYear == now.year && month > now.month);
                    bool isSelected = _selectedMonth.month == month && _selectedMonth.year == tempYear;
                    
                    return InkWell(
                      onTap: isFutureMonth ? null : () => Navigator.pop(context, month),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFB6C1)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _monthNames[index].substring(0, 3),
                          style: TextStyle(
                            color: isFutureMonth 
                                ? Colors.grey[300] 
                                : (isSelected ? Colors.white : Colors.black),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      },
    );

    if (pickedMonth != null) {
      setState(() {
        _selectedMonth = DateTime(tempYear, pickedMonth);
      });
    }
  }

  void _showAddIncomeDialog() {
    final sourceController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (dialogContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(dialogContext)
              .viewInsets
              .bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Income', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC2185B))),
            const SizedBox(height: 20),
            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                labelText: 'Income Source',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 24),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    DateFormat('dd MMM yyyy')
                        .format(selectedDate),
                  ),
                  onTap: () async {

                    final pickedDate =
                    await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  final messenger =
                  ScaffoldMessenger.of(context);

                  final navigator =
                  Navigator.of(dialogContext);

                  if (sourceController.text.isEmpty ||
                      amountController.text.isEmpty) {

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please fill in all fields.",
                        ),
                      ),
                    );
                    return;
                  }

                  final amount =
                  double.tryParse(
                    amountController.text,
                  );

                  if (amount == null) {

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Amount must be a valid number.",
                        ),
                      ),
                    );
                    return;
                  }

                  if (amount <= 0) {

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Amount must be greater than 0.",
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _incomes.insert(0, {
                      'source': sourceController.text,
                      'amount': amount,
                      'date': selectedDate,
                    });

                    AppDataManager.addIncome(
                      sourceController.text,
                      amount,
                      selectedDate,
                    );
                  });

                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {

                    final messenger =
                    ScaffoldMessenger.of(context);

                    try {

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('income')
                          .add({
                        'source': sourceController.text,
                        'amount': amount,
                        'date': Timestamp.fromDate(
                          selectedDate,
                        ),
                      });

                      await loadIncome();

                    } catch (e) {

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to save income.',
                          ),
                        ),
                      );

                      return;
                    }
                  }

                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                  foregroundColor: const Color(0xFFC2185B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save Income',
                  style: TextStyle(
                    color: Color(0xFFC2185B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEditIncomeDialog(Map<String, dynamic> income) {
    final sourceController = TextEditingController(text: income['source']);
    final amountController = TextEditingController(text: income['amount'].toString());
    DateTime selectedDate =
    income['date'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (dialogContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(dialogContext)
              .viewInsets
              .bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Income',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC2185B),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _incomes.remove(income);
                    });
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                labelText: 'Income Source',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount (RM)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),

            const SizedBox(height: 24),

            StatefulBuilder(
              builder: (context, setDialogState) {
                return ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                  ),
                  title: Text(
                    DateFormat('dd MMM yyyy')
                        .format(selectedDate),
                  ),
                  onTap: () async {

                    final pickedDate =
                    await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDate =
                            pickedDate;
                      });
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (sourceController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    setState(() {
                      income['source'] =
                          sourceController.text;

                      income['amount'] =
                          double.tryParse(
                            amountController.text,
                          ) ?? 0.0;

                      income['date'] =
                          selectedDate;
                    });
                    Navigator.pop(dialogContext);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB6C1),
                    foregroundColor: const Color(0xFFC2185B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update Income', style: TextStyle(color: Color(0xFFC2185B), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadIncome();
  }

  @override
  Widget build(BuildContext context) {
    String selectedMonthText = "${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Income Tracker",
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
      body: Column(
        children: [
          // Month Selector and Total Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMonthText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _selectMonth(context),
                  icon: const Icon(Icons.calendar_month_outlined,
                    color: Colors.black,),
                  tooltip: 'Select Month',
                ),
              ],
            ),
          ),
          
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB6C1),
                  Color(0xFFC2185B),],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                color: const Color(0xFFC2185B).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Monthly Income',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalMonthlyIncome.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Income History',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredIncomes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No income records for $selectedMonthText',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredIncomes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final income = _filteredIncomes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFB6C1),
                            child: Icon(
                              Icons.add,
                              color: Color(0xFFC2185B),
                            ),
                          ),
                          title: Text(
                            income['source'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(income['date'])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+\$${income['amount'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFC2185B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                onPressed: () => _showEditIncomeDialog(income),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeDialog,
        backgroundColor: const Color(0xFFC2185B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Bill {
  String name;
  double amount;
  DateTime dueDate;
  String category;
  bool isPaid;

  Bill({
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isDueSoon => !isPaid && daysRemaining <= 3 && daysRemaining >= 0;
  bool get isOverdue => !isPaid && daysRemaining < 0;
}

class BillManager {
  static List<Bill> allBills = [
    Bill(
      name: "Room Rental",
      amount: 350.0,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: "Others",
    ),
    Bill(
      name: "Internet",
      amount: 89.0,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      category: "Entertainment",
    ),
  ];
}

class BillReminderPage extends StatefulWidget {
  const BillReminderPage({super.key});

  @override
  State<BillReminderPage> createState() => _BillReminderPageState();
}

class _BillReminderPageState extends State<BillReminderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategory = "Others";

  final List<String> _categories = [
    "Food",
    "Transportation",
    "Entertainment",
    "Education",
    "Medical",
    "Others"
  ];

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addNewBill() {
    if (_nameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required information!")),
      );
      return;
    }

    setState(() {
      BillManager.allBills.add(
        Bill(
          name: _nameController.text,
          amount: double.tryParse(_amountController.text) ?? 0.0,
          dueDate: _selectedDate!,
          category: _selectedCategory,
        ),
      );

      _nameController.clear();
      _amountController.clear();
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),

      appBar: AppBar(
        title: const Text(
          "Bill Reminder",
          style: TextStyle(
            color: Color(0xFFC2185B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildAddBillForm(),

            const SizedBox(height: 25),

            const Text(
              "Important Notifications",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 10),

            _buildAutoNotifications(),

            const SizedBox(height: 25),

            const Text(
              "Student Bills",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC2185B),
              ),
            ),

            const SizedBox(height: 15),

            _buildBillList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBillForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Bill Name"),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount (RM)"),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: "Category"),
            items: _categories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? "Select Due Date"
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                ),
              ),
              IconButton(
                onPressed: () => _pickDate(context),
                icon: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addNewBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB6C1),
                foregroundColor: const Color(0xFFC2185B),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Add Monthly Bill",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAutoNotifications() {
    final urgent = BillManager.allBills
        .where((b) => b.isDueSoon || b.isOverdue)
        .toList();

    if (urgent.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("No urgent bills."),
      );
    }

    return Column(
      children: urgent.map((bill) {
        final msg = bill.isOverdue
            ? "OVERDUE: ${bill.name}!"
            : "REMINDER: ${bill.name} remaining ${bill.daysRemaining} days";

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBillList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: BillManager.allBills.length,
      itemBuilder: (context, index) {
        final bill = BillManager.allBills[index];

        return Card(
          child: ListTile(
            title: Text(bill.name),
            subtitle: Text(
              "RM ${bill.amount.toStringAsFixed(2)} • ${bill.category}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: bill.isPaid,
                  onChanged: (v) {
                    setState(() {
                      bill.isPaid = v!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      BillManager.allBills.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
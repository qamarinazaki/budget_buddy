import 'package:flutter/material.dart';
import 'app_data_manager.dart';

class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  State<SavingGoalsPage> createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _savedController = TextEditingController();
  void _addNewGoal() {
    if (_nameController.text.isEmpty ||
        _targetController.text.isEmpty) {
      return;
    }

    double target =
        double.tryParse(_targetController.text) ?? 0;

    double saved =
        double.tryParse(_savedController.text) ?? 0;

    AppDataManager.addSavingGoal(
      _nameController.text,
      target,
      saved,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Matlamat '${_nameController.text}' berjaya ditambah!",
        ),
      ),
    );

    _nameController.clear();
    _targetController.clear();
    _savedController.clear();

    setState(() {});
  }
  void _showAddSavingsDialog(
      Map<String, dynamic> goal) {

    final amountController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Add Savings to ${goal["name"]}",
          ),

          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount (RM)",
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

                double amount =
                    double.tryParse(
                      amountController.text,
                    ) ??
                        0;

                setState(() {
                  goal["saved"] =
                      (goal["saved"] as num).toDouble() + amount;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          "Saving Goals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFC81858),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Set Matlamat Simpanan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC81858),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                _nameController,
                "Apa yang anda hendak beli?",
                Icons.shopping_bag_outlined,
              ),

              const SizedBox(height: 15),

              _buildTextField(
                _targetController,
                "Jumlah sasaran (RM)",
                Icons.track_changes,
                isNumber: true,
              ),

              const SizedBox(height: 15),

              _buildTextField(
                _savedController,
                "Jumlah simpanan semasa (RM)",
                Icons.account_balance_wallet_outlined,
                isNumber: true,
              ),

              const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _addNewGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC81858),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Tambah Matlamat",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

              const SizedBox(height: 30),
              const SizedBox(height: 30),

              ...(AppDataManager.savingGoals.isEmpty
                  ? [
                const Center(
                  child: Text(
                    "No saving goals yet.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ]
                  : AppDataManager.savingGoals.map((goal) {
                double target = goal["target"];
                double saved = goal["saved"];

                double progress =
                target > 0 ? saved / target : 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal["name"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "RM ${saved.toStringAsFixed(2)} / RM ${target.toStringAsFixed(2)}",
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showAddSavingsDialog(goal);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add Savings"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC81858),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value:
                          progress > 1 ? 1 : progress,
                          backgroundColor:
                          Colors.grey.shade200,
                          color: const Color(0xFFC81858),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      keyboardType:
      isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFC81858),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
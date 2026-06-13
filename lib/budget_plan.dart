import 'package:flutter/material.dart';
import 'app_data_manager.dart';
import 'saving_goals.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  // --- 1. DATA STATE (Limit & Used) ---
  double totalBudget = 0.0;

  // Had Bajet (Limit)
  double makananLimit = 0.0;
  double pengangkutanLimit = 0.0;
  double hiburanLimit = 0.0;
  double pengajianLimit = 0.0;
  double perubatanLimit = 0.0;
  double lainLainLimit = 0.0;

  double getCategoryExpense(String category) {
    double total = 0;

    for (var expense in AppDataManager.expenseRecords) {
      if (expense["category"] == category) {
        total += expense["amount"];
      }
    }

    return total;
  }


  // Controllers untuk Had Bajet
  final TextEditingController _makananController = TextEditingController();
  final TextEditingController _pengangkutanController = TextEditingController();
  final TextEditingController _hiburanController = TextEditingController();
  final TextEditingController _pengajianController = TextEditingController();
  final TextEditingController _perubatanController = TextEditingController();
  final TextEditingController _lainController = TextEditingController();

  // Controllers untuk Jumlah Digunakan
  final TextEditingController _makananUsedController = TextEditingController();
  final TextEditingController _pengangkutanUsedController = TextEditingController();
  final TextEditingController _hiburanUsedController = TextEditingController();
  final TextEditingController _pengajianUsedController = TextEditingController();
  final TextEditingController _perubatanUsedController = TextEditingController();
  final TextEditingController _lainUsedController = TextEditingController();

  final TextEditingController _newGoalNameController = TextEditingController();
  final TextEditingController _newGoalTargetController = TextEditingController();


  void _addNewGoal() {
    if (_newGoalNameController.text.isEmpty ||
        _newGoalTargetController.text.isEmpty) {
      _showSnackBar("Please enter a goal name and target amount!");
      return;
    }

    AppDataManager.addSavingGoal(
      _newGoalNameController.text,
      double.tryParse(
        _newGoalTargetController.text,
      ) ??
          0,
      0,
    );

    setState(() {});

    _newGoalNameController.clear();
    _newGoalTargetController.clear();
  }
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                        (goal["saved"] as num)
                            .toDouble() +
                            amount;
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
    // Dispose semua controller
    _makananController.dispose();
    _pengangkutanController.dispose();
    _hiburanController.dispose();
    _pengajianController.dispose();
    _perubatanController.dispose();
    _lainController.dispose();
    _makananUsedController.dispose();
    _pengangkutanUsedController.dispose();
    _hiburanUsedController.dispose();
    _pengajianUsedController.dispose();
    _perubatanUsedController.dispose();
    _lainUsedController.dispose();
    _newGoalNameController.dispose();
    _newGoalTargetController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

    makananLimit = AppDataManager.foodBudget;
    pengangkutanLimit = AppDataManager.transportBudget;
    hiburanLimit = AppDataManager.entertainmentBudget;
    pengajianLimit = AppDataManager.educationBudget;
    perubatanLimit = AppDataManager.medicalBudget;
    lainLainLimit = AppDataManager.othersBudget;

    _makananController.text = makananLimit.toString();
    _pengangkutanController.text =
        pengangkutanLimit.toString();
    _hiburanController.text =
        hiburanLimit.toString();
    _pengajianController.text =
        pengajianLimit.toString();
    _perubatanController.text =
        perubatanLimit.toString();
    _lainController.text =
        lainLainLimit.toString();

    totalBudget =
        makananLimit +
            pengangkutanLimit +
            hiburanLimit +
            pengajianLimit +
            perubatanLimit +
            lainLainLimit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Budget Planner',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AMARAN (Hanya muncul jika nisbah Used/Limit tinggi)
            _buildWarningSection(),

            const SizedBox(height: 10),
            _buildMonthlyBudgetCard(),
            const SizedBox(height: 25),

            _buildCombinedInputSection(),
            const SizedBox(height: 25),

            _buildGoalInputSection(),
            const SizedBox(height: 25),

            if (AppDataManager.savingGoals.isNotEmpty) ...[
              const Text("Your Savings Goals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...AppDataManager.savingGoals.map((goal) => _buildGoalCard(goal)).toList(),
              const SizedBox(height: 25),
            ],

            const Text("Budget Planning Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCategorySummary(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- UI: BAHAGIAN NOTIFIKASI AMARAN (DINAMIK) ---
  Widget _buildWarningSection() {
    List<Widget> warnings = [];

    // Fungsi helper untuk cek amaran
    void checkWarning(String title, double used, double limit) {
      if (limit > 0 && (used / limit) >= 0.8) {
        warnings.add(_warningItem(title, used / limit));
      }
    }

    checkWarning("Food", getCategoryExpense("Food"), makananLimit);
    checkWarning("Transportation", getCategoryExpense("Transportation"), pengangkutanLimit);
    checkWarning("Entertainment", getCategoryExpense("Entertainment"), hiburanLimit);
    checkWarning("Education", getCategoryExpense("Education"), pengajianLimit);
    checkWarning("Medical", getCategoryExpense("Medical"), perubatanLimit);
    checkWarning("Others", getCategoryExpense("Others"), lainLainLimit);

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Text(
          "Important Notifications",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...warnings,
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _warningItem(String category, double percent) {
    bool isCritical = percent >= 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCritical ? Colors.red.shade200 : Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.report_problem : Icons.warning_amber_rounded,
            color: isCritical ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCritical
                  ? "Budget exceeded for $category!"
                  : "$category budget is almost reached (${(percent * 100).toInt()}%)",
              style: TextStyle(
                  color: isCritical ? Colors.red.shade900 : Colors.orange.shade900,
                  fontSize: 13,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: INPUT HAD & JUMLAH DIGUNAKAN ---
  Widget _buildCombinedInputSection() {
    return _buildContainerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Set Budget Limits & Expenses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          _buildCategoryInputs(
            "Food",
            Icons.restaurant,
            _makananController,
          ),

          _buildCategoryInputs(
            "Transportation",
            Icons.directions_car,
            _pengangkutanController,
          ),

          _buildCategoryInputs(
            "Entertainment",
            Icons.sports_esports,
            _hiburanController,
          ),

          _buildCategoryInputs(
            "Education",
            Icons.school,
            _pengajianController,
          ),

          _buildCategoryInputs(
            "Medical",
            Icons.medical_services,
            _perubatanController,
          ),

          _buildCategoryInputs(
            "Others",
            Icons.more_horiz,
            _lainController,
          ),
          const SizedBox(height: 10),
          _buildActionButton("Save & Update", _updateBudget, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildCategoryInputs(
      String title,
      IconData icon,
      TextEditingController limitCtrl,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.pink),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          _buildSmallTextField(
            limitCtrl,
            "Budget RM",
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
    );
  }

  // --- UI: INPUT MATLAMAT ---
  Widget _buildGoalInputSection() {
    return _buildContainerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Savings Goal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          _buildTextField(_newGoalNameController, "Goal Name (e.g. Umrah)", Icons.flag, isText: true),
          _buildTextField(_newGoalTargetController, "Target Amount (RM)", Icons.track_changes),
          const SizedBox(height: 10),
          _buildActionButton("Add Goal", _addNewGoal, const Color(0xFFC81858)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {

    double target =
    (goal["target"] as num).toDouble();

    double saved =
    (goal["saved"] as num).toDouble();

    double progress =
    target > 0 ? saved / target : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            goal["name"],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "RM ${saved.toStringAsFixed(2)} / RM ${target.toStringAsFixed(2)}",
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress > 1 ? 1 : progress,
            color: const Color(0xFFC81858),
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
                backgroundColor:
                const Color(0xFFC81858),
                foregroundColor:
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: RINGKASAN ---
  Widget _buildCategorySummary() {
    return Column(
      children: [
        _categoryProgressRow(
          Icons.restaurant,
          "Food",
          getCategoryExpense("Food"),
          makananLimit,
          Colors.orange,
        ),
        _categoryProgressRow(Icons.directions_car, "Transportation", getCategoryExpense("Transportation"), pengangkutanLimit, Colors.blue),
        _categoryProgressRow(Icons.sports_esports, "Entertainment", getCategoryExpense("Entertainment"), hiburanLimit, Colors.purple),
        _categoryProgressRow(Icons.school, "Education", getCategoryExpense("Education"), pengajianLimit, Colors.green),
        _categoryProgressRow(Icons.medical_services, "Medical", getCategoryExpense("Medical"), perubatanLimit, Colors.red),
        _categoryProgressRow(Icons.more_horiz, "Others", getCategoryExpense("Others"), lainLainLimit, Colors.grey),
      ],
    );
  }
  void _updateBudget() {
    setState(() {
      makananLimit =
          double.tryParse(_makananController.text) ?? 0.0;

      pengangkutanLimit =
          double.tryParse(_pengangkutanController.text) ?? 0.0;

      hiburanLimit =
          double.tryParse(_hiburanController.text) ?? 0.0;

      pengajianLimit =
          double.tryParse(_pengajianController.text) ?? 0.0;

      perubatanLimit =
          double.tryParse(_perubatanController.text) ?? 0.0;

      lainLainLimit =
          double.tryParse(_lainController.text) ?? 0.0;

      AppDataManager.foodBudget = makananLimit;
      AppDataManager.transportBudget = pengangkutanLimit;
      AppDataManager.entertainmentBudget = hiburanLimit;
      AppDataManager.educationBudget = pengajianLimit;
      AppDataManager.medicalBudget = perubatanLimit;
      AppDataManager.othersBudget = lainLainLimit;

      totalBudget =
          makananLimit +
              pengangkutanLimit +
              hiburanLimit +
              pengajianLimit +
              perubatanLimit +
              lainLainLimit;
    });

    _showSnackBar("Budget updated successfully!");
  }

  // --- HELPERS ---
  Widget _buildMonthlyBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.pink.shade700, Colors.pink.shade500]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text("Total Budget Allocated", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text("RM ${totalBudget.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: isText ? TextInputType.text : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label),
      ),
    );
  }

  Widget _buildContainerWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _categoryProgressRow(IconData icon, String name, double used, double limit, Color color) {
    if (limit == 0) return const SizedBox.shrink();

    double progress = used / limit;
    if (progress > 1.0) progress = 1.0;

    // Tukar warna kepada merah jika kritikal
    Color barColor = progress >= 0.9 ? Colors.red : color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: barColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("RM ${used.toInt()} / RM ${limit.toInt()}", style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                    value: progress,
                    color: barColor,
                    backgroundColor: Colors.grey.shade100,
                    minHeight: 4
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
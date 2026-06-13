import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_data_manager.dart';

class AnalyticsReport extends StatefulWidget {
  const AnalyticsReport({super.key});

  @override
  State<AnalyticsReport> createState() => _AnalyticsReportState();
}

class _AnalyticsReportState extends State<AnalyticsReport> {
  DateTime _selectedMonth = DateTime.now();

  final List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

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
                    // Prevent going to future years
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
                          color: isSelected ? Colors.indigo : null,
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

  @override
  Widget build(BuildContext context) {
    String selectedMonthText = "${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics & Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedMonthText Summary',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _selectMonth(context),
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.indigo),
                  tooltip: 'Select Month',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 4 Small Summary Cards in a row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Spending Insights",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Total Expenses: RM ${AppDataManager.totalExpense.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Total Income: RM ${AppDataManager.totalIncome.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Total Transactions: ${AppDataManager.expenseRecords.length}",
                  ),

                  Text(
                    "Current Savings: RM ${(AppDataManager.totalIncome - AppDataManager.totalExpense).toStringAsFixed(2)}",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Spending Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildPieChart(), // Pie chart follows top categories data
            const SizedBox(height: 32),
            const Text(
              'Top Spending Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCategoryList(),
            const SizedBox(height: 32),
            // Download Report Button
            const SizedBox(height: 32),

            const Text(
              "Monthly Trend",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Monthly Expense Trend Chart",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Downloading report...'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Monthly Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    Map<String, double> categoryTotals = {};

    for (var expense in AppDataManager.expenseRecords) {

      String category = expense["category"];

      double amount =
      (expense["amount"] as num).toDouble();

      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + amount;
    }
    final categories = [
      {
        'name': 'Food',
        'amount': categoryTotals['Food'] ?? 0,
        'color': Colors.orange,
      },
      {
        'name': 'Transport',
        'amount': categoryTotals['Transport'] ?? 0,
        'color': Colors.green,
      },
      {
        'name': 'Printing',
        'amount': categoryTotals['Printing'] ?? 0,
        'color': Colors.blue,
      },
      {
        'name': 'Entertainment',
        'amount': categoryTotals['Entertainment'] ?? 0,
        'color': Colors.purple,
      },
    ];

    double total = categories.fold(
      0.0,
          (sum, item) => sum + (item['amount'] as double),
    );

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: CustomPaint(
                painter: PieChartPainter(categories, total),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: categories.map((cat) {
                double percentage = total == 0
                    ? 0
                    : ((cat['amount'] as double) / total) * 100;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cat['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${cat['name']} ${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    Map<String, double> categoryTotals = {};

    for (var expense in AppDataManager.expenseRecords) {

      String category = expense["category"];

      double amount =
      (expense["amount"] as num).toDouble();

      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + amount;
    }

    final categories = [
      {
        'name': 'Food',
        'amount': categoryTotals['Food'] ?? 0,
        'color': Colors.orange,
      },
      {
        'name': 'Transport',
        'amount': categoryTotals['Transport'] ?? 0,
        'color': Colors.green,
      },
      {
        'name': 'Printing',
        'amount': categoryTotals['Printing'] ?? 0,
        'color': Colors.blue,
      },
      {
        'name': 'Entertainment',
        'amount': categoryTotals['Entertainment'] ?? 0,
        'color': Colors.purple,
      },
    ];
    double totalExpense =
    categoryTotals.values.fold(
      0.0,
          (sum, item) => sum + item,
    );

    return Column(
      children: categories.map((cat) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "RM ${(cat['amount'] as double).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalExpense == 0
                          ? 0
                          : (cat['amount'] as double) / totalExpense,
                      backgroundColor: Colors.grey[100],
                      color: cat['color'] as Color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  final double total;

  PieChartPainter(this.categories, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -math.pi / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (var cat in categories) {
      final sweepAngle = ((cat['amount'] as double) / total) * 2 * math.pi;
      final paint = Paint()
        ..color = cat['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Donut hole effect
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 4, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

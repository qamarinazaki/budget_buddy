import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  List<Map<String, dynamic>> get monthlyExpenses {
    return AppDataManager.expenseRecords.where((expense) {

      final date = expense["date"] as DateTime;

      return date.month == _selectedMonth.month &&
          date.year == _selectedMonth.year;

    }).toList();
  }

  double get monthlyTotalExpense {

    double total = 0;

    for (var expense in monthlyExpenses) {
      total += (expense["amount"] as num)
          .toDouble();
    }

    return total;
  }
  double get monthlyTotalIncome {

    double total = 0;

    for (var income
    in AppDataManager.incomeRecords) {

      final date =
      income["date"] as DateTime;

      if (date.month ==
          _selectedMonth.month &&
          date.year ==
              _selectedMonth.year) {

        total +=
            (income["amount"] as num)
                .toDouble();
      }
    }

    return total;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Food":
        return Colors.orange;

      case "Transportation":
        return Colors.green;

      case "Entertainment":
        return Colors.purple;

      case "Education":
        return Colors.blue;

      case "Medical":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Future<void> downloadReport() async {
    try {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {

          return pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "BudgetBuddy Monthly Report",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Month: ${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}",
              ),

              pw.Text(
                "Total Expenses: RM ${monthlyTotalExpense.toStringAsFixed(2)}",
              ),

              pw.Text(
                "Total Transactions: ${monthlyExpenses.length}",
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Expense Records",
                style: pw.TextStyle(
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              ...monthlyExpenses.map(
                    (expense) => pw.Text(
                  "${expense['category']} - RM ${(expense['amount'] as num).toStringAsFixed(2)}",
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async =>
          pdf.save(),
    );
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to generate report.',
          ),
        ),
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
                          color: isSelected ? const Color(0xFFC2185B) : null,
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Analytics & Report",
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
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.black),
                  tooltip: 'Select Month',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 4 Small Summary Cards in a row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFF8BBD0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insights,
                    color: Color(0xFFC2185B),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Spending Insights",
                    style: TextStyle(
                      color: Color(0xFFAD1457),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Total Expenses: RM ${monthlyTotalExpense.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Total Income: RM ${monthlyTotalIncome.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Total Transactions: ${monthlyExpenses.length}",
                  ),

                  Text(
                    "Available Balance: RM ${(monthlyTotalIncome - monthlyTotalExpense).toStringAsFixed(2)}",
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

            const Text(
              'Monthly Expense Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildMonthlyExpenseChart(),

            const SizedBox(height: 32),

// Download Report Button

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await downloadReport();
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Monthly Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2185B),
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

  Widget _buildPieChart() {
    Map<String, double> categoryTotals = {};

    for (var expense in monthlyExpenses) {

      String category = expense["category"];

      double amount =
      (expense["amount"] as num).toDouble();

      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + amount;
    }
    final categories = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getCategoryColor(entry.key),
      };
    }).toList();

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

    for (var expense in monthlyExpenses) {

      String category = expense["category"];

      double amount =
      (expense["amount"] as num).toDouble();

      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + amount;
    }

    final categories = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getCategoryColor(entry.key),
      };
    }).toList();
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
  Widget _buildMonthlyExpenseChart() {

    Map<String, double> monthlyTotals = {};

    for (var expense in AppDataManager.expenseRecords) {

      final date =
      expense["date"] as DateTime;

      final month =
          "${_monthNames[date.month - 1].substring(0, 3)} ${date.year}";

      monthlyTotals[month] =
          (monthlyTotals[month] ?? 0) +
              (expense["amount"] as num)
                  .toDouble();
    }

    final data =
    monthlyTotals.entries.toList();

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No expense data available",
        ),
      );
    }

    double maxValue = data
        .map((e) => e.value)
        .reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        children: data.map((item) {

          final percentage =
              item.value / maxValue;

          return Padding(
            padding:
            const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Row(
              children: [

                SizedBox(
                  width: 70,
                  child: Text(item.key),
                ),

                Expanded(
                  child:
                  LinearProgressIndicator(
                    value: percentage,
                    minHeight: 12,
                    color: const Color(
                      0xFFC2185B,
                    ),
                    backgroundColor:
                    Colors.grey[200],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "RM ${item.value.toStringAsFixed(0)}",
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}


class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  final double total;

  PieChartPainter(this.categories, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
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

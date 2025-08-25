import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_sochitieu/shared/models/category.dart';
import 'package:flutter_sochitieu/shared/models/income_expense.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Tháng này';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Dữ liệu mẫu cho demo
  final List<IncomeExpense> _sampleData = [
    IncomeExpense(
      id: '1',
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 25)),
      type: IncomeExpenseType.expense,
      categoryId: 'food',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeExpense(
      id: '2',
      amount: 300000,
      date: DateTime.now().subtract(const Duration(days: 20)),
      type: IncomeExpenseType.expense,
      categoryId: 'transport',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeExpense(
      id: '3',
      amount: 200000,
      date: DateTime.now().subtract(const Duration(days: 15)),
      type: IncomeExpenseType.expense,
      categoryId: 'shopping',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeExpense(
      id: '4',
      amount: 1500000,
      date: DateTime.now().subtract(const Duration(days: 10)),
      type: IncomeExpenseType.income,
      categoryId: 'salary',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    IncomeExpense(
      id: '5',
      amount: 400000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: IncomeExpenseType.expense,
      categoryId: 'entertainment',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<Category> _categories = [
    Category(
      id: 'food',
      text: 'Ăn uống',
      icon: '🍽️',
      color: '#FF6B6B',
      type: IncomeExpenseType.expense,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'transport',
      text: 'Di chuyển',
      icon: '🚗',
      color: '#4ECDC4',
      type: IncomeExpenseType.expense,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'shopping',
      text: 'Mua sắm',
      icon: '🛍️',
      color: '#45B7D1',
      type: IncomeExpenseType.expense,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'entertainment',
      text: 'Giải trí',
      icon: '🎮',
      color: '#96CEB4',
      type: IncomeExpenseType.expense,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'salary',
      text: 'Lương',
      icon: '💰',
      color: '#FFEAA7',
      type: IncomeExpenseType.income,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn khoảng thời gian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Hôm nay'),
              onTap: () {
                setState(() {
                  _selectedPeriod = 'Hôm nay';
                  _startDate = DateTime.now();
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_week),
              title: const Text('Tuần này'),
              onTap: () {
                setState(() {
                  _selectedPeriod = 'Tuần này';
                  _startDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Tháng này'),
              onTap: () {
                setState(() {
                  _selectedPeriod = 'Tháng này';
                  _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('3 tháng gần đây'),
              onTap: () {
                setState(() {
                  _selectedPeriod = '3 tháng gần đây';
                  _startDate = DateTime.now().subtract(const Duration(days: 90));
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month),
              title: const Text('Năm nay'),
              onTap: () {
                setState(() {
                  _selectedPeriod = 'Năm nay';
                  _startDate = DateTime(DateTime.now().year, 1, 1);
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  double get _totalIncome {
    return _sampleData
        .where((item) => item.type == IncomeExpenseType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _sampleData
        .where((item) => item.type == IncomeExpenseType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get _balance => _totalIncome - _totalExpense;

  Map<String, double> get _categoryExpenses {
    final Map<String, double> result = {};
    for (final item in _sampleData.where((item) => item.type == IncomeExpenseType.expense)) {
      final category = _categories.firstWhere((cat) => cat.id == item.categoryId);
      result[category.text ?? ''] = (result[category.text ?? ''] ?? 0) + item.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header với thống kê tổng quan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedPeriod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: _showPeriodPicker,
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Thu nhập', _totalIncome, Colors.green, Icons.trending_up),
                    _buildStatCard('Chi tiêu', _totalExpense, Colors.red, Icons.trending_down),
                    _buildStatCard('Còn lại', _balance, Colors.blue, Icons.account_balance_wallet),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Biểu đồ'),
                Tab(text: 'Chi tiết'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChartTab(),
                _buildDetailTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan tài chính',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Biểu đồ cột đơn giản
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_totalIncome + _totalExpense) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Thu nhập', 'Chi tiêu'];
                        if (value >= 0 && value < titles.length) {
                          return Text(titles[value.toInt()], style: const TextStyle(fontSize: 12));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormat.compact(locale: 'vi_VN').format(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _totalIncome,
                        color: Colors.green,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _totalExpense,
                        color: Colors.red,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top chi tiêu theo danh mục
          const Text(
            'Chi tiêu theo danh mục',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._categoryExpenses.entries.take(5).map((entry) {
            final category = _categories.firstWhere((cat) => cat.text == entry.key);
            final percentage = (_totalExpense > 0) ? (entry.value / _totalExpense * 100) : 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${category.color?.substring(1)}')),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.icon ?? '📊',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(entry.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biểu đồ phân tích',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Biểu đồ tròn cho chi tiêu theo danh mục
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Phân bổ chi tiêu theo danh mục',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _categoryExpenses.entries.map((entry) {
                        final category = _categories.firstWhere((cat) => cat.text == entry.key);
                        final percentage = (_totalExpense > 0) ? (entry.value / _totalExpense * 100) : 0;
                        
                        return PieChartSectionData(
                          color: Color(int.parse('0xFF${category.color?.substring(1)}')),
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Chú thích cho biểu đồ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chú thích',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ..._categoryExpenses.entries.map((entry) {
                  final category = _categories.firstWhere((cat) => cat.text == entry.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(int.parse('0xFF${category.color?.substring(1)}')),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(entry.value),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab() {
    final filteredData = _sampleData.where((item) {
      return item.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
             item.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
    
    filteredData.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        final category = _categories.firstWhere((cat) => cat.id == item.categoryId);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${category.color?.substring(1)}')),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    category.icon ?? '📊',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.text ?? 'Không xác định',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(item.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (item.description != null && item.description!.isNotEmpty)
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(item.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: item.type == IncomeExpenseType.income ? Colors.green : Colors.red,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.type == IncomeExpenseType.income 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.type == IncomeExpenseType.income ? 'Thu' : 'Chi',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.type == IncomeExpenseType.income ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sochitieu/shared/models/income_expense.dart';
import 'package:flutter_sochitieu/shared/models/category.dart';
import 'package:flutter_sochitieu/shared/providers/app_providers.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCurrency = 'VND';
  String _selectedYear = 'Năm 2025';
  String _selectedMonth = 'Tháng 8';
  String _selectedDay = 'Tất cả ngày';
  
  // Danh sách các tùy chọn lọc
  final List<String> _currencies = ['VND', 'USD', 'EUR'];
  final List<String> _years = ['Năm 2025', 'Năm 2024', 'Năm 2023'];
  final List<String> _months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 
                                'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
  final List<String> _days = ['Tất cả ngày', 'Hôm nay', 'Hôm qua', 'Tuần này'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomeExpenses = ref.watch(incomeExpensesProvider);
    
    // Lọc giao dịch theo các bộ lọc
    final filteredTransactions = _getFilteredTransactions(incomeExpenses);
    
    // Tính toán thống kê
    double totalIncome = 0;
    double totalExpense = 0;
    for (var transaction in filteredTransactions) {
      if (transaction.type == IncomeExpenseType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    final remaining = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // PHẦN 1: HEADER - TÌM KIẾM VÀ LỌC
          Container(
            color: Colors.pink[400],
            child: SafeArea(
              child: Column(
                children: [
                  // Tiêu đề
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Lịch sử',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Phần tìm kiếm và lọc
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Thanh tìm kiếm
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),    
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tìm kiếm danh mục...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.pink[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Nút bộ lọc
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.pink[400]!, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: Colors.pink[400],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bộ lọc',
                                style: TextStyle(
                                  color: Colors.pink[400],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Các bộ lọc đang hoạt động
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildActiveFilterChip(_selectedCurrency, () => _showCurrencyDialog()),
                            _buildActiveFilterChip(_selectedYear, () => _showYearDialog()),
                            _buildActiveFilterChip(_selectedMonth, () => _showMonthDialog()),
                            _buildActiveFilterChip(_selectedDay, () => _showDayDialog()),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Thống kê tài chính
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Thu nhập
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(Icons.account_balance_wallet, color: Colors.green, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Thu',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                                                         GestureDetector(
                                        onTap: _showCurrencyDialog,
                                        child: Text(
                                          '${_formatCurrency(totalIncome)} $_selectedCurrency',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Chi tiêu
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(Icons.shopping_cart, color: Colors.red, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Chi',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                                                         GestureDetector(
                                        onTap: _showCurrencyDialog,
                                        child: Text(
                                          '${_formatCurrency(totalExpense)} $_selectedCurrency',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Còn lại
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(Icons.savings, color: Colors.orange, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Còn',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                                                         GestureDetector(
                                        onTap: _showCurrencyDialog,
                                        child: Text(
                                          '${_formatCurrency(remaining)} $_selectedCurrency',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // PHẦN 2: NỘI DUNG - HIỂN THỊ DANH SÁCH GIAO DỊCH
          Expanded(
            child: Container(
              color: Colors.white,
              child: filteredTransactions.isNotEmpty
                  ? Column(
                      children: [
                        // Tiêu đề phần danh sách
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.pink[400],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Trả về ${filteredTransactions.length} khoản thu chi',
                                style: TextStyle(
                                  color: Colors.pink[400],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Danh sách giao dịch
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = filteredTransactions[index];
                              final showDateSeparator = index == 0 || 
                                  _shouldShowDateSeparator(filteredTransactions[index - 1], transaction);
                              
                              return Column(
                                children: [
                                  if (showDateSeparator) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Ngày ${_formatDate(transaction.date)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  _buildTransactionCard(transaction),
                                  if (index < filteredTransactions.length - 1) 
                                    const SizedBox(height: 12),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có giao dịch nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thử thay đổi bộ lọc hoặc tìm kiếm',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(IncomeExpense transaction) {
    final categories = ref.read(categoriesProvider);
    final Category? cat = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => Category(
        id: 'unknown',
        text: 'Không xác định',
        icon: '📁',
        color: '#CCCCCC',
        order: 0,
        type: transaction.type,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final Color badgeColor = Color(int.parse('0xFF${(cat?.color ?? '#CCCCCC').substring(1)}'))
        .withOpacity(0.2);
    final Color edgeColor = Color(int.parse('0xFF${(cat?.color ?? '#CCCCCC').substring(1)}'));

    final String currencyUnit = transaction.currency ?? _selectedCurrency;
    final String sign = transaction.type == IncomeExpenseType.income ? '+' : '-';
    final String formattedAmount = NumberFormat.decimalPattern('vi_VN').format(transaction.amount.round());
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icon danh mục
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: edgeColor, width: 1),
            ),
            child: Center(
              child: Text(
                cat?.icon ?? '📁',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Thông tin giao dịch
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Không có mô tả',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat?.text ?? 'Không xác định',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Số tiền
          Flexible(
            flex: 0,
            child: FittedBox( 
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _showCurrencyDialog,
                child: Text(
                  '$sign$formattedAmount $currencyUnit',
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: transaction.type == IncomeExpenseType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<IncomeExpense> _getFilteredTransactions(List<IncomeExpense> allTransactions) {
    var filtered = allTransactions;
    
    // Lọc theo tìm kiếm
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.description?.toLowerCase().contains(
          _searchController.text.toLowerCase()
        ) ?? false;
      }).toList();
    }
    
    // Lọc theo năm
    if (_selectedYear != 'Tất cả năm') {
      final year = int.tryParse(_selectedYear.replaceAll('Năm ', ''));
      if (year != null) {
        filtered = filtered.where((transaction) => transaction.date.year == year).toList();
      }
    }
    
    // Lọc theo tháng
    if (_selectedMonth != 'Tất cả tháng') {
      final month = int.tryParse(_selectedMonth.replaceAll('Tháng ', ''));
      if (month != null) {
        filtered = filtered.where((transaction) => transaction.date.month == month).toList();
      }
    }
    
    // Lọc theo ngày
    if (_selectedDay != 'Tất cả ngày') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (_selectedDay) {
        case 'Hôm nay':
          filtered = filtered.where((transaction) {
            final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
            return transactionDate == today;
          }).toList();
          break;
        case 'Hôm qua':
          final yesterday = today.subtract(const Duration(days: 1));
          filtered = filtered.where((transaction) {
            final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
            return transactionDate == yesterday;
          }).toList();
          break;
        case 'Tuần này':
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          filtered = filtered.where((transaction) {
            return transaction.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                   transaction.date.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).toList();
          break;
      }
    }
    
    // Sắp xếp theo ngày mới nhất
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }

  bool _shouldShowDateSeparator(IncomeExpense previous, IncomeExpense current) {
    final prevDate = DateTime(previous.date.year, previous.date.month, previous.date.day);
    final currDate = DateTime(current.date.year, current.date.month, current.date.day);
    return prevDate != currDate;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} nghìn';
    }
    return NumberFormat.decimalPattern('vi_VN').format(amount.round());
  }

  void _showCurrencyDialog() {
    _showSelectionDialog('Chọn tiền tệ', _currencies, (value) {
      setState(() => _selectedCurrency = value);
    });
  }

  void _showYearDialog() {
    _showSelectionDialog('Chọn năm', _years, (value) {
      setState(() => _selectedYear = value);
    });
  }

  void _showMonthDialog() {
    _showSelectionDialog('Chọn tháng', _months, (value) {
      setState(() => _selectedMonth = value);
    });
  }

  void _showDayDialog() {
    _showSelectionDialog('Chọn ngày', _days, (value) {
      setState(() => _selectedDay = value);
    });
  }

  void _showSelectionDialog(String title, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  onSelect(option);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

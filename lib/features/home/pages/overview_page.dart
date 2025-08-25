import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/models/income_expense.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  IncomeExpenseType _selectedType = IncomeExpenseType.expense;
  String? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCurrency = 'VND';
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeFilter = 'Tháng này'; // Thêm biến chọn thời gian

  @override
  void initState() {
    super.initState();
    _amountController.text = '0';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final incomeExpenses = ref.watch(incomeExpensesProvider);
    final filteredCategories = categories.where((cat) => cat.type == _selectedType).toList();
    
    // Lọc giao dịch theo thời gian được chọn
    final filteredTransactions = _getFilteredTransactions(incomeExpenses);
    
    // Tính toán thống kê tháng
    double totalIncome = 1000000;
    double totalExpense = 2000;
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // PHẦN 1: HEADER - QUẢN LÝ THU CHI
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề chính
                    Text(
                      'QUẢN LÝ THU CHI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Nội dung chính
                    Row(
                      children: [
                        // Bên trái - Nút chọn loại
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildTypeButton(
                                'Khoản Thu',
                                _selectedType == IncomeExpenseType.income,
                                Colors.green,
                                () => setState(() => _selectedType = IncomeExpenseType.income),
                              ),
                              const SizedBox(height: 12),
                              _buildTypeButton(
                                'Khoản Chi',
                                _selectedType == IncomeExpenseType.expense,
                                Colors.red,
                                () => setState(() => _selectedType = IncomeExpenseType.expense),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Bên phải - Tóm tắt tài chính
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Tháng này',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.pink[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Thu nhập
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Thu: ${_formatCurrency(totalIncome)}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Chi tiêu
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Chi: ${_formatCurrency(totalExpense)}',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.shopping_cart, color: Colors.red, size: 20),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Còn lại
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Còn: ${_formatCurrency(remaining)}',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.savings, color: Colors.orange, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // PHẦN 2: FORM NHẬP THU CHI
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề form
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedType == IncomeExpenseType.income ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _selectedType == IncomeExpenseType.income ? Icons.add : Icons.remove,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedType == IncomeExpenseType.income ? 'Tạo khoản thu' : 'Tạo khoản chi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedType == IncomeExpenseType.income ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Ngày
                    _buildInputField(
                      'Ngày *:',
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    
                    // Ghi chú
                    _buildInputField(
                      'Ghi chú :',
                      'Mô tả khoản ${_selectedType == IncomeExpenseType.income ? 'thu' : 'chi'}...',
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 16),
                    
                    // Số tiền
                    _buildInputField(
                      'Số tiền *:',
                      '0',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      suffix: _buildCurrencyDropdown(),
                    ),
                    const SizedBox(height: 20),
                    
                    if (filteredCategories.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            final isSelected = _selectedCategory == category.id;
                            
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = isSelected ? null : category.id;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? (_selectedType == IncomeExpenseType.income 
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1))
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected 
                                          ? (_selectedType == IncomeExpenseType.income 
                                              ? Colors.green 
                                              : Colors.red)
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        category.icon ?? '📁',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category.text ?? 'Không tên',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected 
                                              ? (_selectedType == IncomeExpenseType.income 
                                                  ? Colors.green 
                                                  : Colors.red)
                                              : Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có danh mục nào cho ${_selectedType == IncomeExpenseType.income ? 'thu nhập' : 'chi tiêu'}',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),

                    // Nút thêm giao dịch
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedCategory != null ? _addTransaction : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedType == IncomeExpenseType.income 
                              ? Colors.green 
                              : Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedType == IncomeExpenseType.income 
                                  ? Icons.add 
                                  : Icons.remove,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedType == IncomeExpenseType.income 
                                  ? 'Thêm khoản thu' 
                                  : 'Thêm khoản chi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // PHẦN 3: DANH SÁCH KHOẢN THU CHI GẦN ĐÂY
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề phần danh sách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: Colors.pink[400],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Thu chi gần đây',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.pink[400],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showTimeFilterDialog(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedTimeFilter,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Danh sách giao dịch
                    if (filteredTransactions.isNotEmpty)
                      ...filteredTransactions.take(5).map((transaction) => _buildTransactionItem(transaction))
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có giao dịch nào trong tháng này',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String text, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    IconData? icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    Widget? suffix,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        // Label
        SizedBox(
          width: 70, // Độ rộng cố định cho label
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        
        // Input field
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: controller != null
                        ? TextField(
                            controller: controller,
                            keyboardType: keyboardType,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                            ),
                          )
                        : Text(
                            hint,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                  ),
                  if (suffix != null) suffix,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedCurrency,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(IncomeExpense transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icon và màu sắc
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.type == IncomeExpenseType.income
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.type == IncomeExpenseType.income
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: transaction.type == IncomeExpenseType.income
                  ? Colors.green
                  : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Thông tin giao dịch
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Không có mô tả',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngày ${transaction.date.day}-${transaction.date.month}-${transaction.date.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Số tiền
          Text(
            '${transaction.amount.toStringAsFixed(0)} VND',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: transaction.type == IncomeExpenseType.income
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount < 0) {
      return '${(amount.abs() / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTransaction() {
    if (_selectedCategory == null) return;
    
    // TODO: Implement actual transaction creation
    print('Adding transaction:');
    print('Type: ${_selectedType == IncomeExpenseType.income ? 'Income' : 'Expense'}');
    print('Description: ${_descriptionController.text}');
    print('Amount: ${_amountController.text}');
    print('Category: $_selectedCategory');
    print('Currency: $_selectedCurrency');
    print('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}');
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ${_selectedType == IncomeExpenseType.income ? 'thu nhập' : 'chi tiêu'} thành công!',
        ),
        backgroundColor: _selectedType == IncomeExpenseType.income ? Colors.green : Colors.red,
      ),
    );
    
    // Reset form
    _descriptionController.clear();
    _amountController.text = '0';
    _selectedCategory = null;
  }

  List<IncomeExpense> _getFilteredTransactions(List<IncomeExpense> allTransactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_selectedTimeFilter) {
      case 'Hôm nay':
        return allTransactions.where((transaction) {
          final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
          return transactionDate == today;
        }).toList();
        
      case 'Tuần này':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return allTransactions.where((transaction) {
          return transaction.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                 transaction.date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
        
      case 'Tháng này':
        return allTransactions.where((transaction) {
          return transaction.date.month == now.month && transaction.date.year == now.year;
        }).toList();
        
      case 'Năm này':
        return allTransactions.where((transaction) {
          return transaction.date.year == now.year;
        }).toList();
        
      default:
        return allTransactions;
    }
  }

  void _showTimeFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn khoảng thời gian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeFilterOption('Hôm nay'),
              _buildTimeFilterOption('Tuần này'),
              _buildTimeFilterOption('Tháng này'),
              _buildTimeFilterOption('Năm này'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeFilterOption(String option) {
    final isSelected = _selectedTimeFilter == option;
    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          color: isSelected ? Colors.pink[400] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      leading: isSelected 
          ? Icon(Icons.check_circle, color: Colors.pink[400])
          : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
      onTap: () {
        setState(() {
          _selectedTimeFilter = option;
        });
        Navigator.of(context).pop();
      },
    );
  }
}

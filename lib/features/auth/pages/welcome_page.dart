import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sochitieu/shared/models/category.dart';
import 'package:flutter_sochitieu/shared/models/income_expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/models/user.dart';
import '../../../core/constants/app_constants.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../../home/pages/home_page.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
    _checkFirstLaunch();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;
      
      if (isFirstLaunch) {
        // Lần đầu mở app, tạo dữ liệu mẫu
        await _createSampleData();
        await prefs.setBool(AppConstants.isFirstLaunchKey, false);
      }
    } catch (e) {
      print('Lỗi khi kiểm tra lần đầu mở app: $e');
    }
  }

  Future<void> _createSampleData() async {
    try {
      // Tạo danh mục mẫu
      final sampleCategories = [
        Category(
          id: 'cat_1',
          name: 'food',
          text: 'Ăn uống',
          icon: '🍽️',
          color: '#FF6B6B',
          order: 1,
          type: IncomeExpenseType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'sample_user', // Thêm userId mẫu
        ),
        Category(
          id: 'cat_2',
          name: 'transport',
          text: 'Di chuyển',
          icon: '🚗',
          color: '#4ECDC4',
          order: 2,
          type: IncomeExpenseType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'sample_user', // Thêm userId mẫu
        ),
        Category(
          id: 'cat_3',
          name: 'shopping',
          text: 'Mua sắm',
          icon: '🛍️',
          color: '#45B7D1',
          order: 3,
          type: IncomeExpenseType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'sample_user', // Thêm userId mẫu
        ),
        Category(
          id: 'cat_4',
          name: 'salary',
          text: 'Lương',
          icon: '💰',
          color: '#96CEB4',
          order: 1,
          type: IncomeExpenseType.income,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'sample_user', // Thêm userId mẫu
        ),
        Category(
          id: 'cat_5',
          name: 'investment',
          text: 'Đầu tư',
          icon: '📈',
          color: '#FFEAA7',
          order: 2,
          type: IncomeExpenseType.income,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'sample_user', // Thêm userId mẫu
        ),
      ];

      final databaseService = ref.read(databaseServiceProvider);
      for (final category in sampleCategories) {
        try {
          await databaseService.insertCategory(category);
          print('Đã tạo danh mục: ${category.text}');
        } catch (e) {
          print('Lỗi khi tạo danh mục ${category.text}: $e');
        }
      }

      // Refresh categories
      await ref.read(categoriesProvider.notifier).refresh();
      print('Đã tạo xong dữ liệu mẫu');
    } catch (e) {
      print('Lỗi khi tạo dữ liệu mẫu: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo và tên app
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 60,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Quản lý tài chính cá nhân thông minh',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Các nút hành động
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Nút "Dùng ngay không cần đăng nhập"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _useWithoutLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.defaultPadding + 4,
                              ),
                            ),
                            child: const Text(
                              'Dùng ngay không cần đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Nút "Đăng nhập"
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _goToLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.defaultPadding + 4,
                              ),
                            ),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Nút "Đăng ký"
                        TextButton(
                          onPressed: _goToRegister,
                          child: Text(
                            'Chưa có tài khoản? Đăng ký ngay',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Thông tin bổ sung
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Dữ liệu sẽ được lưu cục bộ và có thể đồng bộ khi đăng nhập',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _useWithoutLogin() async {
    try {
      // Tạo user offline
      final offlineUser = User(
        id: 'offline_user',
        userName: 'offline_user',
        email: null,
        fullName: 'Người dùng offline',
        phone: null,
        avatar: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isOnline: false,
      );

      // Lưu user vào database
      await ref.read(databaseServiceProvider).insertUser(offlineUser);
      
      // Cập nhật state
      ref.read(currentUserProvider.notifier).setCurrentUser(offlineUser);
      
      // Chuyển đến trang chủ
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
}

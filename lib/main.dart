import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/models/income_expense.dart';
import 'shared/models/category.dart';
import 'shared/models/user.dart';
import 'shared/services/database_service.dart';
import 'shared/services/api_service.dart';
import 'shared/services/sync_service.dart';
import 'shared/providers/app_providers.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cấu hình Hive
  await Hive.initFlutter();
  
  // Đăng ký adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(IncomeExpenseTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(IncomeExpenseAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(UserAdapter());
  }
  
  // Mở boxes
  await Hive.openBox('income_expenses');
  await Hive.openBox('categories');
  await Hive.openBox('users');
  
  // Khởi tạo SharedPreferences
  await SharedPreferences.getInstance();
  
  // Khởi tạo database
  final databaseService = DatabaseService();
  await databaseService.database;
  
  // Khởi tạo API service
  final apiService = ApiService();
  
  // Khởi tạo sync service
  final syncService = SyncService(databaseService, apiService);
  
  // Cấu hình hệ thống
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Cấu hình orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(databaseService),
        apiServiceProvider.overrideWithValue(apiService),
        syncServiceProvider.overrideWithValue(syncService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        // fontFamily: 'Roboto', // Commented out until fonts are added
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: AppConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.defaultPadding,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        // fontFamily: 'Roboto', // Commented out until fonts are added
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: AppConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.defaultPadding,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sochitieu/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_sochitieu/features/history/presentation/pages/history_page.dart';
import 'package:flutter_sochitieu/features/report/presentation/pages/report_page.dart';
import 'overview_page.dart';
import 'package:flutter_sochitieu/shared/providers/app_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OverviewPage(), // Sử dụng OverviewPage mới
    const HistoryPage(), // Sử dụng HistoryPage thay vì TransactionsTab
    const ReportPage(), 
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Kick off a sync if user is logged in; don't block UI
    // ignore: avoid_void_async
    Future<void>(() async {
      final user = ref.read(currentUserProvider);
      if (user?.isOnline == true) {
        final syncService = ref.read(syncServiceProvider);
        // ignore: unawaited_futures
        syncService.syncWhenOnline();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //         Navigator.of(context).push(
      //           MaterialPageRoute(
      //             builder: (context) => const AddTransactionPage(),
      //           ),
      //         );
      //       },
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   foregroundColor: Theme.of(context).colorScheme.onPrimary,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}


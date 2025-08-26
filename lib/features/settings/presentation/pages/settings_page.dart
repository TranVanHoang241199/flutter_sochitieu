import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sochitieu/features/auth/presentation/pages/welcome_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sochitieu/shared/utils/formatters.dart';
import 'package:flutter_sochitieu/shared/providers/app_providers.dart';
import '../widgets/setting_section_header.dart';
import '../widgets/setting_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _autoSyncEnabled = true;
  String _selectedCurrency = 'VND';
  String _selectedLanguage = 'Tiếng Việt';
  double _budgetLimit = 5000000;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final bool isLoggedIn = currentUser?.isOnline == true; // offline user is not logged in
    _darkModeEnabled = themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    (currentUser?.fullName?.isNotEmpty ?? false)
                        ? (currentUser!.fullName!)
                        : 'Người dùng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    (currentUser?.email?.isNotEmpty ?? false)
                        ? (currentUser!.email!)
                        : (isLoggedIn ? 'user@example.com' : 'Chế độ không đăng nhập'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cài đặt chung
            const SettingSectionHeader(title: 'Cài đặt chung'),
            SettingTile(
              icon: Icons.notifications,
              title: 'Thông báo',
              subtitle: 'Bật/tắt thông báo ứng dụng',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            SettingTile(
              icon: Icons.dark_mode,
              title: 'Chế độ tối',
              subtitle: 'Giao diện tối cho mắt',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) async {
                  final notifier = ref.read(themeModeProvider.notifier);
                  await notifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            SettingTile(
              icon: Icons.fingerprint,
              title: 'Xác thực sinh trắc học',
              subtitle: 'Đăng nhập bằng vân tay/face ID',
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cài đặt tài chính
            const SettingSectionHeader(title: 'Cài đặt tài chính'),
            SettingTile(
              icon: Icons.currency_exchange,
              title: 'Đơn vị tiền tệ',
              subtitle: _selectedCurrency,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showCurrencyPicker(),
            ),
            SettingTile(
              icon: Icons.account_balance_wallet,
              title: 'Giới hạn chi tiêu',
              subtitle: '₫${NumberFormat('#,###').format(_budgetLimit)}',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showBudgetLimitDialog(),
            ),
            SettingTile(
              icon: Icons.sync,
              title: 'Đồng bộ tự động',
              subtitle: 'Đồng bộ dữ liệu với cloud',
              trailing: Switch(
                value: _autoSyncEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoSyncEnabled = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cài đặt ngôn ngữ
            const SettingSectionHeader(title: 'Ngôn ngữ & Khu vực'),
            SettingTile(
              icon: Icons.language,
              title: 'Ngôn ngữ',
              subtitle: _selectedLanguage,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguagePicker(),
            ),
            
            const SizedBox(height: 20),
            
            // Cài đặt dữ liệu
            const SettingSectionHeader(title: 'Dữ liệu & Bảo mật'),
            SettingTile(
              icon: Icons.backup,
              title: 'Sao lưu dữ liệu',
              subtitle: 'Tạo bản sao lưu',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showBackupDialog(),
            ),
            SettingTile(
              icon: Icons.restore,
              title: 'Khôi phục dữ liệu',
              subtitle: 'Khôi phục từ bản sao lưu',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showRestoreDialog(),
            ),
            SettingTile(
              icon: Icons.delete_forever,
              title: 'Xóa dữ liệu',
              subtitle: 'Xóa tất cả dữ liệu',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeleteDataDialog(),
            ),
            
            const SizedBox(height: 20),
            
            // Thông tin ứng dụng
            const SettingSectionHeader(title: 'Thông tin ứng dụng'),
            SettingTile(
              icon: Icons.info,
              title: 'Phiên bản',
              subtitle: '1.0.0',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showAboutDialog(),
            ),
            SettingTile(
              icon: Icons.privacy_tip,
              title: 'Chính sách bảo mật',
              subtitle: 'Đọc chính sách bảo mật',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyPolicy(),
            ),
            SettingTile(
              icon: Icons.description,
              title: 'Điều khoản sử dụng',
              subtitle: 'Đọc điều khoản sử dụng',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showTermsOfService(),
            ),
            
            const SizedBox(height: 20),
            
            // Nút thoát / đăng xuất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showExitDialog(isLoggedIn: isLoggedIn),
                  icon: const Icon(Icons.exit_to_app),
                  label: Text(isLoggedIn ? 'Thoát và Đăng xuất' : 'Thoát'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn đơn vị tiền tệ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCurrencyOption('VND', 'Đồng Việt Nam', '₫'),
            _buildCurrencyOption('USD', 'Đô la Mỹ', '\$'),
            _buildCurrencyOption('EUR', 'Euro', '€'),
            _buildCurrencyOption('JPY', 'Yên Nhật', '¥'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name, String symbol) {
    return ListTile(
      leading: Text(
        symbol,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      title: Text(code),
      subtitle: Text(name),
      trailing: _selectedCurrency == code ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setState(() {
          _selectedCurrency = code;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showBudgetLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt giới hạn chi tiêu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (context, setLocalState) {
                final controller = TextEditingController(text: NumberFormat('#,###').format(_budgetLimit.round()));
                return TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (VND)',
                    border: OutlineInputBorder(),
                  ),
                  controller: controller,
                  onChanged: (value) {
                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(digits);
                    if (amount != null) {
                      setState(() {
                        _budgetLimit = amount;
                      });
                      setLocalState(() {});
                    }
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn ngôn ngữ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption('Tiếng Việt', 'vi'),
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('中文', 'zh'),
            _buildLanguageOption('日本語', 'ja'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code) {
    return ListTile(
      title: Text(name),
      trailing: _selectedLanguage == name ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = name;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao lưu dữ liệu'),
        content: const Text('Bạn có muốn tạo bản sao lưu dữ liệu hiện tại không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo bản sao lưu thành công!')),
              );
            },
            child: const Text('Sao lưu'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dữ liệu'),
        content: const Text('Bạn có muốn khôi phục dữ liệu từ bản sao lưu không? Dữ liệu hiện tại sẽ bị ghi đè.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã khôi phục dữ liệu thành công!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả dữ liệu? Hành động này không thể hoàn tác!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa tất cả dữ liệu!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sổ Chi Tiêu v1.0.0'),
            SizedBox(height: 8),
            Text('Ứng dụng quản lý tài chính cá nhân'),
            SizedBox(height: 8),
            Text('© 2024 Sổ Chi Tiêu Team'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Chính sách bảo mật')),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Text(
              'Chính sách bảo mật của ứng dụng Sổ Chi Tiêu...',
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Điều khoản sử dụng')),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Text(
              'Điều khoản sử dụng của ứng dụng Sổ Chi Tiêu...',
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog({required bool isLoggedIn}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLoggedIn ? 'Thoát và đăng xuất' : 'Thoát ứng dụng'),
        content: Text(
          isLoggedIn
              ? 'Bạn có chắc chắn muốn thoát và đăng xuất?'
              : 'Bạn đang sử dụng chế độ không đăng nhập. Nếu thoát, dữ liệu cục bộ có thể mất. Hãy đăng nhập để sao lưu dữ liệu trước khi thoát.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (isLoggedIn) {
                  await ref.read(currentUserProvider.notifier).clearCurrentUser();
                  ref.read(apiServiceProvider).clearAccessToken();
                }
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isLoggedIn ? 'Thoát và Đăng xuất' : 'Thoát'),
          ),
        ],
      ),
    );
  }

  // Deprecated old method placeholder to avoid confusion
  void _showLogoutDialog() {}
}

import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
      ),
      body: const Center(
        child: Text('Trang đăng ký sẽ được hiển thị ở đây'),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/screens/main_screen.dart';
import 'package:the_cherry_pet_shop/utils/auth.dart';

import '../../models/user_model.dart';
import '../../shared_preferences/token_manager.dart';
import 'forgot_password_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    // Thiết lập animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kiểm tra trạng thái đăng nhập thông qua TokenManager
  Future<void> _checkLoginStatus() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  // Hàm xử lý đăng nhập
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> result = await Auth.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Vì token đã được lưu qua TokenManager trong Auth.login,
      // chỉ cần lưu thông tin người dùng vào session.
      Map<String, dynamic> decodedToken = result['decodedToken'];
      UserModel user = UserModel.fromJson(decodedToken);

      await TokenManager.saveSession(json.encode({
        'username': _usernameController.text,
        'userId': _usernameController.text,
        'user_info': user.toJson()
      }));

      // Hiển thị hộp thoại hỏi có lưu mật khẩu cho lần đăng nhập sau không
      bool? shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Save Password"),
            content: const Text(
                "Would you like to save your password for next login?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );

      if (shouldSave == true) {
        // Giả sử bạn đã bổ sung hàm savePassword vào TokenManager
        await TokenManager.savePassword(_passwordController.text);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      String errorMessage =
          result['message'] ?? 'Tên đăng nhập hoặc mật khẩu không đúng';
      _showErrorSnackbar(errorMessage);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/nen-pet.png'),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.04),
                        // Logo and brand name
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/nen-pet.png',
                            height: 60,
                            width: 60,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // App name
                        Text(
                          'The Cherry PetShop',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700],
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đăng nhập để tiếp tục',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        // Login card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username field
                              Text(
                                'Tên đăng nhập',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập tên đăng nhập';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Nhập tên đăng nhập của bạn',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[400], fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: Colors.pink[300]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.pink[300]!, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Password field
                              Text(
                                'Mật khẩu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Nhập mật khẩu của bạn',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[400], fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: Colors.pink[300]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.pink[300]!, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: () {
                                      setState(() =>
                                          _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                ),
                              ),
                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.pink[700],
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Login button
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink[700],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'ĐĂNG NHẬP',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Chưa có tài khoản? ",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.pink[700],
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 30),
                              ),
                              child: Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: Colors.pink[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

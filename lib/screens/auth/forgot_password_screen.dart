import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    usernameController.dispose();
    super.dispose();
  }

  Future<void> sendOtp(BuildContext context) async {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      _showSnackBar(context, "Vui lòng nhập tên đăng nhập", Colors.redAccent);
      return;
    }

    print("Sending OTP request with username: $username");

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final response = await apiClient.post(
        'Authenticate/send-otp',
        body: username,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == true) {
          final otp = body['otp']?.toString() ?? '';
          if (otp.isNotEmpty) {
            await _showOtpDialog(context, otp);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(username: username),
              ),
            );
          } else {
            _showSnackBar(
                context, "Không nhận được mã OTP, thử lại.", Colors.redAccent);
          }
        } else {
          _showSnackBar(context, "Lỗi: ${body['message'] ?? 'Không xác định'}", Colors.redAccent);
        }
      } else {
        String errorMessage = "Lỗi không xác định";
        try {
          final body = jsonDecode(response.body);
          errorMessage = body['errors']?["\$"]?.first ?? body['message'] ?? "Lỗi không xác định (mã ${response.statusCode})";
        } catch (_) {
          errorMessage = "Lỗi không xác định (mã ${response.statusCode})";
        }
        _showSnackBar(context, errorMessage, Colors.redAccent);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(context, "Đã xảy ra lỗi: $e", Colors.redAccent);
    }
  }

  Future<void> _showOtpDialog(BuildContext context, String otp) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Mã OTP của bạn'),
        content: Text(
          otp,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              bg == Colors.redAccent
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
                child:
                Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
            ),
            child: Icon(Icons.arrow_back, color: primaryColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.03),
                        Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Nhập tên đăng nhập của bạn.",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4),
                        ),
                        SizedBox(height: size.height * 0.04),
                        Center(
                          child: Icon(Icons.lock_reset,
                              size: size.width * 0.2,
                              color: primaryColor.withOpacity(0.7)),
                        ),
                        SizedBox(height: size.height * 0.05),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tên đăng nhập",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800])),
                              const SizedBox(height: 8),
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  hintText: "Nhập tên đăng nhập",
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: primaryColor),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: primaryColor, width: 1)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => sendOtp(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                        AlwaysStoppedAnimation(
                                            Colors.white)),
                                  )
                                      : const Text("Gửi mã OTP"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Màn hình Reset Password
class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({Key? key, required this.username})
      : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(BuildContext context) async {
    final otp = otpController.text.trim();
    final np = newPasswordController.text.trim();
    final cp = confirmPasswordController.text.trim();
    if (otp.isEmpty || np.isEmpty || cp.isEmpty) {
      _showSnackBar(
          context, "Vui lòng điền đầy đủ thông tin", Colors.redAccent);
      return;
    }
    if (np != cp) {
      _showSnackBar(context, "Mật khẩu xác nhận không khớp", Colors.redAccent);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final api = ApiClient();
      final res = await api.post('Authenticate/reset-password', body: {
        'username': widget.username,
        'resetCode': otp,
        'newPassword': np,
      });
      setState(() => _isLoading = false);
      if (res.statusCode == 200) {
        _showSuccessDialog(context);
      } else {
        final body = jsonDecode(res.body);
        _showSnackBar(context, "Lỗi: ${body['message']}", Colors.redAccent);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(context, "Đã xảy ra lỗi: $e", Colors.redAccent);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FadeTransition(
        opacity: _fadeAnim,
        child: Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.green.shade50),
                child: Icon(Icons.check_circle_outline,
                    size: 50, color: Colors.green.shade600),
              ),
              const SizedBox(height: 16),
              const Text("Đặt lại mật khẩu thành công!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  "Bạn có thể đăng nhập bằng mật khẩu mới của mình ngay bây giờ.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("Quay lại đăng nhập"),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
              bg == Colors.redAccent
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white))),
        ]),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white.withOpacity(0.8)),
            child: Icon(Icons.arrow_back, color: primaryColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.white,
                Colors.purple.shade50,
              ]),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.03),
                          Text("Đặt lại mật khẩu",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          const SizedBox(height: 8),
                          Text("Nhập mã OTP và mật khẩu mới.",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4)),
                          SizedBox(height: size.height * 0.02),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mã OTP",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800])),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: otpController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Nhập mã OTP",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      prefixIcon: Icon(Icons.security,
                                          color: primaryColor),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: primaryColor, width: 1)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text("Mật khẩu mới",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800])),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: newPasswordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: "Nhập mật khẩu mới",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      prefixIcon: Icon(Icons.lock_outline,
                                          color: primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey[600]),
                                        onPressed: () => setState(() =>
                                        _obscurePassword =
                                        !_obscurePassword),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: primaryColor, width: 1)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text("Xác nhận mật khẩu",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800])),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: confirmPasswordController,
                                    obscureText: _obscureConfirm,
                                    decoration: InputDecoration(
                                      hintText: "Nhập lại mật khẩu mới",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      prefixIcon: Icon(Icons.lock_outline,
                                          color: primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscureConfirm
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey[600]),
                                        onPressed: () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: primaryColor, width: 1)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => resetPassword(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                              AlwaysStoppedAnimation(
                                                  Colors.white)))
                                          : const Text("Đặt lại mật khẩu"),
                                    ),
                                  ),
                                ]),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

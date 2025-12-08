import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/local_storage.dart';
import '../services/auth_service.dart';
import 'build_simulator_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _agreeTerms = false;
  bool _agreeNewsletter = false;
  bool _isLoading = false;

  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  double _passwordStrength = 0;
  String _passwordStrengthText = 'กรุณากรอกรหัสผ่าน';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _emailError.isEmpty &&
        _passwordError.isEmpty &&
        _confirmPasswordError.isEmpty &&
        _agreeTerms;
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text;
      if (email.isEmpty) {
        _emailError = '';
      } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        _emailError = 'รูปแบบอีเมลไม่ถูกต้อง';
      } else {
        _emailError = '';
      }
    });
  }

  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;

      if (password.isEmpty) {
        _passwordError = '';
        _passwordStrength = 0;
        _passwordStrengthText = 'กรุณากรอกรหัสผ่าน';
        _passwordStrengthColor = Colors.grey;
      } else if (password.length < 8) {
        _passwordError = 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
        _passwordStrength = 0.25;
        _passwordStrengthText = 'รหัสผ่านสั้นเกินไป';
        _passwordStrengthColor = const Color(0xFFef4444);
      } else {
        _passwordError = '';

        // Calculate password strength
        int strength = 0;
        if (password.length >= 8) strength++;
        if (RegExp(r'[a-z]').hasMatch(password)) strength++;
        if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
        if (RegExp(r'[0-9]').hasMatch(password)) strength++;
        if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) strength++;

        if (strength <= 2) {
          _passwordStrength = 0.4;
          _passwordStrengthText = 'รหัสผ่านอ่อน';
          _passwordStrengthColor = const Color(0xFFef4444);
        } else if (strength <= 3) {
          _passwordStrength = 0.7;
          _passwordStrengthText = 'รหัสผ่านปานกลาง';
          _passwordStrengthColor = const Color(0xFFf59e0b);
        } else {
          _passwordStrength = 1.0;
          _passwordStrengthText = 'รหัสผ่านแข็งแกร่ง';
          _passwordStrengthColor = const Color(0xFF10A37F);
        }
      }

      // Revalidate confirm password if it has value
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword();
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      final confirmPassword = _confirmPasswordController.text;
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = '';
      } else if (confirmPassword != _passwordController.text) {
        _confirmPasswordError = 'รหัสผ่านไม่ตรงกัน';
      } else {
        _confirmPasswordError = '';
      }
    });
  }

  void _handleRegistration() async {
    // Final validation
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    if (!_isFormValid()) {
      _showSnackBar('กรุณาตรวจสอบข้อมูลให้ถูกต้อง', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Save newsletter preference
      if (_agreeNewsletter) {
        final formData = {
          'email': _emailController.text,
          'newsletter': _agreeNewsletter,
          'registrationTime': DateTime.now().toIso8601String(),
        };
        setLocalStorageItem('toramRegistration', jsonEncode(formData));
      }

      _showSnackBar(
          'สมัครสมาชิกสำเร็จ! กำลังเข้าสู่ระบบ...', const Color(0xFF10A37F));

      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigateToApp();
      });
    } else {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BuildSimulatorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF192127),
      body: Stack(
        children: [
          // Background decoration
          //..._buildFloatingIcons(),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF10A37F).withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 60,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top gradient line
                    Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF10A37F),
                            Color(0xFF0ea5e9),
                            Color(0xFF8b5cf6),
                            Color(0xFF10A37F),
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildForm(),
                          if (_isLoading) ...[
                            const SizedBox(height: 20),
                            _buildLoadingIndicator(),
                          ],
                          const SizedBox(height: 30),
                          _buildFooter(),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Text(
                    '⚔️',
                    style: TextStyle(fontSize: 40),
                  ),
                );
              },
              onEnd: () {
                setState(() {});
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Toram Build Simulator',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10A37F),
                shadows: [
                  Shadow(
                    color: Color(0xFF10A37F),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'สร้างและปรับแต่งบิลด์ตัวละครของคุณ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'สมัครสมาชิกใหม่',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF10A37F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        const Text(
          'อีเมล',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF10A37F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'กรอกอีเมลของคุณ',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError.isNotEmpty
                    ? const Color(0xFFef4444)
                    : const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError.isNotEmpty
                    ? const Color(0xFFef4444)
                    : _emailController.text.isNotEmpty && _emailError.isEmpty
                        ? const Color(0xFF10A37F)
                        : const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF10A37F),
                width: 2,
              ),
            ),
          ),
          onChanged: (_) => _validateEmail(),
        ),
        if (_emailError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _emailError,
              style: const TextStyle(
                color: Color(0xFFef4444),
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Password field
        const Text(
          'รหัสผ่าน',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF10A37F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'สร้างรหัสผ่าน (อย่างน้อย 8 ตัวอักษร)',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordError.isNotEmpty
                    ? const Color(0xFFef4444)
                    : const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordError.isNotEmpty
                    ? const Color(0xFFef4444)
                    : _passwordController.text.isNotEmpty &&
                            _passwordError.isEmpty
                        ? const Color(0xFF10A37F)
                        : const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF10A37F),
                width: 2,
              ),
            ),
            suffixIcon: IconButton(
              icon: Text(
                _passwordVisible ? '🙈' : '👁️',
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          onChanged: (_) => _validatePassword(),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Password strength bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(_passwordStrengthColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _passwordStrengthText,
            style: TextStyle(
              fontSize: 12,
              color: _passwordStrengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (_passwordError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _passwordError,
              style: const TextStyle(
                color: Color(0xFFef4444),
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Confirm Password field
        const Text(
          'ยืนยันรหัสผ่านอีกครั้ง',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF10A37F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_confirmPasswordVisible,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'กรอกรหัสผ่านอีกครั้ง',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _confirmPasswordError.isNotEmpty
                    ? const Color(0xFFef4444)
                    : const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _confirmPasswordError.isNotEmpty
                    ? const Color(0xFFef4444)
                    : _confirmPasswordController.text.isNotEmpty &&
                            _confirmPasswordError.isEmpty
                        ? const Color(0xFF10A37F)
                        : const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF10A37F),
                width: 2,
              ),
            ),
            suffixIcon: IconButton(
              icon: Text(
                _confirmPasswordVisible ? '🙈' : '👁️',
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
          ),
          onChanged: (_) => _validateConfirmPassword(),
        ),
        if (_confirmPasswordError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _confirmPasswordError,
              style: const TextStyle(
                color: Color(0xFFef4444),
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Terms section
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: const Color(0xFF10A37F).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeTerms = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF10A37F),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          children: const [
                            TextSpan(text: 'ฉันยอมรับ'),
                            TextSpan(
                              text: 'ข้อกำหนดการใช้งาน',
                              style: TextStyle(
                                color: Color(0xFF10A37F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: 'และ'),
                            TextSpan(
                              text: 'นโยบายความเป็นส่วนตัว',
                              style: TextStyle(
                                color: Color(0xFF10A37F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: 'ของ Toram Build Simulator'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeNewsletter,
                    onChanged: (value) {
                      setState(() {
                        _agreeNewsletter = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF10A37F),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'ฉันต้องการรับข่าวสารและอัปเดตใหม่ทางอีเมล (ไม่บังคับ)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isLoading || !_isFormValid() ? null : _handleRegistration,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color(0xFF10A37F),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'สมัครสมาชิก',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Color(0xFF10A37F),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'กำลังสมัครสมาชิก...',
          style: TextStyle(
            color: Color(0xFF10A37F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.only(bottom: 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'มีบัญชีอยู่แล้ว? ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                  color: Color(0xFF10A37F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // List<Widget> _buildFloatingIcons() {
  //   final icons = ['⚔️', '🛡️', '💎', '🎯', '⚡', '🔥', '❄️', '🌟', '💫'];
  //   return List.generate(icons.length, (index) {
  //     return Positioned(
  //       left: (index * 11.0) % 100,
  //       top: -50,
  //       child: TweenAnimationBuilder<double>(
  //         tween: Tween(begin: 0, end: 1),
  //         duration: Duration(seconds: 20 + index * 2),
  //         curve: Curves.linear,
  //         builder: (context, value, child) {
  //           return Transform.translate(
  //             offset: Offset(0, MediaQuery.of(context).size.height * value),
  //             child: Transform.rotate(
  //               angle: value * 6.28 * 2,
  //               child: Opacity(
  //                 opacity: 0.1,
  //                 child: Text(
  //                   icons[index],
  //                   style: const TextStyle(fontSize: 32),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //         onEnd: () {
  //           setState(() {});
  //         },
  //       ),
  //     );
  //   });
  // }
}

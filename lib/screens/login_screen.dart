import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/local_storage.dart';
import 'build_simulator_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;
  bool _isLoading = false;
  String _selectedOption = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _checkExistingLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkExistingLogin() {
    final savedLogin = getLocalStorageItem('toramLogin');
    if (savedLogin != null && savedLogin.isNotEmpty) {
      try {
        final loginData = jsonDecode(savedLogin);
        final loginTime = DateTime.parse(loginData['loginTime']);
        final now = DateTime.now();
        final hoursDiff = now.difference(loginTime).inHours;

        final maxHours = loginData['rememberMe'] == true ? 24 : 2;

        if (hoursDiff < maxHours) {
          _showSnackBar('พบการเข้าสู่ระบบเดิม กำลังเข้าสู่แอป...', Colors.blue);
          Future.delayed(const Duration(milliseconds: 1500), () {
            _navigateToApp();
          });
        } else {
          setLocalStorageItem('toramLogin', '');
        }
      } catch (_) {}
    }
  }

  void _selectLoginOption(String option) {
    setState(() {
      _selectedOption = option;
      if (option == 'email') {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleEmailLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('กรุณากรอกอีเมลและรหัสผ่าน', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      final loginData = {
        'email': _emailController.text,
        'loginTime': DateTime.now().toIso8601String(),
        'rememberMe': _rememberMe,
        'userType': 'registered',
      };

      setLocalStorageItem('toramLogin', jsonEncode(loginData));

      setState(() => _isLoading = false);
      _showSnackBar('เข้าสู่ระบบสำเร็จ!', const Color(0xFF10A37F));

      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigateToApp();
      });
    });
  }

  void _handleGuestLogin() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      final guestData = {
        'userType': 'guest',
        'loginTime': DateTime.now().toIso8601String(),
        'sessionId': 'guest_${DateTime.now().millisecondsSinceEpoch}',
      };

      setLocalStorageItem('toramLogin', jsonEncode(guestData));

      setState(() => _isLoading = false);
      _showSnackBar('เข้าใช้แบบเกสสำเร็จ!', const Color(0xFF10A37F));

      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigateToApp();
      });
    });
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
          // ..._buildFloatingIcons(),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
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
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF10A37F),
                            Color(0xFF0ea5e9),
                            Color(0xFF8b5cf6),
                            Color(0xFF10A37F),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
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
                          _buildLoginOptions(),
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
          'ยินดีต้อนรับสู่ระบบ',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF10A37F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginOptions() {
    return Column(
      children: [
        _buildEmailLoginOption(),
        const SizedBox(height: 20),
        _buildGuestLoginOption(),
      ],
    );
  }

  Widget _buildEmailLoginOption() {
    final isSelected = _selectedOption == 'email';
    return GestureDetector(
      onTap: () => _selectLoginOption('email'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10A37F)
                : const Color(0xFF10A37F).withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10A37F).withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📧', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 15),
                const Text(
                  'เข้าสู่ระบบด้วยอีเมล',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'เข้าสู่ระบบเพื่อบันทึกและซิงค์บิลด์ของคุณในคลาวด์',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 15),
            ..._buildFeaturesList([
              'บันทึกบิลด์ไม่จำกัด',
              'ซิงค์ข้อมูลข้ามอุปกรณ์',
              'แชร์บิลด์กับเพื่อน',
              'เข้าถึงฟีเจอร์พิเศษ',
            ]),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizeTransition(
                sizeFactor: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    _buildEmailForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLoginOption() {
    final isSelected = _selectedOption == 'guest';
    return GestureDetector(
      onTap: () => _selectLoginOption('guest'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10A37F)
                : const Color(0xFF10A37F).withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10A37F).withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👤', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 15),
                const Text(
                  'เข้าใช้แบบเกส',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'เริ่มใช้งานทันทีโดยไม่ต้องสมัครสมาชิก',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 15),
            ..._buildFeaturesList([
              'ใช้งานได้ทันที',
              'ไม่ต้องกรอกข้อมูล',
              'บิลด์จะบันทึกในเครื่องเท่านั้น',
              'ฟีเจอร์จำกัด',
            ], warning: [
              2,
              3
            ]),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleGuestLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFF10A37F).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'เข้าใช้แบบเกส',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeaturesList(List<String> features,
      {List<int> warning = const []}) {
    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;
      final isWarning = warning.contains(index);
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              isWarning ? '⚠️' : '✅',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          decoration: InputDecoration(
            hintText: 'กรอกอีเมลของคุณ',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF10A37F).withValues(alpha: 0.3),
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
        ),
        const SizedBox(height: 20),
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
            hintText: 'กรอกรหัสผ่าน',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF10A37F).withValues(alpha: 0.3),
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
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF10A37F),
                ),
                Text(
                  'จดจำการเข้าสู่ระบบ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                _showSnackBar(
                    'ฟีเจอร์รีเซ็ตรหัสผ่าน - เร็วๆ นี้!', Colors.blue);
              },
              child: const Text(
                'ลืมรหัสผ่าน?',
                style: TextStyle(
                  color: Color(0xFF10A37F),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color(0xFF10A37F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'เข้าสู่ระบบ',
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
          'กำลังเข้าสู่ระบบ...',
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
              'ยังไม่มีบัญชี? ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const RegisterScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                );
              },
              child: const Text(
                'สมัครสมาชิก',
                style: TextStyle(
                  color: Color(0xFF10A37F),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton('📘'),
            _buildSocialButton('💬'),
            _buildSocialButton('📺'),
            _buildSocialButton('🐙'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          _showSnackBar('ฟีเจอร์โซเชียลมีเดีย - เร็วๆ นี้!', Colors.blue);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
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

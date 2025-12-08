import 'dart:convert';
import 'local_storage.dart';

// -----------------------------------------------------------------------------
// Authentication Service
// - Handles user authentication (login, logout, register)
// - Manages user sessions
// - Stores user data locally
// -----------------------------------------------------------------------------

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current user data
  Map<String, dynamic>? _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Get current user
  Map<String, dynamic>? get currentUser => _currentUser;

  // Get user type (guest, registered, admin)
  String get userType => _currentUser?['userType'] ?? 'guest';

  // Get user email (if registered)
  String? get userEmail => _currentUser?['email'];

  // Initialize - load saved session
  Future<void> initialize() async {
    await _loadSession();
  }

  // Load saved session from storage
  Future<void> _loadSession() async {
    final savedLogin = getLocalStorageItem('toramLogin');
    if (savedLogin != null && savedLogin.isNotEmpty) {
      try {
        final data = jsonDecode(savedLogin);
        final loginTime = DateTime.parse(data['loginTime']);
        final now = DateTime.now();
        final hoursDiff = now.difference(loginTime).inHours;

        // Check session validity
        final maxHours =
            data['rememberMe'] == true ? 24 * 7 : 2; // 7 days or 2 hours

        if (hoursDiff < maxHours) {
          _currentUser = data;
        } else {
          // Session expired
          await logout();
        }
      } catch (e) {
        print('Error loading session: $e');
        await logout();
      }
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate email format
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'รูปแบบอีเมลไม่ถูกต้อง',
        };
      }

      // Validate password length
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
        };
      }

      // TODO: Replace with actual API call
      // For now, accept any valid format as successful login
      final userData = {
        'email': email,
        'userType': 'registered',
        'loginTime': DateTime.now().toIso8601String(),
        'rememberMe': rememberMe,
        'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'displayName': email.split('@')[0],
      };

      // Save to storage
      setLocalStorageItem('toramLogin', jsonEncode(userData));
      _currentUser = userData;

      return {
        'success': true,
        'message': 'เข้าสู่ระบบสำเร็จ!',
        'user': userData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Login as guest
  Future<Map<String, dynamic>> loginAsGuest() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final guestData = {
        'userType': 'guest',
        'loginTime': DateTime.now().toIso8601String(),
        'sessionId': 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'displayName': 'Guest User',
      };

      setLocalStorageItem('toramLogin', jsonEncode(guestData));
      _currentUser = guestData;

      return {
        'success': true,
        'message': 'เข้าใช้แบบเกสสำเร็จ!',
        'user': guestData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Validate email
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'รูปแบบอีเมลไม่ถูกต้อง',
        };
      }

      // Validate password
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
        };
      }

      // Check password match
      if (password != confirmPassword) {
        return {
          'success': false,
          'message': 'รหัสผ่านไม่ตรงกัน',
        };
      }

      // TODO: Replace with actual API call to backend
      // For now, save to local storage
      final userData = {
        'email': email,
        'userType': 'registered',
        'loginTime': DateTime.now().toIso8601String(),
        'rememberMe': true,
        'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'displayName': email.split('@')[0],
        'createdAt': DateTime.now().toIso8601String(),
      };

      setLocalStorageItem('toramLogin', jsonEncode(userData));
      _currentUser = userData;

      return {
        'success': true,
        'message': 'สมัครสมาชิกสำเร็จ!',
        'user': userData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    setLocalStorageItem('toramLogin', '');
    _currentUser = null;
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Get user display name
  String getDisplayName() {
    if (_currentUser == null) return 'Guest';
    if (_currentUser!['displayName'] != null) {
      return _currentUser!['displayName'];
    }
    if (_currentUser!['email'] != null) {
      return _currentUser!['email'].split('@')[0];
    }
    return 'User';
  }

  // Check if session is valid
  bool isSessionValid() {
    if (_currentUser == null) return false;

    try {
      final loginTime = DateTime.parse(_currentUser!['loginTime']);
      final now = DateTime.now();
      final hoursDiff = now.difference(loginTime).inHours;
      final maxHours = _currentUser!['rememberMe'] == true ? 24 * 7 : 2;

      return hoursDiff < maxHours;
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';
import '../services/auth_service.dart';
import '../widgets/navigation/navigation_rail.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<CustomNavigationRailState> _navRailKey =
      GlobalKey<CustomNavigationRailState>();
  final AuthService _authService = AuthService();

  bool _notifications = true;
  bool _darkMode = true;
  bool _autoSave = true;
  String _language = 'th';
  String _theme = 'dark';
  double _fontSize = 14.0;

  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserInfo();
  }

  void _loadSettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final settings = getLocalStorageItem('toramSettings');
    if (settings != null && settings.isNotEmpty) {
      try {
        final data = jsonDecode(settings);
        setState(() {
          _notifications = data['notifications'] ?? true;
          _darkMode = themeProvider.darkMode;
          _autoSave = data['autoSave'] ?? true;
          _language = data['language'] ?? 'th';
          _theme = themeProvider.theme;
          _fontSize = themeProvider.fontSize;
        });
      } catch (_) {}
    }
  }

  void _loadUserInfo() {
    final login = getLocalStorageItem('toramLogin');
    if (login != null && login.isNotEmpty) {
      try {
        final data = jsonDecode(login);
        setState(() {
          _userInfo = data;
        });
      } catch (_) {}
    }
  }

  void _saveSettings() {
    final settings = {
      'notifications': _notifications,
      'darkMode': _darkMode,
      'autoSave': _autoSave,
      'language': _language,
      'theme': _theme,
      'fontSize': _fontSize,
    };
    setLocalStorageItem('toramSettings', jsonEncode(settings));
  }

  void _logout() async {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors?.cardBackground ?? theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'ออกจากระบบ',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'คุณต้องการออกจากระบบหรือไม่?',
          style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SettingsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'ออกจากระบบ',
            ),
          ),
        ],
      ),
    );
  }

  void _clearData() {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors?.cardBackground ?? theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'ล้างข้อมูลทั้งหมด',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'คุณต้องการลบข้อมูลทั้งหมดหรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
          style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setLocalStorageItem('toramBuilds', '');
              setLocalStorageItem('toramSettings', '');
              Navigator.pop(context);
              _showSnackBar('ล้างข้อมูลสำเร็จ!', theme.primaryColor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
            ),
            child: const Text('ล้างข้อมูล'),
          ),
        ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        Widget body;
        if (isWide) {
          body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNavigationRail(key: _navRailKey, initialIndex: 2),
              Expanded(
                child: _buildSettingsContent(),
              ),
            ],
          );
        } else {
          body = _buildSettingsContent();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF192127),
          appBar: _buildHeader(isWide),
          body: body,
          bottomNavigationBar:
              isWide ? null : const CustomBottomNavigationBar(initialIndex: 2),
        );
      },
    );
  }

  PreferredSizeWidget _buildHeader(bool isWide) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.primaryColor,
      elevation: 4,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            if (isWide)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _navRailKey.currentState?.toggleExtended();
                },
                tooltip: 'Menu',
              ),
            if (isWide) const SizedBox(width: 8),
            const Image(
              image: AssetImage('assets/icon/Logo.png'),
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserSection(),
          const SizedBox(height: 24),
          _buildGeneralSettings(),
          const SizedBox(height: 24),
          _buildAppearanceSettings(),
          const SizedBox(height: 24),
          _buildDataSettings(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    final userType = _userInfo?['userType'] ?? 'guest';
    final email = _userInfo?['email'] ?? 'Guest User';
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Container(
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: theme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userType == 'guest' ? 'ผู้ใช้ทั่วไป' : 'สมาชิก',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_userInfo != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('ออกจากระบบ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFef4444),
                  side: const BorderSide(color: Color(0xFFef4444)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (_userInfo == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const LoginScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 200),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('เข้าสู่ระบบ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return _buildSection(
      title: 'ทั่วไป',
      icon: Icons.settings,
      children: [
        _buildSwitchTile(
          title: 'การแจ้งเตือน',
          subtitle: 'รับการแจ้งเตือนจากแอป',
          value: _notifications,
          onChanged: (value) {
            setState(() => _notifications = value);
            _saveSettings();
          },
        ),
        _buildSwitchTile(
          title: 'บันทึกอัตโนมัติ',
          subtitle: 'บันทึกการเปลี่ยนแปลงอัตโนมัติ',
          value: _autoSave,
          onChanged: (value) {
            setState(() => _autoSave = value);
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _buildSection(
      title: 'รูปแบบการแสดงผล',
      icon: Icons.palette,
      children: [
        _buildSwitchTile(
          title: 'โหมดมืด',
          subtitle: 'ใช้ธีมสีเข้ม',
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
            Provider.of<ThemeProvider>(context, listen: false)
                .setDarkMode(value);
            _saveSettings();
            _showSnackBar('เปลี่ยนโหมดสำเร็จ!', const Color(0xFF10A37F));
          },
        ),
        _buildDropdownTile(
          title: 'ธีมสี',
          subtitle: 'เลือกธีมสีที่ชอบ',
          value: _theme,
          items: const [
            {'value': 'dark', 'label': 'Dark'},
            {'value': 'blue', 'label': 'Blue'},
            {'value': 'green', 'label': 'Green'},
          ],
          onChanged: (value) {
            setState(() => _theme = value!);
            Provider.of<ThemeProvider>(context, listen: false).setTheme(value!);
            _saveSettings();
            _showSnackBar('เปลี่ยนธีมสีสำเร็จ!', const Color(0xFF10A37F));
          },
        ),
        _buildSliderTile(
          title: 'ขนาดตัวอักษร',
          subtitle: 'ปรับขนาดตัวอักษร',
          value: _fontSize,
          min: 12,
          max: 20,
          divisions: 8,
          onChanged: (value) {
            setState(() => _fontSize = value);
            Provider.of<ThemeProvider>(context, listen: false)
                .setFontSize(value);
            _saveSettings();
          },
          onChangeEnd: (value) {
            _showSnackBar(
                'เปลี่ยนขนาดตัวอักษรสำเร็จ!', const Color(0xFF10A37F));
          },
        ),
      ],
    );
  }

  Widget _buildDataSettings() {
    final theme = Theme.of(context);

    return _buildSection(
      title: 'ข้อมูล',
      icon: Icons.storage,
      children: [
        ListTile(
          leading: Icon(Icons.file_download, color: theme.primaryColor),
          title: Text(
            'ส่งออกข้อมูล',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          subtitle: Text(
            'ส่งออกบิลด์และการตั้งค่า',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onTap: () {
            _showSnackBar('ฟีเจอร์ส่งออกข้อมูล - เร็วๆ นี้!', Colors.blue);
          },
        ),
        ListTile(
          leading: Icon(Icons.file_upload, color: theme.primaryColor),
          title: Text(
            'นำเข้าข้อมูล',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          subtitle: Text(
            'นำเข้าบิลด์จากไฟล์',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onTap: () {
            _showSnackBar('ฟีเจอร์นำเข้าข้อมูล - เร็วๆ นี้!', Colors.blue);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Color(0xFFef4444)),
          title: const Text(
            'ล้างข้อมูลทั้งหมด',
            style: TextStyle(color: Color(0xFFef4444)),
          ),
          subtitle: Text(
            'ลบบิลด์และการตั้งค่าทั้งหมด',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onTap: _clearData,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final theme = Theme.of(context);

    return _buildSection(
      title: 'เกี่ยวกับ',
      icon: Icons.info,
      children: [
        ListTile(
          leading: Icon(Icons.description, color: theme.primaryColor),
          title: Text(
            'เงื่อนไขการใช้งาน',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onTap: () {
            _showSnackBar('เงื่อนไขการใช้งาน - เร็วๆ นี้!', Colors.blue);
          },
        ),
        ListTile(
          leading: Icon(Icons.privacy_tip, color: theme.primaryColor),
          title: Text(
            'นโยบายความเป็นส่วนตัว',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onTap: () {
            _showSnackBar('นโยบายความเป็นส่วนตัว - เร็วๆ นี้!', Colors.blue);
          },
        ),
        ListTile(
          leading: Icon(Icons.help, color: theme.primaryColor),
          title: Text(
            'ช่วยเหลือ',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          onTap: () {
            _showSnackBar('ศูนย์ช่วยเหลือ - เร็วๆ นี้!', Colors.blue);
          },
        ),
        ListTile(
          leading: Icon(Icons.code, color: theme.primaryColor),
          title: Text(
            'เวอร์ชัน',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          subtitle: Text(
            '1.0.0',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Container(
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.dividerColor,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: customColors?.cardBackground ?? theme.cardColor,
        style: TextStyle(color: theme.colorScheme.onSurface),
        underline: Container(),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          trailing: Text(
            '${value.toInt()}',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: theme.primaryColor,
            inactiveColor: theme.dividerColor,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}

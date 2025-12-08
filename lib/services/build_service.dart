import 'dart:convert';
import 'local_storage.dart';

// -----------------------------------------------------------------------------
// Build Service
// - Handles save/load builds
// - Manages build data
// - Stores builds locally or in cloud (future)
// -----------------------------------------------------------------------------

class BuildService {
  static final BuildService _instance = BuildService._internal();
  factory BuildService() => _instance;
  BuildService._internal();

  // Cache for builds
  List<Map<String, dynamic>> _builds = [];

  // Get all builds
  List<Map<String, dynamic>> get builds => List.unmodifiable(_builds);

  // Initialize - load saved builds
  Future<void> initialize() async {
    await _loadBuilds();
  }

  // Load builds from storage
  Future<void> _loadBuilds() async {
    try {
      final raw = getLocalStorageItem('toramBuilds');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _builds = decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Error loading builds: $e');
      _builds = [];
    }
  }

  // Save build
  Future<Map<String, dynamic>> saveBuild({
    required String name,
    required Map<String, dynamic> buildData,
  }) async {
    try {
      // Validate build name
      if (name.trim().isEmpty) {
        return {
          'success': false,
          'message': 'กรุณาใส่ชื่อบิลด์',
        };
      }

      // Check if name already exists
      final existingIndex = _builds.indexWhere((b) => b['name'] == name);

      final buildToSave = {
        'name': name,
        'data': buildData,
        'createdAt': existingIndex >= 0
            ? _builds[existingIndex]['createdAt']
            : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'id': existingIndex >= 0
            ? _builds[existingIndex]['id']
            : 'build_${DateTime.now().millisecondsSinceEpoch}',
      };

      if (existingIndex >= 0) {
        // Update existing build
        _builds[existingIndex] = buildToSave;
      } else {
        // Add new build
        _builds.add(buildToSave);
      }

      // Save to storage
      await _saveToStorage();

      return {
        'success': true,
        'message':
            existingIndex >= 0 ? 'อัปเดตบิลด์สำเร็จ!' : 'บันทึกบิลด์สำเร็จ!',
        'build': buildToSave,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Load build by name
  Map<String, dynamic>? loadBuild(String name) {
    try {
      return _builds.firstWhere((b) => b['name'] == name);
    } catch (e) {
      return null;
    }
  }

  // Load build by ID
  Map<String, dynamic>? loadBuildById(String id) {
    try {
      return _builds.firstWhere((b) => b['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Delete build
  Future<Map<String, dynamic>> deleteBuild(String name) async {
    try {
      final index = _builds.indexWhere((b) => b['name'] == name);
      if (index < 0) {
        return {
          'success': false,
          'message': 'ไม่พบบิลด์ที่ต้องการลบ',
        };
      }

      _builds.removeAt(index);
      await _saveToStorage();

      return {
        'success': true,
        'message': 'ลบบิลด์สำเร็จ!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Delete build by ID
  Future<Map<String, dynamic>> deleteBuildById(String id) async {
    try {
      final index = _builds.indexWhere((b) => b['id'] == id);
      if (index < 0) {
        return {
          'success': false,
          'message': 'ไม่พบบิลด์ที่ต้องการลบ',
        };
      }

      _builds.removeAt(index);
      await _saveToStorage();

      return {
        'success': true,
        'message': 'ลบบิลด์สำเร็จ!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Get build count
  int get buildCount => _builds.length;

  // Check if build name exists
  bool buildExists(String name) {
    return _builds.any((b) => b['name'] == name);
  }

  // Get recent builds (limit 5)
  List<Map<String, dynamic>> getRecentBuilds({int limit = 5}) {
    final sorted = List<Map<String, dynamic>>.from(_builds);
    sorted.sort((a, b) {
      final aTime = DateTime.parse(a['updatedAt'] ?? a['createdAt']);
      final bTime = DateTime.parse(b['updatedAt'] ?? b['createdAt']);
      return bTime.compareTo(aTime);
    });
    return sorted.take(limit).toList();
  }

  // Export build as JSON string
  String exportBuild(String name) {
    final build = loadBuild(name);
    if (build == null) return '';
    return jsonEncode(build);
  }

  // Import build from JSON string
  Future<Map<String, dynamic>> importBuild(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      if (data is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'รูปแบบข้อมูลไม่ถูกต้อง',
        };
      }

      final name = data['name'] ??
          'Imported Build ${DateTime.now().millisecondsSinceEpoch}';
      final buildData = data['data'] ?? data;

      return await saveBuild(name: name, buildData: buildData);
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Clear all builds (use with caution)
  Future<void> clearAllBuilds() async {
    _builds.clear();
    await _saveToStorage();
  }

  // Save to storage
  Future<void> _saveToStorage() async {
    try {
      final encoded = jsonEncode(_builds);
      setLocalStorageItem('toramBuilds', encoded);
    } catch (e) {
      print('Error saving builds: $e');
    }
  }

  // Duplicate build
  Future<Map<String, dynamic>> duplicateBuild(String name) async {
    try {
      final original = loadBuild(name);
      if (original == null) {
        return {
          'success': false,
          'message': 'ไม่พบบิลด์ต้นฉบับ',
        };
      }

      // Create new name
      String newName = '$name (Copy)';
      int counter = 1;
      while (buildExists(newName)) {
        counter++;
        newName = '$name (Copy $counter)';
      }

      return await saveBuild(
        name: newName,
        buildData: Map<String, dynamic>.from(original['data']),
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }

  // Rename build
  Future<Map<String, dynamic>> renameBuild(
      String oldName, String newName) async {
    try {
      if (newName.trim().isEmpty) {
        return {
          'success': false,
          'message': 'กรุณาใส่ชื่อบิลด์ใหม่',
        };
      }

      if (oldName == newName) {
        return {
          'success': true,
          'message': 'ชื่อเดิมและชื่อใหม่เหมือนกัน',
        };
      }

      if (buildExists(newName)) {
        return {
          'success': false,
          'message': 'มีบิลด์ชื่อนี้อยู่แล้ว',
        };
      }

      final index = _builds.indexWhere((b) => b['name'] == oldName);
      if (index < 0) {
        return {
          'success': false,
          'message': 'ไม่พบบิลด์ที่ต้องการเปลี่ยนชื่อ',
        };
      }

      _builds[index]['name'] = newName;
      _builds[index]['updatedAt'] = DateTime.now().toIso8601String();
      await _saveToStorage();

      return {
        'success': true,
        'message': 'เปลี่ยนชื่อบิลด์สำเร็จ!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: $e',
      };
    }
  }
}

/// 文件存储和加载服务
/// 使用shared_preferences存储数据

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  static const String _key = 'property_management_data';

  /// 保存系统数据
  Future<bool> save(PropertyManagementSystem system) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(system.toJson());
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      throw Exception('保存数据失败: $e');
    }
  }

  /// 加载系统数据
  Future<PropertyManagementSystem> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        return PropertyManagementSystem();
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PropertyManagementSystem.fromJson(json);
    } catch (e) {
      throw Exception('加载数据失败: $e');
    }
  }
}


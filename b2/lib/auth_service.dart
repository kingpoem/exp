/// 用户认证服务

import 'models.dart';

class AuthService {
  User? _currentUser;
  PropertyManagementSystem? _system;

  /// 设置系统数据
  void setSystem(PropertyManagementSystem system) {
    _system = system;
  }

  /// 登录
  bool login(String username, String password) {
    if (_system == null) return false;
    
    try {
      final user = _system!.users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 登出
  void logout() {
    _currentUser = null;
  }

  /// 获取当前用户
  User? getCurrentUser() => _currentUser;

  /// 是否为管理员
  bool isAdmin() => _currentUser?.role == '超级管理员';

  /// 是否为普通用户
  bool isNormalUser() => _currentUser?.role == '普通用户';

  /// 是否已登录
  bool isLoggedIn() => _currentUser != null;
}


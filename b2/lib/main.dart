/// 小区物业管理系统 - Flutter版本
/// 支持Web端和Android应用

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'storage_service.dart';
import 'models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小区物业管理系统',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 初始化存储服务
      final storage = StorageService();
      final system = await storage.load();
      
      // 初始化默认数据
      if (system.users.isEmpty) {
        system.users.add(User(
          username: 'admin',
          password: 'admin123',
          role: '超级管理员',
        ));
        system.users.add(User(
          username: 'user1',
          password: 'user123',
          role: '普通用户',
          residentId: 'R001',
        ));
        
        if (system.community == null) {
          system.community = Community(name: '阳光小区', buildingCount: 10);
        }
        
        if (system.roomTypes.isEmpty) {
          system.roomTypes.addAll([
            RoomType(roomTypeId: 'RT001', roomType: '一室一厅', area: 60.0),
            RoomType(roomTypeId: 'RT002', roomType: '两室一厅', area: 90.0),
            RoomType(roomTypeId: 'RT003', roomType: '三室两厅', area: 120.0),
          ]);
        }
        
        if (system.residents.isEmpty) {
          system.residents.addAll([
            Resident(
              residentId: 'R001',
              name: '张三',
              phone: '13800138001',
              address: '1号楼101',
              prepaidAmount: 5000.0,
              arrears: 500.0,
              roomTypeId: 'RT001',
            ),
            Resident(
              residentId: 'R002',
              name: '李四',
              phone: '13800138002',
              address: '2号楼201',
              prepaidAmount: 3000.0,
              arrears: 1200.0,
              roomTypeId: 'RT002',
            ),
            Resident(
              residentId: 'R003',
              name: '王五',
              phone: '13800138003',
              address: '3号楼301',
              prepaidAmount: 8000.0,
              arrears: 0.0,
              roomTypeId: 'RT003',
            ),
          ]);
        }
        
        if (system.parkingSpaces.isEmpty) {
          system.parkingSpaces.addAll([
            ParkingSpace(spaceId: 'P001', residentId: 'R001', location: '地下停车场A区001'),
            ParkingSpace(spaceId: 'P002', residentId: 'R002', location: '地下停车场B区002'),
          ]);
        }
        
        await storage.save(system);
      }
      
      // 延迟一下显示启动画面
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化失败: $e')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                '小区物业管理系统',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

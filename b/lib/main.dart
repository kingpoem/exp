/// 小区物业管理系统 - Flutter版本

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
      
      bool needSave = false;
      
      // 初始化用户（如果为空）
      if (system.users.isEmpty) {
        needSave = true;
        // 初始化用户
        system.users.addAll([
          User(
            username: 'admin',
            password: 'admin123',
            role: '超级管理员',
          ),
          User(
            username: 'user1',
            password: 'user123',
            role: '普通用户',
            residentId: 'R001',
          ),
          User(
            username: 'user2',
            password: 'user123',
            role: '普通用户',
            residentId: 'R002',
          ),
          User(
            username: 'user3',
            password: 'user123',
            role: '普通用户',
            residentId: 'R003',
          ),
          User(
            username: 'user4',
            password: 'user123',
            role: '普通用户',
            residentId: 'R004',
          ),
          User(
            username: 'user5',
            password: 'user123',
            role: '普通用户',
            residentId: 'R005',
          ),
        ]);
      }
      
      // 初始化小区资料（如果为空）
      if (system.community == null) {
        system.community = Community(name: '阳光小区', buildingCount: 15);
        needSave = true;
      }
      
      // 初始化房型资料（如果为空）
      if (system.roomTypes.isEmpty) {
        needSave = true;
        system.roomTypes.addAll([
          RoomType(roomTypeId: 'RT001', roomType: '一室一厅', area: 60.0),
          RoomType(roomTypeId: 'RT002', roomType: '两室一厅', area: 90.0),
          RoomType(roomTypeId: 'RT003', roomType: '三室两厅', area: 120.0),
          RoomType(roomTypeId: 'RT004', roomType: '四室两厅', area: 150.0),
          RoomType(roomTypeId: 'RT005', roomType: '一室一厅（精装）', area: 65.0),
          RoomType(roomTypeId: 'RT006', roomType: '两室两厅', area: 95.0),
          RoomType(roomTypeId: 'RT007', roomType: '三室一厅', area: 110.0),
        ]);
      }
      
      // 初始化住户资料（如果为空）
      if (system.residents.isEmpty) {
        needSave = true;
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
          Resident(
            residentId: 'R004',
            name: '赵六',
            phone: '13800138004',
            address: '1号楼102',
            prepaidAmount: 6000.0,
            arrears: 300.0,
            roomTypeId: 'RT001',
          ),
          Resident(
            residentId: 'R005',
            name: '钱七',
            phone: '13800138005',
            address: '2号楼202',
            prepaidAmount: 4500.0,
            arrears: 800.0,
            roomTypeId: 'RT002',
          ),
          Resident(
            residentId: 'R006',
            name: '孙八',
            phone: '13800138006',
            address: '3号楼302',
            prepaidAmount: 10000.0,
            arrears: 0.0,
            roomTypeId: 'RT003',
          ),
          Resident(
            residentId: 'R007',
            name: '周九',
            phone: '13800138007',
            address: '4号楼401',
            prepaidAmount: 5500.0,
            arrears: 200.0,
            roomTypeId: 'RT004',
          ),
          Resident(
            residentId: 'R008',
            name: '吴十',
            phone: '13800138008',
            address: '1号楼201',
            prepaidAmount: 4000.0,
            arrears: 1500.0,
            roomTypeId: 'RT005',
          ),
          Resident(
            residentId: 'R009',
            name: '郑十一',
            phone: '13800138009',
            address: '2号楼301',
            prepaidAmount: 7000.0,
            arrears: 0.0,
            roomTypeId: 'RT006',
          ),
          Resident(
            residentId: 'R010',
            name: '王十二',
            phone: '13800138010',
            address: '3号楼401',
            prepaidAmount: 3500.0,
            arrears: 900.0,
            roomTypeId: 'RT007',
          ),
          Resident(
            residentId: 'R011',
            name: '李十三',
            phone: '13800138011',
            address: '5号楼101',
            prepaidAmount: 6500.0,
            arrears: 400.0,
            roomTypeId: 'RT001',
          ),
          Resident(
            residentId: 'R012',
            name: '张十四',
            phone: '13800138012',
            address: '4号楼501',
            prepaidAmount: 9000.0,
            arrears: 0.0,
            roomTypeId: 'RT003',
          ),
          Resident(
            residentId: 'R013',
            name: '刘十五',
            phone: '13800138013',
            address: '6号楼201',
            prepaidAmount: 5000.0,
            arrears: 600.0,
            roomTypeId: 'RT002',
          ),
          Resident(
            residentId: 'R014',
            name: '陈十六',
            phone: '13800138014',
            address: '5号楼301',
            prepaidAmount: 7500.0,
            arrears: 0.0,
            roomTypeId: 'RT004',
          ),
          Resident(
            residentId: 'R015',
            name: '杨十七',
            phone: '13800138015',
            address: '7号楼101',
            prepaidAmount: 4200.0,
            arrears: 1100.0,
            roomTypeId: 'RT005',
          ),
          Resident(
            residentId: 'R016',
            name: '黄十八',
            phone: '13800138016',
            address: '6号楼401',
            prepaidAmount: 5800.0,
            arrears: 250.0,
            roomTypeId: 'RT006',
          ),
          Resident(
            residentId: 'R017',
            name: '周十九',
            phone: '13800138017',
            address: '8号楼201',
            prepaidAmount: 6800.0,
            arrears: 0.0,
            roomTypeId: 'RT007',
          ),
          Resident(
            residentId: 'R018',
            name: '吴二十',
            phone: '13800138018',
            address: '7号楼301',
            prepaidAmount: 4800.0,
            arrears: 700.0,
            roomTypeId: 'RT001',
          ),
          Resident(
            residentId: 'R019',
            name: '徐二一',
            phone: '13800138019',
            address: '9号楼101',
            prepaidAmount: 8500.0,
            arrears: 0.0,
            roomTypeId: 'RT003',
          ),
          Resident(
            residentId: 'R020',
            name: '孙二二',
            phone: '13800138020',
            address: '8号楼401',
            prepaidAmount: 5200.0,
            arrears: 350.0,
            roomTypeId: 'RT002',
          ),
          Resident(
            residentId: 'R021',
            name: '马二三',
            phone: '13800138021',
            address: '10号楼201',
            prepaidAmount: 7200.0,
            arrears: 0.0,
            roomTypeId: 'RT004',
          ),
          Resident(
            residentId: 'R022',
            name: '朱二四',
            phone: '13800138022',
            address: '9号楼501',
            prepaidAmount: 4600.0,
            arrears: 950.0,
            roomTypeId: 'RT005',
          ),
          Resident(
            residentId: 'R023',
            name: '胡二五',
            phone: '13800138023',
            address: '11号楼101',
            prepaidAmount: 6400.0,
            arrears: 180.0,
            roomTypeId: 'RT006',
          ),
          Resident(
            residentId: 'R024',
            name: '林二六',
            phone: '13800138024',
            address: '10号楼301',
            prepaidAmount: 7800.0,
            arrears: 0.0,
            roomTypeId: 'RT007',
          ),
          Resident(
            residentId: 'R025',
            name: '郭二七',
            phone: '13800138025',
            address: '12号楼201',
            prepaidAmount: 5400.0,
            arrears: 450.0,
            roomTypeId: 'RT001',
          ),
        ]);
      }
      
      // 初始化停车位（如果为空）
      if (system.parkingSpaces.isEmpty) {
        needSave = true;
        system.parkingSpaces.addAll([
          ParkingSpace(spaceId: 'P001', residentId: 'R001', location: '地下停车场A区001'),
          ParkingSpace(spaceId: 'P002', residentId: 'R002', location: '地下停车场B区002'),
          ParkingSpace(spaceId: 'P003', residentId: 'R003', location: '地下停车场A区003'),
          ParkingSpace(spaceId: 'P004', residentId: 'R004', location: '地下停车场C区004'),
          ParkingSpace(spaceId: 'P005', residentId: 'R005', location: '地下停车场B区005'),
          ParkingSpace(spaceId: 'P006', residentId: 'R006', location: '地下停车场A区006'),
          ParkingSpace(spaceId: 'P007', residentId: 'R007', location: '地下停车场D区007'),
          ParkingSpace(spaceId: 'P008', residentId: 'R008', location: '地下停车场C区008'),
          ParkingSpace(spaceId: 'P009', residentId: 'R009', location: '地下停车场B区009'),
          ParkingSpace(spaceId: 'P010', residentId: 'R010', location: '地下停车场A区010'),
          ParkingSpace(spaceId: 'P011', residentId: 'R011', location: '地下停车场E区011'),
          ParkingSpace(spaceId: 'P012', residentId: 'R012', location: '地下停车场A区012'),
          ParkingSpace(spaceId: 'P013', residentId: 'R013', location: '地下停车场B区013'),
          ParkingSpace(spaceId: 'P014', residentId: 'R014', location: '地下停车场D区014'),
          ParkingSpace(spaceId: 'P015', residentId: 'R015', location: '地下停车场C区015'),
          ParkingSpace(spaceId: 'P016', residentId: 'R016', location: '地下停车场B区016'),
          ParkingSpace(spaceId: 'P017', residentId: 'R017', location: '地下停车场E区017'),
          ParkingSpace(spaceId: 'P018', residentId: 'R018', location: '地下停车场A区018'),
          ParkingSpace(spaceId: 'P019', residentId: 'R019', location: '地下停车场A区019'),
          ParkingSpace(spaceId: 'P020', residentId: 'R020', location: '地下停车场B区020'),
          ParkingSpace(spaceId: 'P021', residentId: 'R021', location: '地下停车场D区021'),
          ParkingSpace(spaceId: 'P022', residentId: 'R022', location: '地下停车场C区022'),
          ParkingSpace(spaceId: 'P023', residentId: 'R023', location: '地下停车场E区023'),
          ParkingSpace(spaceId: 'P024', residentId: 'R024', location: '地下停车场B区024'),
          ParkingSpace(spaceId: 'P025', residentId: 'R025', location: '地下停车场A区025'),
        ]);
      }
      
      // 初始化报修记录（如果为空）
      if (system.repairs.isEmpty) {
        needSave = true;
        final now = DateTime.now();
        system.repairs.addAll([
          Repair(
            repairId: 'REP001',
            residentId: 'R001',
            description: '客厅灯不亮，需要更换灯泡',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 5)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP002',
            residentId: 'R002',
            description: '卫生间水龙头漏水',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 3)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP003',
            residentId: 'R003',
            description: '门锁损坏，无法正常开关',
            status: '已完成',
            createTime: now.subtract(const Duration(days: 10)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP004',
            residentId: 'R004',
            description: '空调制冷效果差',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 2)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP005',
            residentId: 'R005',
            description: '厨房下水道堵塞',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 1)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP006',
            residentId: 'R006',
            description: '窗户玻璃破裂',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 4)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP007',
            residentId: 'R007',
            description: '电路跳闸，需要检查电路',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 6)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP008',
            residentId: 'R008',
            description: '热水器无法加热',
            status: '已完成',
            createTime: now.subtract(const Duration(days: 8)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP009',
            residentId: 'R009',
            description: '墙面有裂缝需要修补',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 7)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP010',
            residentId: 'R010',
            description: '阳台门锁故障',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 2)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP011',
            residentId: 'R011',
            description: '抽油烟机噪音大',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 3)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP012',
            residentId: 'R012',
            description: '地板有部分松动',
            status: '已完成',
            createTime: now.subtract(const Duration(days: 12)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP013',
            residentId: 'R013',
            description: '洗衣机无法排水',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 1)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP014',
            residentId: 'R014',
            description: '电梯按键不灵敏',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 5)).toString().substring(0, 19),
          ),
          Repair(
            repairId: 'REP015',
            residentId: 'R015',
            description: '燃气灶打不着火',
            status: '已完成',
            createTime: now.subtract(const Duration(days: 9)).toString().substring(0, 19),
          ),
        ]);
      }
      
      // 初始化投诉记录（如果为空）
      if (system.complaints.isEmpty) {
        needSave = true;
        final now = DateTime.now();
        system.complaints.addAll([
          Complaint(
            complaintId: 'COM001',
            residentId: 'R001',
            content: '楼下装修噪音太大，影响休息',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 4)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM002',
            residentId: 'R002',
            content: '楼道卫生清洁不及时',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 2)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM003',
            residentId: 'R003',
            content: '电梯经常故障，影响出行',
            status: '已解决',
            createTime: now.subtract(const Duration(days: 10)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM004',
            residentId: 'R004',
            content: '停车场照明不足，存在安全隐患',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 3)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM005',
            residentId: 'R005',
            content: '邻居在公共区域堆放杂物',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 1)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM006',
            residentId: 'R006',
            content: '小区绿化维护不到位',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 5)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM007',
            residentId: 'R007',
            content: '门禁系统经常失灵',
            status: '已解决',
            createTime: now.subtract(const Duration(days: 8)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM008',
            residentId: 'R008',
            content: '垃圾清运不及时，气味难闻',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 2)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM009',
            residentId: 'R009',
            content: '小区内车辆乱停乱放',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 6)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM010',
            residentId: 'R010',
            content: '公共区域有宠物粪便未清理',
            status: '已解决',
            createTime: now.subtract(const Duration(days: 7)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM011',
            residentId: 'R011',
            content: '夜间施工噪音扰民',
            status: '处理中',
            createTime: now.subtract(const Duration(days: 1)).toString().substring(0, 19),
          ),
          Complaint(
            complaintId: 'COM012',
            residentId: 'R012',
            content: '小区监控摄像头损坏',
            status: '待处理',
            createTime: now.subtract(const Duration(days: 4)).toString().substring(0, 19),
          ),
        ]);
      }
      
      // 初始化收费项目（如果为空）
      if (system.fees.isEmpty) {
        needSave = true;
        system.fees.addAll([
          Fee(
            feeId: 'F001',
            name: '物业管理费',
            amount: 2.5,
            unit: '元/㎡',
            cycle: '月',
          ),
          Fee(
            feeId: 'F002',
            name: '停车管理费',
            amount: 150.0,
            unit: '元',
            cycle: '月',
          ),
          Fee(
            feeId: 'F003',
            name: '垃圾清运费',
            amount: 20.0,
            unit: '元',
            cycle: '月',
          ),
          Fee(
            feeId: 'F004',
            name: '公共区域维护费',
            amount: 50.0,
            unit: '元',
            cycle: '月',
          ),
          Fee(
            feeId: 'F005',
            name: '电梯维护费',
            amount: 30.0,
            unit: '元',
            cycle: '月',
          ),
          Fee(
            feeId: 'F006',
            name: '绿化维护费',
            amount: 25.0,
            unit: '元',
            cycle: '月',
          ),
          Fee(
            feeId: 'F007',
            name: '安保服务费',
            amount: 40.0,
            unit: '元',
            cycle: '月',
          ),
          Fee(
            feeId: 'F008',
            name: '公共设施维修基金',
            amount: 100.0,
            unit: '元',
            cycle: '年',
          ),
        ]);
      }
      
      // 如果有新数据，保存系统
      if (needSave) {
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

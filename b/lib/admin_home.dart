/// 管理员主页
/// 包含所有管理员功能模块

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'models.dart';
import 'login_page.dart';

class AdminHomePage extends StatefulWidget {
  final AuthService authService;

  const AdminHomePage({super.key, required this.authService});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PropertyManagementSystem? _system;
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  
  // 住户管理筛选状态
  String _residentFilter = 'all'; // 'all', 'arrears', 'sorted'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final system = await _storage.load();
      setState(() {
        _system = system;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (_system == null) return;
    try {
      await _storage.save(_system!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.authService.logout();
              Navigator.pop(context); // 关闭确认对话框
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false, // 清除所有路由
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_system == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('管理员主页')),
        body: const Center(child: Text('数据加载失败')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理员主页'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '小区资料', icon: Icon(Icons.apartment)),
            Tab(text: '房型管理', icon: Icon(Icons.home)),
            Tab(text: '住户管理', icon: Icon(Icons.people)),
            Tab(text: '报修管理', icon: Icon(Icons.build)),
            Tab(text: '投诉管理', icon: Icon(Icons.report)),
            Tab(text: '停车位', icon: Icon(Icons.local_parking)),
            Tab(text: '收费管理', icon: Icon(Icons.payment)),
            Tab(text: '统计查询', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
            tooltip: '保存数据',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '退出登录',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunityTab(),
          _buildRoomTypeTab(),
          _buildResidentTab(),
          _buildRepairTab(),
          _buildComplaintTab(),
          _buildParkingTab(),
          _buildFeeTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('小区信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_system!.community != null) ...[
                    _buildInfoRow('小区名称', _system!.community!.name),
                    _buildInfoRow('楼宇总数', '${_system!.community!.buildingCount}'),
                  ] else
                    const Text('暂无小区资料'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('编辑小区资料', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '小区名称',
                      hintText: _system!.community?.name ?? '请输入小区名称',
                    ),
                    controller: TextEditingController(text: _system!.community?.name ?? ''),
                    onChanged: (value) {
                      setState(() {
                        _system!.community = Community(name: value, buildingCount: _system!.community?.buildingCount ?? 10);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '楼宇总数',
                      hintText: '${_system!.community?.buildingCount ?? 10}',
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: '${_system!.community?.buildingCount ?? 10}'),
                    onChanged: (value) {
                      final count = int.tryParse(value) ?? 10;
                      setState(() {
                        _system!.community = Community(name: _system!.community?.name ?? '阳光小区', buildingCount: count);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTypeTab() {
    final roomTypeCount = _system!.roomTypes.toSet().length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('房型种类数: $roomTypeCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('房型列表', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddRoomTypeDialog(),
                  ),
                ),
                const Divider(),
                ..._system!.roomTypes.map((rt) => ListTile(
                      title: Text(rt.roomType),
                      subtitle: Text('${rt.roomTypeId} - ${rt.area}㎡'),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentTab() {
    // 根据筛选状态获取住户列表
    List<Resident> displayResidents;
    switch (_residentFilter) {
      case 'arrears':
        displayResidents = _system!.residents.where((r) => r.arrears > 0).toList();
        break;
      case 'sorted':
        displayResidents = List.from(_system!.residents)
          ..sort((a, b) => b.arrears.compareTo(a.arrears));
        break;
      default:
        displayResidents = _system!.residents;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _residentFilter = 'all';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _residentFilter == 'all' ? Colors.blue : null,
                  foregroundColor: _residentFilter == 'all' ? Colors.white : null,
                ),
                child: const Text('全部住户'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _residentFilter = 'arrears';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _residentFilter == 'arrears' ? Colors.blue : null,
                  foregroundColor: _residentFilter == 'arrears' ? Colors.white : null,
                ),
                child: const Text('欠费住户'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _residentFilter = 'sorted';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _residentFilter == 'sorted' ? Colors.blue : null,
                  foregroundColor: _residentFilter == 'sorted' ? Colors.white : null,
                ),
                child: const Text('按欠费排序'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('住户列表', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddResidentDialog(),
                  ),
                ),
                const Divider(),
                if (displayResidents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('暂无住户记录'),
                  )
                else
                  ...displayResidents.map((r) => ListTile(
                        title: Text(r.name),
                        subtitle: Text('${r.residentId} - ${r.phone} - ${r.address}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '欠费: ${r.arrears.toStringAsFixed(2)}元',
                              style: TextStyle(
                                color: r.arrears > 0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '预付: ${r.prepaidAmount.toStringAsFixed(2)}元',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            const ListTile(
              title: Text('报修报表', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ..._system!.repairs.map((r) {
              final resident = _system!.residents.firstWhere((res) => res.residentId == r.residentId, orElse: () => Resident(residentId: '', name: '未知', phone: '', address: '', prepaidAmount: 0, arrears: 0, roomTypeId: ''));
              return ListTile(
                title: Text(resident.name),
                subtitle: Text(r.description),
                trailing: Chip(label: Text(r.status)),
              );
            }),
            if (_system!.repairs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无报修记录'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            const ListTile(
              title: Text('投诉报表', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ..._system!.complaints.map((c) {
              final resident = _system!.residents.firstWhere((res) => res.residentId == c.residentId, orElse: () => Resident(residentId: '', name: '未知', phone: '', address: '', prepaidAmount: 0, arrears: 0, roomTypeId: ''));
              return ListTile(
                title: Text(resident.name),
                subtitle: Text(c.content),
                trailing: Chip(label: Text(c.status)),
              );
            }),
            if (_system!.complaints.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无投诉记录'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('停车位列表', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddParkingDialog(),
                  ),
                ),
                const Divider(),
                ..._system!.parkingSpaces.map((ps) {
                  final resident = _system!.residents.firstWhere((res) => res.residentId == ps.residentId, orElse: () => Resident(residentId: '', name: '未知', phone: '', address: '', prepaidAmount: 0, arrears: 0, roomTypeId: ''));
                  return ListTile(
                    title: Text('${ps.spaceId} - ${resident.name}'),
                    subtitle: Text(ps.location),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('收费项目列表', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddFeeDialog(),
              ),
            ),
            const Divider(),
            ..._system!.fees.map((f) => ListTile(
                  title: Text(f.name),
                  subtitle: Text('${f.amount.toStringAsFixed(2)}元/${f.unit} - ${f.cycle}'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    final arrearsCount = _system!.residents.where((r) => r.arrears > 0).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard('房型种类数', '${_system!.roomTypes.toSet().length}'),
          _buildStatCard('欠费住户数', '$arrearsCount'),
          _buildStatCard('总住户数', '${_system!.residents.length}'),
          _buildStatCard('总报修数', '${_system!.repairs.length}'),
          _buildStatCard('总投诉数', '${_system!.complaints.length}'),
          _buildStatCard('总停车位数', '${_system!.parkingSpaces.length}'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _showAddRoomTypeDialog() {
    final roomTypeIdController = TextEditingController();
    final roomTypeController = TextEditingController();
    final areaController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加房型'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomTypeIdController,
                decoration: const InputDecoration(
                  labelText: '房型编号',
                  hintText: '例如: RT001',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomTypeController,
                decoration: const InputDecoration(
                  labelText: '房型',
                  hintText: '例如: 一室一厅',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: '建筑面积(㎡)',
                  hintText: '例如: 60.0',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final roomTypeId = roomTypeIdController.text.trim();
              final roomType = roomTypeController.text.trim();
              final areaStr = areaController.text.trim();
              
              if (roomTypeId.isEmpty || roomType.isEmpty || areaStr.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }
              
              final area = double.tryParse(areaStr);
              if (area == null || area <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('建筑面积必须是大于0的数字')),
                );
                return;
              }
              
              // 检查房型编号是否已存在
              if (_system!.roomTypes.any((rt) => rt.roomTypeId == roomTypeId)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('房型编号已存在')),
                );
                return;
              }
              
              setState(() {
                _system!.roomTypes.add(RoomType(
                  roomTypeId: roomTypeId,
                  roomType: roomType,
                  area: area,
                ));
              });
              
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('房型已添加')),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddResidentDialog() {
    final residentIdController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final prepaidController = TextEditingController(text: '0');
    final arrearsController = TextEditingController(text: '0');
    final roomTypeIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加住户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: residentIdController,
                decoration: const InputDecoration(
                  labelText: '住户编号',
                  hintText: '例如: R001',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  hintText: '请输入住户姓名',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: '联系电话',
                  hintText: '例如: 13800138001',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: '联系地址',
                  hintText: '例如: 1号楼101',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prepaidController,
                decoration: const InputDecoration(
                  labelText: '预付金额',
                  hintText: '例如: 5000.0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: arrearsController,
                decoration: const InputDecoration(
                  labelText: '欠费金额',
                  hintText: '例如: 500.0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roomTypeIdController,
                decoration: const InputDecoration(
                  labelText: '房型编号',
                  hintText: '例如: RT001',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final residentId = residentIdController.text.trim();
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final address = addressController.text.trim();
              final prepaidStr = prepaidController.text.trim();
              final arrearsStr = arrearsController.text.trim();
              final roomTypeId = roomTypeIdController.text.trim();
              
              if (residentId.isEmpty || name.isEmpty || phone.isEmpty || address.isEmpty || roomTypeId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }
              
              final prepaid = double.tryParse(prepaidStr) ?? 0.0;
              final arrears = double.tryParse(arrearsStr) ?? 0.0;
              
              // 检查住户编号是否已存在
              if (_system!.residents.any((r) => r.residentId == residentId)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('住户编号已存在')),
                );
                return;
              }
              
              setState(() {
                _system!.residents.add(Resident(
                  residentId: residentId,
                  name: name,
                  phone: phone,
                  address: address,
                  prepaidAmount: prepaid,
                  arrears: arrears,
                  roomTypeId: roomTypeId,
                ));
              });
              
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('住户已添加')),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddParkingDialog() {
    final spaceIdController = TextEditingController();
    final residentIdController = TextEditingController();
    final locationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加停车位'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: spaceIdController,
                decoration: const InputDecoration(
                  labelText: '车位编号',
                  hintText: '例如: P001',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: residentIdController,
                decoration: const InputDecoration(
                  labelText: '住户编号',
                  hintText: '例如: R001',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: '车位位置',
                  hintText: '例如: 地下停车场A区001',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final spaceId = spaceIdController.text.trim();
              final residentId = residentIdController.text.trim();
              final location = locationController.text.trim();
              
              if (spaceId.isEmpty || residentId.isEmpty || location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }
              
              // 检查车位编号是否已存在
              if (_system!.parkingSpaces.any((ps) => ps.spaceId == spaceId)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('车位编号已存在')),
                );
                return;
              }
              
              // 检查住户是否存在
              if (!_system!.residents.any((r) => r.residentId == residentId)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('住户编号不存在')),
                );
                return;
              }
              
              setState(() {
                _system!.parkingSpaces.add(ParkingSpace(
                  spaceId: spaceId,
                  residentId: residentId,
                  location: location,
                ));
              });
              
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('停车位已添加')),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddFeeDialog() {
    final feeIdController = TextEditingController();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final unitController = TextEditingController();
    final cycleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加收费项目'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feeIdController,
                decoration: const InputDecoration(
                  labelText: '收费编号',
                  hintText: '例如: F001',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '收费名称',
                  hintText: '例如: 物业管理费',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: '收费金额',
                  hintText: '例如: 100.0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: '收费单位',
                  hintText: '例如: 元',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cycleController,
                decoration: const InputDecoration(
                  labelText: '收费周期',
                  hintText: '例如: 月',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final feeId = feeIdController.text.trim();
              final name = nameController.text.trim();
              final amountStr = amountController.text.trim();
              final unit = unitController.text.trim();
              final cycle = cycleController.text.trim();
              
              if (feeId.isEmpty || name.isEmpty || amountStr.isEmpty || unit.isEmpty || cycle.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }
              
              final amount = double.tryParse(amountStr);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('收费金额必须是大于0的数字')),
                );
                return;
              }
              
              // 检查收费编号是否已存在
              if (_system!.fees.any((f) => f.feeId == feeId)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('收费编号已存在')),
                );
                return;
              }
              
              setState(() {
                _system!.fees.add(Fee(
                  feeId: feeId,
                  name: name,
                  amount: amount,
                  unit: unit,
                  cycle: cycle,
                ));
              });
              
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('收费项目已添加')),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

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
  
  // 车位管理搜索状态
  final TextEditingController _parkingSearchController = TextEditingController();
  String _parkingSearchType = 'spaceId'; // 'spaceId', 'residentId', 'residentName', 'location'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _parkingSearchController.dispose();
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
            Tab(text: '用户管理', icon: Icon(Icons.person_add)),
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
          _buildUserTab(),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditRoomTypeDialog(rt),
                            tooltip: '编辑',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteRoomTypeDialog(rt),
                            tooltip: '删除',
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

  Widget _buildResidentTab() {
    // 根据筛选状态获取住户列表
    List<Resident> displayResidents;
    switch (_residentFilter) {
      case 'arrears':
        displayResidents = _system!.residents.where((r) => r.arrears > 0).toList();
        break;
      case 'sorted':
        // 按欠费排序，排除欠费为0元的住户
        displayResidents = _system!.residents
            .where((r) => r.arrears > 0)
            .toList()
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
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
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditResidentDialog(r),
                              tooltip: '编辑',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteResidentDialog(r),
                              tooltip: '删除',
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(r.status)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditRepairDialog(r),
                      tooltip: '编辑',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteRepairDialog(r),
                      tooltip: '删除',
                    ),
                  ],
                ),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(c.status)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditComplaintDialog(c),
                      tooltip: '编辑',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteComplaintDialog(c),
                      tooltip: '删除',
                    ),
                  ],
                ),
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
    // 根据搜索条件筛选车位
    List<ParkingSpace> displayParkingSpaces = _system!.parkingSpaces;
    final searchKeyword = _parkingSearchController.text.trim().toLowerCase();
    
    if (searchKeyword.isNotEmpty) {
      displayParkingSpaces = _system!.parkingSpaces.where((ps) {
        final resident = _system!.residents.firstWhere(
          (res) => res.residentId == ps.residentId,
          orElse: () => Resident(
            residentId: '',
            name: '未知',
            phone: '',
            address: '',
            prepaidAmount: 0,
            arrears: 0,
            roomTypeId: '',
          ),
        );
        
        switch (_parkingSearchType) {
          case 'spaceId':
            return ps.spaceId.toLowerCase().contains(searchKeyword);
          case 'residentId':
            return ps.residentId.toLowerCase().contains(searchKeyword);
          case 'residentName':
            return resident.name.toLowerCase().contains(searchKeyword);
          case 'location':
            return ps.location.toLowerCase().contains(searchKeyword);
          default:
            return true;
        }
      }).toList();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索区域
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '搜索车位',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // 搜索类型选择
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _parkingSearchType,
                          decoration: const InputDecoration(
                            labelText: '搜索类型',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'spaceId',
                              child: Text('车位编号'),
                            ),
                            DropdownMenuItem(
                              value: 'residentId',
                              child: Text('住户编号'),
                            ),
                            DropdownMenuItem(
                              value: 'residentName',
                              child: Text('住户姓名'),
                            ),
                            DropdownMenuItem(
                              value: 'location',
                              child: Text('车位位置'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _parkingSearchType = value ?? 'spaceId';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _parkingSearchController,
                          decoration: InputDecoration(
                            labelText: '搜索关键词',
                            hintText: '请输入搜索内容',
                            border: const OutlineInputBorder(),
                            suffixIcon: _parkingSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _parkingSearchController.clear();
                                      });
                                    },
                                  )
                                : const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (searchKeyword.isNotEmpty)
                    Text(
                      '找到 ${displayParkingSpaces.length} 个匹配的车位',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 车位列表
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
                if (displayParkingSpaces.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      searchKeyword.isNotEmpty
                          ? '未找到匹配的车位信息'
                          : '暂无车位记录',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  ...displayParkingSpaces.map((ps) {
                    final resident = _system!.residents.firstWhere(
                      (res) => res.residentId == ps.residentId,
                      orElse: () => Resident(
                        residentId: '',
                        name: '未知',
                        phone: '',
                        address: '',
                        prepaidAmount: 0,
                        arrears: 0,
                        roomTypeId: '',
                      ),
                    );
                    return ListTile(
                      title: Text('${ps.spaceId} - ${resident.name}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('住户编号: ${ps.residentId}'),
                          Text('车位位置: ${ps.location}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditParkingDialog(ps),
                            tooltip: '编辑',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteParkingDialog(ps),
                            tooltip: '删除',
                          ),
                        ],
                      ),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditFeeDialog(f),
                        tooltip: '编辑',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteFeeDialog(f),
                        tooltip: '删除',
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('用户列表', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddUserDialog(),
              ),
            ),
            const Divider(),
            if (_system!.users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无用户记录'),
              )
            else
              ..._system!.users.map((u) => ListTile(
                    title: Text(u.username),
                    subtitle: Text('角色: ${u.role}${u.residentId != null ? ' | 关联住户: ${u.residentId}' : ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 不允许删除当前登录的管理员
                        if (u.username != widget.authService.getCurrentUser()?.username) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditUserDialog(u),
                            tooltip: '编辑',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteUserDialog(u),
                            tooltip: '删除',
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('当前用户', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                      ],
                    ),
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
          _buildStatCard('总用户数', '${_system!.users.length}'),
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

  // ========== 编辑对话框方法 ==========

  void _showEditRoomTypeDialog(RoomType roomType) {
    final roomTypeIdController = TextEditingController(text: roomType.roomTypeId);
    final roomTypeController = TextEditingController(text: roomType.roomType);
    final areaController = TextEditingController(text: roomType.area.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑房型'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomTypeIdController,
                decoration: const InputDecoration(labelText: '房型编号'),
                enabled: false, // 编号不可修改
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomTypeController,
                decoration: const InputDecoration(labelText: '房型'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '建筑面积 (㎡)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final type = roomTypeController.text.trim();
              final area = double.tryParse(areaController.text.trim());
              
              if (type.isEmpty || area == null || area <= 0) {
                _showSnackBar('请填写有效信息');
                return;
              }
              
              final index = _system!.roomTypes.indexWhere((rt) => rt.roomTypeId == roomType.roomTypeId);
              if (index != -1) {
                setState(() {
                  _system!.roomTypes[index] = RoomType(
                    roomTypeId: roomType.roomTypeId,
                    roomType: type,
                    area: area,
                  );
                });
                _saveData();
                Navigator.pop(context);
                _showSnackBar('房型已更新');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditResidentDialog(Resident resident) {
    final nameController = TextEditingController(text: resident.name);
    final phoneController = TextEditingController(text: resident.phone);
    final addressController = TextEditingController(text: resident.address);
    final prepaidController = TextEditingController(text: resident.prepaidAmount.toString());
    final arrearsController = TextEditingController(text: resident.arrears.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑住户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '住户编号', hintText: resident.residentId),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '姓名'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '电话'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '地址'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prepaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '预付金额'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: arrearsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '欠费金额'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final address = addressController.text.trim();
              final prepaid = double.tryParse(prepaidController.text.trim()) ?? 0;
              final arrears = double.tryParse(arrearsController.text.trim()) ?? 0;
              
              if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                _showSnackBar('请填写完整信息');
                return;
              }
              
              final index = _system!.residents.indexWhere((r) => r.residentId == resident.residentId);
              if (index != -1) {
                setState(() {
                  _system!.residents[index] = Resident(
                    residentId: resident.residentId,
                    name: name,
                    phone: phone,
                    address: address,
                    prepaidAmount: prepaid,
                    arrears: arrears,
                    roomTypeId: resident.roomTypeId,
                  );
                });
                _saveData();
                Navigator.pop(context);
                _showSnackBar('住户信息已更新');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditRepairDialog(Repair repair) {
    final descriptionController = TextEditingController(text: repair.description);
    String selectedStatus = repair.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑报修'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '报修描述'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: '状态'),
                items: ['待处理', '处理中', '已完成', '已取消'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value ?? repair.status;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.trim().isEmpty) {
                _showSnackBar('报修描述不能为空');
                return;
              }
              
              final index = _system!.repairs.indexWhere((r) => r.repairId == repair.repairId);
              if (index != -1) {
                setState(() {
                  _system!.repairs[index] = Repair(
                    repairId: repair.repairId,
                    residentId: repair.residentId,
                    description: descriptionController.text.trim(),
                    status: selectedStatus,
                    createTime: repair.createTime,
                  );
                });
                _saveData();
                Navigator.pop(context);
                _showSnackBar('报修记录已更新');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditComplaintDialog(Complaint complaint) {
    final contentController = TextEditingController(text: complaint.content);
    String selectedStatus = complaint.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑投诉'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: '投诉内容'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: '状态'),
                items: ['待处理', '处理中', '已解决', '已取消'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value ?? complaint.status;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.trim().isEmpty) {
                _showSnackBar('投诉内容不能为空');
                return;
              }
              
              final index = _system!.complaints.indexWhere((c) => c.complaintId == complaint.complaintId);
              if (index != -1) {
                setState(() {
                  _system!.complaints[index] = Complaint(
                    complaintId: complaint.complaintId,
                    residentId: complaint.residentId,
                    content: contentController.text.trim(),
                    status: selectedStatus,
                    createTime: complaint.createTime,
                  );
                });
                _saveData();
                Navigator.pop(context);
                _showSnackBar('投诉记录已更新');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditParkingDialog(ParkingSpace parking) {
    final residentIdController = TextEditingController(text: parking.residentId);
    final locationController = TextEditingController(text: parking.location);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑停车位'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '车位编号', hintText: parking.spaceId),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: residentIdController,
                decoration: const InputDecoration(labelText: '住户编号'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: '车位位置'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final residentId = residentIdController.text.trim();
              final location = locationController.text.trim();
              
              if (residentId.isEmpty || location.isEmpty) {
                _showSnackBar('请填写完整信息');
                return;
              }
              
              if (!_system!.residents.any((r) => r.residentId == residentId)) {
                _showSnackBar('住户编号不存在');
                return;
              }
              
              final index = _system!.parkingSpaces.indexWhere((ps) => ps.spaceId == parking.spaceId);
              if (index != -1) {
                setState(() {
                  _system!.parkingSpaces[index] = ParkingSpace(
                    spaceId: parking.spaceId,
                    residentId: residentId,
                    location: location,
                  );
                });
                _saveData();
                Navigator.pop(context);
                _showSnackBar('停车位已更新');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditFeeDialog(Fee fee) {
    final nameController = TextEditingController(text: fee.name);
    final amountController = TextEditingController(text: fee.amount.toString());
    final unitController = TextEditingController(text: fee.unit);
    final cycleController = TextEditingController(text: fee.cycle);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑收费项目'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '收费编号', hintText: fee.feeId),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '收费名称'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '收费金额'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: '收费单位'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cycleController,
                decoration: const InputDecoration(labelText: '收费周期'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amountStr = amountController.text.trim();
              final unit = unitController.text.trim();
              final cycle = cycleController.text.trim();
              
              if (name.isEmpty || amountStr.isEmpty || unit.isEmpty || cycle.isEmpty) {
                _showSnackBar('请填写完整信息');
                return;
              }
              
              final amount = double.tryParse(amountStr);
              if (amount == null || amount <= 0) {
                _showSnackBar('收费金额必须是大于0的数字');
                return;
              }
              
              final index = _system!.fees.indexWhere((f) => f.feeId == fee.feeId);
              if (index != -1) {
                setState(() {
                  _system!.fees[index] = Fee(
                    feeId: fee.feeId,
                    name: name,
                    amount: amount,
                    unit: unit,
                    cycle: cycle,
                  );
                });
                _saveData();
                Navigator.pop(context);
                _showSnackBar('收费项目已更新');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // ========== 删除对话框方法 ==========

  void _showDeleteRoomTypeDialog(RoomType roomType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除房型 "${roomType.roomType}" 吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 检查是否有住户使用此房型
              if (_system!.residents.any((r) => r.roomTypeId == roomType.roomTypeId)) {
                Navigator.pop(context);
                _showSnackBar('该房型正在被使用，无法删除');
                return;
              }
              
              setState(() {
                _system!.roomTypes.removeWhere((rt) => rt.roomTypeId == roomType.roomTypeId);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('房型已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteResidentDialog(Resident resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除住户 "${resident.name}" 吗？\n\n此操作将同时删除相关的报修、投诉和车位记录。\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _system!.residents.removeWhere((r) => r.residentId == resident.residentId);
                _system!.repairs.removeWhere((r) => r.residentId == resident.residentId);
                _system!.complaints.removeWhere((c) => c.residentId == resident.residentId);
                _system!.parkingSpaces.removeWhere((ps) => ps.residentId == resident.residentId);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('住户及相关记录已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRepairDialog(Repair repair) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条报修记录吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _system!.repairs.removeWhere((r) => r.repairId == repair.repairId);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('报修记录已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteComplaintDialog(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条投诉记录吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _system!.complaints.removeWhere((c) => c.complaintId == complaint.complaintId);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('投诉记录已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteParkingDialog(ParkingSpace parking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除停车位 "${parking.spaceId}" 吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _system!.parkingSpaces.removeWhere((ps) => ps.spaceId == parking.spaceId);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('停车位已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFeeDialog(Fee fee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除收费项目 "${fee.name}" 吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _system!.fees.removeWhere((f) => f.feeId == fee.feeId);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('收费项目已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // ========== 用户管理对话框方法 ==========

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedRole = '普通用户';
        String? selectedResidentId;
        
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('添加用户'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      hintText: '请输入用户名',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      hintText: '请输入密码',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: '角色'),
                    items: ['普通用户', '超级管理员'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value ?? '普通用户';
                        if (selectedRole == '超级管理员') {
                          selectedResidentId = null;
                        }
                      });
                    },
                  ),
                  if (selectedRole == '普通用户') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: selectedResidentId,
                      decoration: const InputDecoration(labelText: '关联住户（可选）'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('无')),
                        ..._system!.residents.map((r) {
                          return DropdownMenuItem<String?>(
                            value: r.residentId,
                            child: Text('${r.residentId} - ${r.name}'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedResidentId = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();
                  
                  if (username.isEmpty || password.isEmpty) {
                    _showSnackBar('用户名和密码不能为空');
                    return;
                  }
                  
                  // 检查用户名是否已存在
                  if (_system!.users.any((u) => u.username == username)) {
                    _showSnackBar('用户名已存在');
                    return;
                  }
                  
                  setState(() {
                    _system!.users.add(User(
                      username: username,
                      password: password,
                      role: selectedRole,
                      residentId: selectedResidentId,
                    ));
                  });
                  
                  _saveData();
                  Navigator.pop(context);
                  _showSnackBar('用户已添加');
                },
                child: const Text('添加'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditUserDialog(User user) {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController(text: user.password);
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedRole = user.role;
        String? selectedResidentId = user.residentId;
        
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('编辑用户'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: '用户名'),
                    enabled: false, // 用户名不可修改
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      hintText: '请输入新密码',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: '角色'),
                    items: ['普通用户', '超级管理员'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value ?? user.role;
                        if (selectedRole == '超级管理员') {
                          selectedResidentId = null;
                        }
                      });
                    },
                  ),
                  if (selectedRole == '普通用户') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: selectedResidentId,
                      decoration: const InputDecoration(labelText: '关联住户（可选）'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('无')),
                        ..._system!.residents.map((r) {
                          return DropdownMenuItem<String?>(
                            value: r.residentId,
                            child: Text('${r.residentId} - ${r.name}'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedResidentId = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final password = passwordController.text.trim();
                  
                  if (password.isEmpty) {
                    _showSnackBar('密码不能为空');
                    return;
                  }
                  
                  final index = _system!.users.indexWhere((u) => u.username == user.username);
                  if (index != -1) {
                    setState(() {
                      _system!.users[index] = User(
                        username: user.username,
                        password: password,
                        role: selectedRole,
                        residentId: selectedResidentId,
                      );
                    });
                    
                    // 如果修改的是当前登录用户，更新认证服务
                    if (user.username == widget.authService.getCurrentUser()?.username) {
                      widget.authService.setSystem(_system!);
                      widget.authService.login(user.username, password);
                    }
                    
                    _saveData();
                    Navigator.pop(context);
                    _showSnackBar('用户信息已更新');
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteUserDialog(User user) {
    // 不允许删除当前登录的用户
    if (user.username == widget.authService.getCurrentUser()?.username) {
      _showSnackBar('不能删除当前登录的用户');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除用户 "${user.username}" 吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _system!.users.removeWhere((u) => u.username == user.username);
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('用户已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

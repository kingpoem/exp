/// 普通用户主页
/// 包含用户个人信息、报修、投诉等功能

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'models.dart';
import 'login_page.dart';

class UserHomePage extends StatefulWidget {
  final AuthService authService;

  const UserHomePage({super.key, required this.authService});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PropertyManagementSystem? _system;
  Resident? _currentResident;
  final StorageService _storage = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      final user = widget.authService.getCurrentUser();
      Resident? resident;
      
      if (user?.residentId != null) {
        resident = system.residents.firstWhere(
          (r) => r.residentId == user!.residentId,
          orElse: () => Resident(
            residentId: '',
            name: '',
            phone: '',
            address: '',
            prepaidAmount: 0,
            arrears: 0,
            roomTypeId: '',
          ),
        );
      }

      setState(() {
        _system = system;
        _currentResident = resident;
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
              // 保存数据
              _saveData();
              // 退出登录
              widget.authService.logout();
              // 关闭确认对话框
              Navigator.pop(context);
              // 清除所有路由并返回到登录页面
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

    if (_currentResident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('用户主页')),
        body: const Center(child: Text('未关联住户信息')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('欢迎, ${_currentResident!.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '个人信息', icon: Icon(Icons.person)),
            Tab(text: '提交报修', icon: Icon(Icons.build)),
            Tab(text: '提交投诉', icon: Icon(Icons.report)),
            Tab(text: '我的车位', icon: Icon(Icons.local_parking)),
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
          _buildInfoTab(),
          _buildRepairTab(),
          _buildComplaintTab(),
          _buildParkingTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
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
                  const Text('个人信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoRow('住户编号', _currentResident!.residentId),
                  _buildInfoRow('姓名', _currentResident!.name),
                  _buildInfoRow('电话', _currentResident!.phone),
                  _buildInfoRow('地址', _currentResident!.address),
                  _buildInfoRow('预付金额', '${_currentResident!.prepaidAmount.toStringAsFixed(2)}元'),
                  _buildInfoRow('欠费金额', '${_currentResident!.arrears.toStringAsFixed(2)}元', isArrears: true),
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
                  const Text('修改信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '姓名',
                      hintText: _currentResident!.name,
                    ),
                    controller: TextEditingController(text: _currentResident!.name),
                    onChanged: (value) {
                      setState(() {
                        final index = _system!.residents.indexWhere((r) => r.residentId == _currentResident!.residentId);
                        if (index != -1) {
                          _system!.residents[index] = Resident(
                            residentId: _currentResident!.residentId,
                            name: value,
                            phone: _currentResident!.phone,
                            address: _currentResident!.address,
                            prepaidAmount: _currentResident!.prepaidAmount,
                            arrears: _currentResident!.arrears,
                            roomTypeId: _currentResident!.roomTypeId,
                          );
                          _currentResident = _system!.residents[index];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '电话',
                      hintText: _currentResident!.phone,
                    ),
                    controller: TextEditingController(text: _currentResident!.phone),
                    onChanged: (value) {
                      setState(() {
                        final index = _system!.residents.indexWhere((r) => r.residentId == _currentResident!.residentId);
                        if (index != -1) {
                          _system!.residents[index] = Resident(
                            residentId: _currentResident!.residentId,
                            name: _currentResident!.name,
                            phone: value,
                            address: _currentResident!.address,
                            prepaidAmount: _currentResident!.prepaidAmount,
                            arrears: _currentResident!.arrears,
                            roomTypeId: _currentResident!.roomTypeId,
                          );
                          _currentResident = _system!.residents[index];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '地址',
                      hintText: _currentResident!.address,
                    ),
                    controller: TextEditingController(text: _currentResident!.address),
                    onChanged: (value) {
                      setState(() {
                        final index = _system!.residents.indexWhere((r) => r.residentId == _currentResident!.residentId);
                        if (index != -1) {
                          _system!.residents[index] = Resident(
                            residentId: _currentResident!.residentId,
                            name: _currentResident!.name,
                            phone: _currentResident!.phone,
                            address: value,
                            prepaidAmount: _currentResident!.prepaidAmount,
                            arrears: _currentResident!.arrears,
                            roomTypeId: _currentResident!.roomTypeId,
                          );
                          _currentResident = _system!.residents[index];
                        }
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

  Widget _buildRepairTab() {
    final myRepairs = _system!.repairs.where((r) => r.residentId == _currentResident!.residentId).toList();
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('我的报修记录', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),
                  ...myRepairs.map((r) => ListTile(
                        title: Text(r.description),
                        subtitle: Text(r.createTime),
                        trailing: Chip(label: Text(r.status)),
                      )),
                  if (myRepairs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('暂无报修记录'),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSubmitRepairDialog(),
              icon: const Icon(Icons.add),
              label: const Text('提交报修'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintTab() {
    final myComplaints = _system!.complaints.where((c) => c.residentId == _currentResident!.residentId).toList();
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('我的投诉记录', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),
                  ...myComplaints.map((c) => ListTile(
                        title: Text(c.content),
                        subtitle: Text(c.createTime),
                        trailing: Chip(label: Text(c.status)),
                      )),
                  if (myComplaints.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('暂无投诉记录'),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSubmitComplaintDialog(),
              icon: const Icon(Icons.add),
              label: const Text('提交投诉'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParkingTab() {
    final parking = _system!.parkingSpaces.firstWhere(
      (ps) => ps.residentId == _currentResident!.residentId,
      orElse: () => ParkingSpace(spaceId: '', residentId: '', location: ''),
    );

    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_parking, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('我的车位信息', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (parking.spaceId.isNotEmpty) ...[
                _buildInfoRow('车位编号', parking.spaceId),
                const SizedBox(height: 16),
                _buildInfoRow('车位位置', parking.location),
              ] else
                const Text('您暂无车位信息', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isArrears = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: isArrears && double.tryParse(value.replaceAll('元', '')) != null && double.tryParse(value.replaceAll('元', ''))! > 0
                  ? Colors.red
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitRepairDialog() {
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交报修'),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: '报修描述',
            hintText: '请详细描述需要报修的问题',
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (descriptionController.text.trim().isNotEmpty) {
                final repair = Repair(
                  repairId: 'REP${DateTime.now().millisecondsSinceEpoch}',
                  residentId: _currentResident!.residentId,
                  description: descriptionController.text.trim(),
                  status: '待处理',
                  createTime: DateTime.now().toString().substring(0, 19),
                );
                setState(() {
                  _system!.repairs.add(repair);
                });
                _saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('报修已提交')),
                );
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  void _showSubmitComplaintDialog() {
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交投诉'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(
            labelText: '投诉内容',
            hintText: '请详细描述投诉内容',
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (contentController.text.trim().isNotEmpty) {
                final complaint = Complaint(
                  complaintId: 'COM${DateTime.now().millisecondsSinceEpoch}',
                  residentId: _currentResident!.residentId,
                  content: contentController.text.trim(),
                  status: '待处理',
                  createTime: DateTime.now().toString().substring(0, 19),
                );
                setState(() {
                  _system!.complaints.add(complaint);
                });
                _saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('投诉已提交')),
                );
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}

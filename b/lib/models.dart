/// 数据模型定义
/// 包含所有物业管理相关的数据结构

class Community {
  /// 小区名称
  final String name;
  
  /// 楼宇总数
  final int buildingCount;

  Community({required this.name, required this.buildingCount});

  Map<String, dynamic> toJson() => {
    'name': name,
    'building_count': buildingCount,
  };

  factory Community.fromJson(Map<String, dynamic> json) => Community(
    name: json['name'] as String,
    buildingCount: json['building_count'] as int,
  );
}

class RoomType {
  /// 房型编号
  final String roomTypeId;
  
  /// 房型
  final String roomType;
  
  /// 建筑面积（平方米）
  final double area;

  RoomType({
    required this.roomTypeId,
    required this.roomType,
    required this.area,
  });

  Map<String, dynamic> toJson() => {
    'room_type_id': roomTypeId,
    'room_type': roomType,
    'area': area,
  };

  factory RoomType.fromJson(Map<String, dynamic> json) => RoomType(
    roomTypeId: json['room_type_id'] as String,
    roomType: json['room_type'] as String,
    area: (json['area'] as num).toDouble(),
  );
}

class Resident {
  /// 住户编号
  final String residentId;
  
  /// 住户姓名
  final String name;
  
  /// 联系电话
  final String phone;
  
  /// 联系地址
  final String address;
  
  /// 预付金额
  final double prepaidAmount;
  
  /// 欠费金额
  final double arrears;
  
  /// 房型编号
  final String roomTypeId;

  Resident({
    required this.residentId,
    required this.name,
    required this.phone,
    required this.address,
    required this.prepaidAmount,
    required this.arrears,
    required this.roomTypeId,
  });

  Map<String, dynamic> toJson() => {
    'resident_id': residentId,
    'name': name,
    'phone': phone,
    'address': address,
    'prepaid_amount': prepaidAmount,
    'arrears': arrears,
    'room_type_id': roomTypeId,
  };

  factory Resident.fromJson(Map<String, dynamic> json) => Resident(
    residentId: json['resident_id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    prepaidAmount: (json['prepaid_amount'] as num).toDouble(),
    arrears: (json['arrears'] as num).toDouble(),
    roomTypeId: json['room_type_id'] as String,
  );
}

class Repair {
  /// 报修编号
  final String repairId;
  
  /// 住户编号
  final String residentId;
  
  /// 报修描述
  final String description;
  
  /// 状态
  final String status;
  
  /// 创建时间
  final String createTime;

  Repair({
    required this.repairId,
    required this.residentId,
    required this.description,
    required this.status,
    required this.createTime,
  });

  Map<String, dynamic> toJson() => {
    'repair_id': repairId,
    'resident_id': residentId,
    'description': description,
    'status': status,
    'create_time': createTime,
  };

  factory Repair.fromJson(Map<String, dynamic> json) => Repair(
    repairId: json['repair_id'] as String,
    residentId: json['resident_id'] as String,
    description: json['description'] as String,
    status: json['status'] as String,
    createTime: json['create_time'] as String,
  );
}

class Complaint {
  /// 投诉编号
  final String complaintId;
  
  /// 住户编号
  final String residentId;
  
  /// 投诉内容
  final String content;
  
  /// 状态
  final String status;
  
  /// 创建时间
  final String createTime;

  Complaint({
    required this.complaintId,
    required this.residentId,
    required this.content,
    required this.status,
    required this.createTime,
  });

  Map<String, dynamic> toJson() => {
    'complaint_id': complaintId,
    'resident_id': residentId,
    'content': content,
    'status': status,
    'create_time': createTime,
  };

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    complaintId: json['complaint_id'] as String,
    residentId: json['resident_id'] as String,
    content: json['content'] as String,
    status: json['status'] as String,
    createTime: json['create_time'] as String,
  );
}

class ParkingSpace {
  /// 车位编号
  final String spaceId;
  
  /// 住户编号
  final String residentId;
  
  /// 车位位置
  final String location;

  ParkingSpace({
    required this.spaceId,
    required this.residentId,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'space_id': spaceId,
    'resident_id': residentId,
    'location': location,
  };

  factory ParkingSpace.fromJson(Map<String, dynamic> json) => ParkingSpace(
    spaceId: json['space_id'] as String,
    residentId: json['resident_id'] as String,
    location: json['location'] as String,
  );
}

class Fee {
  /// 收费编号
  final String feeId;
  
  /// 收费名称
  final String name;
  
  /// 收费金额
  final double amount;
  
  /// 收费单位
  final String unit;
  
  /// 收费周期
  final String cycle;

  Fee({
    required this.feeId,
    required this.name,
    required this.amount,
    required this.unit,
    required this.cycle,
  });

  Map<String, dynamic> toJson() => {
    'fee_id': feeId,
    'name': name,
    'amount': amount,
    'unit': unit,
    'cycle': cycle,
  };

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
    feeId: json['fee_id'] as String,
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    unit: json['unit'] as String,
    cycle: json['cycle'] as String,
  );
}

class User {
  /// 用户名
  final String username;
  
  /// 密码
  final String password;
  
  /// 角色（普通用户、超级管理员）
  final String role;
  
  /// 关联的住户编号（普通用户）
  final String? residentId;

  User({
    required this.username,
    required this.password,
    required this.role,
    this.residentId,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'role': role,
    'resident_id': residentId,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'] as String,
    password: json['password'] as String,
    role: json['role'] as String,
    residentId: json['resident_id'] as String?,
  );
}

class PropertyManagementSystem {
  /// 小区资料
  Community? community;
  
  /// 房型资料列表
  List<RoomType> roomTypes;
  
  /// 住户资料列表
  List<Resident> residents;
  
  /// 报修记录列表
  List<Repair> repairs;
  
  /// 投诉记录列表
  List<Complaint> complaints;
  
  /// 停车位列表
  List<ParkingSpace> parkingSpaces;
  
  /// 收费项目列表
  List<Fee> fees;
  
  /// 用户列表
  List<User> users;

  PropertyManagementSystem({
    this.community,
    List<RoomType>? roomTypes,
    List<Resident>? residents,
    List<Repair>? repairs,
    List<Complaint>? complaints,
    List<ParkingSpace>? parkingSpaces,
    List<Fee>? fees,
    List<User>? users,
  })  : roomTypes = roomTypes ?? [],
        residents = residents ?? [],
        repairs = repairs ?? [],
        complaints = complaints ?? [],
        parkingSpaces = parkingSpaces ?? [],
        fees = fees ?? [],
        users = users ?? [];

  Map<String, dynamic> toJson() => {
    'community': community?.toJson(),
    'room_types': roomTypes.map((rt) => rt.toJson()).toList(),
    'residents': residents.map((r) => r.toJson()).toList(),
    'repairs': repairs.map((r) => r.toJson()).toList(),
    'complaints': complaints.map((c) => c.toJson()).toList(),
    'parking_spaces': parkingSpaces.map((ps) => ps.toJson()).toList(),
    'fees': fees.map((f) => f.toJson()).toList(),
    'users': users.map((u) => u.toJson()).toList(),
  };

  factory PropertyManagementSystem.fromJson(Map<String, dynamic> json) {
    return PropertyManagementSystem(
      community: json['community'] != null
          ? Community.fromJson(json['community'] as Map<String, dynamic>)
          : null,
      roomTypes: (json['room_types'] as List<dynamic>?)
              ?.map((rt) => RoomType.fromJson(rt as Map<String, dynamic>))
              .toList() ??
          [],
      residents: (json['residents'] as List<dynamic>?)
              ?.map((r) => Resident.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      repairs: (json['repairs'] as List<dynamic>?)
              ?.map((r) => Repair.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      complaints: (json['complaints'] as List<dynamic>?)
              ?.map((c) => Complaint.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      parkingSpaces: (json['parking_spaces'] as List<dynamic>?)
              ?.map((ps) => ParkingSpace.fromJson(ps as Map<String, dynamic>))
              .toList() ??
          [],
      fees: (json['fees'] as List<dynamic>?)
              ?.map((f) => Fee.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      users: (json['users'] as List<dynamic>?)
              ?.map((u) => User.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}


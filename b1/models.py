"""
数据模型定义
包含所有物业管理相关的数据结构
"""

from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime


@dataclass
class Community:
    """小区资料"""
    name: str  # 小区名称
    building_count: int  # 楼宇总数


@dataclass
class RoomType:
    """房型资料"""
    room_type_id: str  # 房型编号
    room_type: str  # 房型（如：一室一厅、两室一厅等）
    area: float  # 建筑面积（平方米）


@dataclass
class Resident:
    """住户资料"""
    resident_id: str  # 住户编号
    name: str  # 住户姓名
    phone: str  # 联系电话
    address: str  # 联系地址
    prepaid_amount: float  # 预付金额
    arrears: float  # 欠费金额
    room_type_id: str  # 房型编号


@dataclass
class Repair:
    """住户报修管理"""
    repair_id: str  # 报修编号
    resident_id: str  # 住户编号
    description: str  # 报修描述
    status: str  # 状态（待处理、处理中、已完成）
    create_time: str  # 创建时间


@dataclass
class Complaint:
    """住户投诉管理"""
    complaint_id: str  # 投诉编号
    resident_id: str  # 住户编号
    content: str  # 投诉内容
    status: str  # 状态（待处理、处理中、已解决）
    create_time: str  # 创建时间


@dataclass
class ParkingSpace:
    """住户停车车位管理"""
    space_id: str  # 车位编号
    resident_id: str  # 住户编号
    location: str  # 车位位置


@dataclass
class Fee:
    """住户物业收费管理"""
    fee_id: str  # 收费编号
    name: str  # 收费名称
    amount: float  # 收费金额
    unit: str  # 收费单位
    cycle: str  # 收费周期（如：月、季度、年）


@dataclass
class User:
    """用户信息"""
    username: str  # 用户名
    password: str  # 密码
    role: str  # 角色（普通用户、超级管理员）
    resident_id: Optional[str] = None  # 关联的住户编号（普通用户）


@dataclass
class PropertyManagementSystem:
    """物业管理系统数据容器"""
    community: Optional[Community] = None
    room_types: List[RoomType] = field(default_factory=list)
    residents: List[Resident] = field(default_factory=list)
    repairs: List[Repair] = field(default_factory=list)
    complaints: List[Complaint] = field(default_factory=list)
    parking_spaces: List[ParkingSpace] = field(default_factory=list)
    fees: List[Fee] = field(default_factory=list)
    users: List[User] = field(default_factory=list)


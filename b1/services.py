"""
核心功能服务模块
实现查询、排序、计算、显示等功能
"""

from typing import List, Optional
from datetime import datetime
from models import (
    PropertyManagementSystem, Community, RoomType, Resident, 
    Repair, Complaint, ParkingSpace, Fee
)


class CommunityService:
    """小区资料管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def set_community(self, name: str, building_count: int):
        """
        设置小区资料
        @param name: 小区名称
        @param building_count: 楼宇总数
        """
        self.system.community = Community(name=name, building_count=building_count)
    
    def get_community(self) -> Optional[Community]:
        """
        获取小区资料
        @return: 小区资料对象
        """
        return self.system.community


class RoomTypeService:
    """房型资料管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def add_room_type(self, room_type_id: str, room_type: str, area: float):
        """
        添加房型
        @param room_type_id: 房型编号
        @param room_type: 房型
        @param area: 建筑面积
        """
        self.system.room_types.append(
            RoomType(room_type_id=room_type_id, room_type=room_type, area=area)
        )
    
    def get_room_type_count(self) -> int:
        """
        计算小区的房型种类
        @return: 房型种类数量
        """
        return len(set(rt.room_type for rt in self.system.room_types))
    
    def get_all_room_types(self) -> List[RoomType]:
        """
        获取所有房型
        @return: 房型列表
        """
        return self.system.room_types


class ResidentService:
    """住户资料管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def add_resident(self, resident_id: str, name: str, phone: str, 
                    address: str, prepaid_amount: float, arrears: float, 
                    room_type_id: str):
        """
        添加住户
        @param resident_id: 住户编号
        @param name: 住户姓名
        @param phone: 联系电话
        @param address: 联系地址
        @param prepaid_amount: 预付金额
        @param arrears: 欠费金额
        @param room_type_id: 房型编号
        """
        self.system.residents.append(
            Resident(
                resident_id=resident_id,
                name=name,
                phone=phone,
                address=address,
                prepaid_amount=prepaid_amount,
                arrears=arrears,
                room_type_id=room_type_id
            )
        )
    
    def get_resident(self, resident_id: str) -> Optional[Resident]:
        """
        根据住户编号获取住户信息
        @param resident_id: 住户编号
        @return: 住户对象
        """
        for resident in self.system.residents:
            if resident.resident_id == resident_id:
                return resident
        return None
    
    def update_resident(self, resident_id: str, **kwargs):
        """
        更新住户信息
        @param resident_id: 住户编号
        @param kwargs: 要更新的字段
        """
        resident = self.get_resident(resident_id)
        if resident:
            for key, value in kwargs.items():
                if hasattr(resident, key):
                    setattr(resident, key, value)
    
    def get_residents_with_arrears(self) -> List[Resident]:
        """
        查询住户的欠费状况
        @return: 有欠费的住户列表
        """
        return [r for r in self.system.residents if r.arrears > 0]
    
    def sort_by_arrears(self) -> List[Resident]:
        """
        按照欠费金额进行排序
        @return: 排序后的住户列表（从高到低）
        """
        return sorted(self.system.residents, key=lambda x: x.arrears, reverse=True)
    
    def get_all_residents(self) -> List[Resident]:
        """
        获取所有住户
        @return: 住户列表
        """
        return self.system.residents


class RepairService:
    """住户报修管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def add_repair(self, repair_id: str, resident_id: str, description: str):
        """
        添加报修记录
        @param repair_id: 报修编号
        @param resident_id: 住户编号
        @param description: 报修描述
        """
        self.system.repairs.append(
            Repair(
                repair_id=repair_id,
                resident_id=resident_id,
                description=description,
                status="待处理",
                create_time=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            )
        )
    
    def get_repair_report(self) -> List[Repair]:
        """
        显示住户报修报表
        @return: 报修记录列表
        """
        return self.system.repairs
    
    def get_repairs_by_resident(self, resident_id: str) -> List[Repair]:
        """
        获取指定住户的报修记录
        @param resident_id: 住户编号
        @return: 报修记录列表
        """
        return [r for r in self.system.repairs if r.resident_id == resident_id]


class ComplaintService:
    """住户投诉管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def add_complaint(self, complaint_id: str, resident_id: str, content: str):
        """
        添加投诉记录
        @param complaint_id: 投诉编号
        @param resident_id: 住户编号
        @param content: 投诉内容
        """
        self.system.complaints.append(
            Complaint(
                complaint_id=complaint_id,
                resident_id=resident_id,
                content=content,
                status="待处理",
                create_time=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            )
        )
    
    def get_complaint_report(self) -> List[Complaint]:
        """
        显示住户投诉报表
        @return: 投诉记录列表
        """
        return self.system.complaints
    
    def get_complaints_by_resident(self, resident_id: str) -> List[Complaint]:
        """
        获取指定住户的投诉记录
        @param resident_id: 住户编号
        @return: 投诉记录列表
        """
        return [c for c in self.system.complaints if c.resident_id == resident_id]


class ParkingService:
    """住户停车车位管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def add_parking_space(self, space_id: str, resident_id: str, location: str):
        """
        添加停车位
        @param space_id: 车位编号
        @param resident_id: 住户编号
        @param location: 车位位置
        """
        self.system.parking_spaces.append(
            ParkingSpace(space_id=space_id, resident_id=resident_id, location=location)
        )
    
    def find_parking_by_resident(self, resident_id: str) -> Optional[ParkingSpace]:
        """
        查找住户的车位信息
        @param resident_id: 住户编号
        @return: 停车位对象
        """
        for ps in self.system.parking_spaces:
            if ps.resident_id == resident_id:
                return ps
        return None
    
    def find_parking_by_space_id(self, space_id: str) -> Optional[ParkingSpace]:
        """
        根据车位编号查找车位信息
        @param space_id: 车位编号
        @return: 停车位对象
        """
        for ps in self.system.parking_spaces:
            if ps.space_id == space_id:
                return ps
        return None


class FeeService:
    """住户物业收费管理服务"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化服务
        @param system: 物业管理系统对象
        """
        self.system = system
    
    def add_fee(self, fee_id: str, name: str, amount: float, unit: str, cycle: str):
        """
        添加收费项目
        @param fee_id: 收费编号
        @param name: 收费名称
        @param amount: 收费金额
        @param unit: 收费单位
        @param cycle: 收费周期
        """
        self.system.fees.append(
            Fee(fee_id=fee_id, name=name, amount=amount, unit=unit, cycle=cycle)
        )
    
    def get_all_fees(self) -> List[Fee]:
        """
        获取所有收费项目
        @return: 收费项目列表
        """
        return self.system.fees


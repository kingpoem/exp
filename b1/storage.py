"""
文件存储和加载功能
将小区的所有相关信息内容存为文件
"""

import json
import os
from typing import Optional
from models import PropertyManagementSystem, Community, RoomType, Resident, Repair, Complaint, ParkingSpace, Fee, User


class StorageManager:
    """存储管理器，负责数据的保存和加载"""
    
    def __init__(self, data_file: str = "property_data.json"):
        """
        初始化存储管理器
        @param data_file: 数据文件路径
        """
        self.data_file = data_file
    
    def save(self, system: PropertyManagementSystem) -> bool:
        """
        保存系统数据到文件
        @param system: 物业管理系统对象
        @return: 是否保存成功
        """
        try:
            data = {
                "community": {
                    "name": system.community.name,
                    "building_count": system.community.building_count
                } if system.community else None,
                "room_types": [
                    {
                        "room_type_id": rt.room_type_id,
                        "room_type": rt.room_type,
                        "area": rt.area
                    }
                    for rt in system.room_types
                ],
                "residents": [
                    {
                        "resident_id": r.resident_id,
                        "name": r.name,
                        "phone": r.phone,
                        "address": r.address,
                        "prepaid_amount": r.prepaid_amount,
                        "arrears": r.arrears,
                        "room_type_id": r.room_type_id
                    }
                    for r in system.residents
                ],
                "repairs": [
                    {
                        "repair_id": r.repair_id,
                        "resident_id": r.resident_id,
                        "description": r.description,
                        "status": r.status,
                        "create_time": r.create_time
                    }
                    for r in system.repairs
                ],
                "complaints": [
                    {
                        "complaint_id": c.complaint_id,
                        "resident_id": c.resident_id,
                        "content": c.content,
                        "status": c.status,
                        "create_time": c.create_time
                    }
                    for c in system.complaints
                ],
                "parking_spaces": [
                    {
                        "space_id": ps.space_id,
                        "resident_id": ps.resident_id,
                        "location": ps.location
                    }
                    for ps in system.parking_spaces
                ],
                "fees": [
                    {
                        "fee_id": f.fee_id,
                        "name": f.name,
                        "amount": f.amount,
                        "unit": f.unit,
                        "cycle": f.cycle
                    }
                    for f in system.fees
                ],
                "users": [
                    {
                        "username": u.username,
                        "password": u.password,
                        "role": u.role,
                        "resident_id": u.resident_id
                    }
                    for u in system.users
                ]
            }
            
            with open(self.data_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            return True
        except Exception as e:
            print(f"保存数据失败: {e}")
            return False
    
    def load(self) -> PropertyManagementSystem:
        """
        从文件加载系统数据
        @return: 物业管理系统对象
        """
        system = PropertyManagementSystem()
        
        # 如果文件不存在，返回空系统
        if not os.path.exists(self.data_file):
            return system
        
        try:
            with open(self.data_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # 加载小区资料
            if data.get("community"):
                system.community = Community(
                    name=data["community"]["name"],
                    building_count=data["community"]["building_count"]
                )
            
            # 加载房型资料
            system.room_types = [
                RoomType(
                    room_type_id=rt["room_type_id"],
                    room_type=rt["room_type"],
                    area=rt["area"]
                )
                for rt in data.get("room_types", [])
            ]
            
            # 加载住户资料
            system.residents = [
                Resident(
                    resident_id=r["resident_id"],
                    name=r["name"],
                    phone=r["phone"],
                    address=r["address"],
                    prepaid_amount=r["prepaid_amount"],
                    arrears=r["arrears"],
                    room_type_id=r["room_type_id"]
                )
                for r in data.get("residents", [])
            ]
            
            # 加载报修记录
            system.repairs = [
                Repair(
                    repair_id=r["repair_id"],
                    resident_id=r["resident_id"],
                    description=r["description"],
                    status=r["status"],
                    create_time=r["create_time"]
                )
                for r in data.get("repairs", [])
            ]
            
            # 加载投诉记录
            system.complaints = [
                Complaint(
                    complaint_id=c["complaint_id"],
                    resident_id=c["resident_id"],
                    content=c["content"],
                    status=c["status"],
                    create_time=c["create_time"]
                )
                for c in data.get("complaints", [])
            ]
            
            # 加载停车位信息
            system.parking_spaces = [
                ParkingSpace(
                    space_id=ps["space_id"],
                    resident_id=ps["resident_id"],
                    location=ps["location"]
                )
                for ps in data.get("parking_spaces", [])
            ]
            
            # 加载收费信息
            system.fees = [
                Fee(
                    fee_id=f["fee_id"],
                    name=f["name"],
                    amount=f["amount"],
                    unit=f["unit"],
                    cycle=f["cycle"]
                )
                for f in data.get("fees", [])
            ]
            
            # 加载用户信息
            system.users = [
                User(
                    username=u["username"],
                    password=u["password"],
                    role=u["role"],
                    resident_id=u.get("resident_id")
                )
                for u in data.get("users", [])
            ]
            
        except Exception as e:
            print(f"加载数据失败: {e}")
        
        return system


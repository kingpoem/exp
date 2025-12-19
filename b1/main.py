"""
小区物业管理系统 - 主程序
提供美观的界面和完整的交互功能
"""

import os
from datetime import datetime
from models import PropertyManagementSystem, User
from storage import StorageManager
from auth import AuthManager
from services import (
    CommunityService, RoomTypeService, ResidentService,
    RepairService, ComplaintService, ParkingService, FeeService
)


class PropertyManagementUI:
    """物业管理系统用户界面"""
    
    def __init__(self):
        """初始化系统"""
        self.storage = StorageManager()
        self.system = self.storage.load()
        self.auth = AuthManager(self.system)
        
        # 初始化各个服务
        self.community_service = CommunityService(self.system)
        self.room_type_service = RoomTypeService(self.system)
        self.resident_service = ResidentService(self.system)
        self.repair_service = RepairService(self.system)
        self.complaint_service = ComplaintService(self.system)
        self.parking_service = ParkingService(self.system)
        self.fee_service = FeeService(self.system)
        
        # 初始化默认数据（如果系统为空）
        self._init_default_data()
    
    def _init_default_data(self):
        """初始化默认数据（如果系统为空）"""
        if not self.system.users:
            # 创建默认管理员
            self.system.users.append(
                User(username="admin", password="admin123", role="超级管理员")
            )
            # 创建默认普通用户
            self.system.users.append(
                User(username="user1", password="user123", role="普通用户", resident_id="R001")
            )
        
        if not self.system.community:
            self.community_service.set_community("阳光小区", 10)
        
        if not self.system.room_types:
            self.room_type_service.add_room_type("RT001", "一室一厅", 60.0)
            self.room_type_service.add_room_type("RT002", "两室一厅", 90.0)
            self.room_type_service.add_room_type("RT003", "三室两厅", 120.0)
        
        if not self.system.residents:
            self.resident_service.add_resident("R001", "张三", "13800138001", "1号楼101", 5000.0, 500.0, "RT001")
            self.resident_service.add_resident("R002", "李四", "13800138002", "2号楼201", 3000.0, 1200.0, "RT002")
            self.resident_service.add_resident("R003", "王五", "13800138003", "3号楼301", 8000.0, 0.0, "RT003")
        
        if not self.system.parking_spaces:
            self.parking_service.add_parking_space("P001", "R001", "地下停车场A区001")
            self.parking_service.add_parking_space("P002", "R002", "地下停车场B区002")
        
        self.storage.save(self.system)
    
    def clear_screen(self):
        """清屏"""
        os.system('clear' if os.name != 'nt' else 'cls')
    
    def print_header(self, title: str):
        """打印标题"""
        print("\n" + "=" * 60)
        print(f"  {title}")
        print("=" * 60)
    
    def print_menu(self, menu_items: list):
        """打印菜单"""
        for i, item in enumerate(menu_items, 1):
            print(f"  {i}. {item}")
        print()
    
    def get_input(self, prompt: str) -> str:
        """获取用户输入"""
        return input(f"  {prompt}: ").strip()
    
    def login_menu(self):
        """登录菜单"""
        self.clear_screen()
        self.print_header("小区物业管理系统 - 用户登录")
        
        username = self.get_input("请输入用户名")
        password = self.get_input("请输入密码")
        
        if self.auth.login(username, password):
            print("\n  ✓ 登录成功！")
            input("  按回车键继续...")
            return True
        else:
            print("\n  ✗ 用户名或密码错误！")
            input("  按回车键返回...")
            return False
    
    def admin_menu(self):
        """管理员菜单"""
        while True:
            self.clear_screen()
            self.print_header("超级管理员 - 主菜单")
            menu_items = [
                "小区资料管理",
                "房型资料管理",
                "住户资料管理",
                "报修管理",
                "投诉管理",
                "停车位管理",
                "收费管理",
                "查询统计",
                "退出登录"
            ]
            self.print_menu(menu_items)
            
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                self.community_management()
            elif choice == "2":
                self.room_type_management()
            elif choice == "3":
                self.resident_management()
            elif choice == "4":
                self.repair_management()
            elif choice == "5":
                self.complaint_management()
            elif choice == "6":
                self.parking_management()
            elif choice == "7":
                self.fee_management()
            elif choice == "8":
                self.query_statistics()
            elif choice == "9":
                self.auth.logout()
                self.storage.save(self.system)
                break
            else:
                print("  无效的选择，请重试")
                input("  按回车键继续...")
    
    def user_menu(self):
        """普通用户菜单"""
        current_user = self.auth.get_current_user()
        resident_id = current_user.resident_id if current_user else None
        
        while True:
            self.clear_screen()
            self.print_header("普通用户 - 主菜单")
            menu_items = [
                "查询个人信息",
                "修改个人资料",
                "提交报修",
                "提交投诉",
                "查询车位信息",
                "退出登录"
            ]
            self.print_menu(menu_items)
            
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                self.view_own_info(resident_id)
            elif choice == "2":
                self.update_own_info(resident_id)
            elif choice == "3":
                self.submit_repair(resident_id)
            elif choice == "4":
                self.submit_complaint(resident_id)
            elif choice == "5":
                self.view_own_parking(resident_id)
            elif choice == "6":
                self.auth.logout()
                self.storage.save(self.system)
                break
            else:
                print("  无效的选择，请重试")
                input("  按回车键继续...")
    
    def community_management(self):
        """小区资料管理"""
        while True:
            self.clear_screen()
            self.print_header("小区资料管理")
            
            community = self.community_service.get_community()
            if community:
                print(f"  小区名称: {community.name}")
                print(f"  楼宇总数: {community.building_count}")
            else:
                print("  暂无小区资料")
            
            print("\n  1. 修改小区资料")
            print("  2. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                name = self.get_input("请输入小区名称")
                building_count = int(self.get_input("请输入楼宇总数"))
                self.community_service.set_community(name, building_count)
                self.storage.save(self.system)
                print("  ✓ 修改成功！")
                input("  按回车键继续...")
            elif choice == "2":
                break
    
    def room_type_management(self):
        """房型资料管理"""
        while True:
            self.clear_screen()
            self.print_header("房型资料管理")
            
            room_types = self.room_type_service.get_all_room_types()
            print(f"  房型种类数: {self.room_type_service.get_room_type_count()}\n")
            for rt in room_types:
                print(f"  {rt.room_type_id}: {rt.room_type} - {rt.area}平方米")
            
            print("\n  1. 添加房型")
            print("  2. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                room_type_id = self.get_input("请输入房型编号")
                room_type = self.get_input("请输入房型")
                area = float(self.get_input("请输入建筑面积"))
                self.room_type_service.add_room_type(room_type_id, room_type, area)
                self.storage.save(self.system)
                print("  ✓ 添加成功！")
                input("  按回车键继续...")
            elif choice == "2":
                break
    
    def resident_management(self):
        """住户资料管理"""
        while True:
            self.clear_screen()
            self.print_header("住户资料管理")
            
            print("  1. 添加住户")
            print("  2. 查看所有住户")
            print("  3. 查询欠费状况")
            print("  4. 按欠费金额排序")
            print("  5. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                resident_id = self.get_input("请输入住户编号")
                name = self.get_input("请输入住户姓名")
                phone = self.get_input("请输入联系电话")
                address = self.get_input("请输入联系地址")
                prepaid = float(self.get_input("请输入预付金额"))
                arrears = float(self.get_input("请输入欠费金额"))
                room_type_id = self.get_input("请输入房型编号")
                self.resident_service.add_resident(
                    resident_id, name, phone, address, prepaid, arrears, room_type_id
                )
                self.storage.save(self.system)
                print("  ✓ 添加成功！")
                input("  按回车键继续...")
            elif choice == "2":
                self.clear_screen()
                self.print_header("所有住户信息")
                residents = self.resident_service.get_all_residents()
                for r in residents:
                    print(f"  {r.resident_id}: {r.name} - 电话:{r.phone} - 欠费:{r.arrears}元")
                input("\n  按回车键返回...")
            elif choice == "3":
                self.clear_screen()
                self.print_header("欠费住户查询")
                arrears_residents = self.resident_service.get_residents_with_arrears()
                if arrears_residents:
                    for r in arrears_residents:
                        print(f"  {r.resident_id}: {r.name} - 欠费:{r.arrears}元")
                else:
                    print("  暂无欠费住户")
                input("\n  按回车键返回...")
            elif choice == "4":
                self.clear_screen()
                self.print_header("按欠费金额排序")
                sorted_residents = self.resident_service.sort_by_arrears()
                for r in sorted_residents:
                    print(f"  {r.resident_id}: {r.name} - 欠费:{r.arrears}元 - 地址:{r.address}")
                input("\n  按回车键返回...")
            elif choice == "5":
                break
    
    def repair_management(self):
        """报修管理"""
        while True:
            self.clear_screen()
            self.print_header("报修管理")
            
            print("  1. 查看报修报表")
            print("  2. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                self.clear_screen()
                self.print_header("住户报修报表")
                repairs = self.repair_service.get_repair_report()
                if repairs:
                    for r in repairs:
                        resident = self.resident_service.get_resident(r.resident_id)
                        name = resident.name if resident else "未知"
                        print(f"  {r.repair_id}: {name}({r.resident_id}) - {r.description} - {r.status} - {r.create_time}")
                else:
                    print("  暂无报修记录")
                input("\n  按回车键返回...")
            elif choice == "2":
                break
    
    def complaint_management(self):
        """投诉管理"""
        while True:
            self.clear_screen()
            self.print_header("投诉管理")
            
            print("  1. 查看投诉报表")
            print("  2. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                self.clear_screen()
                self.print_header("住户投诉报表")
                complaints = self.complaint_service.get_complaint_report()
                if complaints:
                    for c in complaints:
                        resident = self.resident_service.get_resident(c.resident_id)
                        name = resident.name if resident else "未知"
                        print(f"  {c.complaint_id}: {name}({c.resident_id}) - {c.content} - {c.status} - {c.create_time}")
                else:
                    print("  暂无投诉记录")
                input("\n  按回车键返回...")
            elif choice == "2":
                break
    
    def parking_management(self):
        """停车位管理"""
        while True:
            self.clear_screen()
            self.print_header("停车位管理")
            
            print("  1. 添加停车位")
            print("  2. 查找车位信息")
            print("  3. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                space_id = self.get_input("请输入车位编号")
                resident_id = self.get_input("请输入住户编号")
                location = self.get_input("请输入车位位置")
                self.parking_service.add_parking_space(space_id, resident_id, location)
                self.storage.save(self.system)
                print("  ✓ 添加成功！")
                input("  按回车键继续...")
            elif choice == "2":
                resident_id = self.get_input("请输入住户编号")
                parking = self.parking_service.find_parking_by_resident(resident_id)
                if parking:
                    resident = self.resident_service.get_resident(resident_id)
                    name = resident.name if resident else "未知"
                    print(f"\n  住户: {name}({resident_id})")
                    print(f"  车位编号: {parking.space_id}")
                    print(f"  车位位置: {parking.location}")
                else:
                    print("  未找到该住户的车位信息")
                input("\n  按回车键返回...")
            elif choice == "3":
                break
    
    def fee_management(self):
        """收费管理"""
        while True:
            self.clear_screen()
            self.print_header("收费管理")
            
            fees = self.fee_service.get_all_fees()
            for f in fees:
                print(f"  {f.fee_id}: {f.name} - {f.amount}元/{f.unit} - 周期:{f.cycle}")
            
            print("\n  1. 添加收费项目")
            print("  2. 返回")
            choice = self.get_input("请选择操作")
            
            if choice == "1":
                fee_id = self.get_input("请输入收费编号")
                name = self.get_input("请输入收费名称")
                amount = float(self.get_input("请输入收费金额"))
                unit = self.get_input("请输入收费单位")
                cycle = self.get_input("请输入收费周期")
                self.fee_service.add_fee(fee_id, name, amount, unit, cycle)
                self.storage.save(self.system)
                print("  ✓ 添加成功！")
                input("  按回车键继续...")
            elif choice == "2":
                break
    
    def query_statistics(self):
        """查询统计"""
        self.clear_screen()
        self.print_header("查询统计")
        
        print(f"  房型种类数: {self.room_type_service.get_room_type_count()}")
        arrears_count = len(self.resident_service.get_residents_with_arrears())
        print(f"  欠费住户数: {arrears_count}")
        print(f"  总住户数: {len(self.resident_service.get_all_residents())}")
        print(f"  总报修数: {len(self.repair_service.get_repair_report())}")
        print(f"  总投诉数: {len(self.complaint_service.get_complaint_report())}")
        print(f"  总停车位数: {len(self.parking_service.system.parking_spaces)}")
        
        input("\n  按回车键返回...")
    
    def view_own_info(self, resident_id: str):
        """查看个人信息"""
        if not resident_id:
            print("  未关联住户信息")
            input("  按回车键返回...")
            return
        
        self.clear_screen()
        self.print_header("个人信息")
        
        resident = self.resident_service.get_resident(resident_id)
        if resident:
            print(f"  住户编号: {resident.resident_id}")
            print(f"  姓名: {resident.name}")
            print(f"  电话: {resident.phone}")
            print(f"  地址: {resident.address}")
            print(f"  预付金额: {resident.prepaid_amount}元")
            print(f"  欠费金额: {resident.arrears}元")
            
            # 显示报修记录
            repairs = self.repair_service.get_repairs_by_resident(resident_id)
            print(f"\n  报修记录数: {len(repairs)}")
            for r in repairs:
                print(f"    - {r.description} ({r.status})")
            
            # 显示投诉记录
            complaints = self.complaint_service.get_complaints_by_resident(resident_id)
            print(f"\n  投诉记录数: {len(complaints)}")
            for c in complaints:
                print(f"    - {c.content} ({c.status})")
        else:
            print("  未找到住户信息")
        
        input("\n  按回车键返回...")
    
    def update_own_info(self, resident_id: str):
        """修改个人资料"""
        if not resident_id:
            print("  未关联住户信息")
            input("  按回车键返回...")
            return
        
        self.clear_screen()
        self.print_header("修改个人资料")
        
        resident = self.resident_service.get_resident(resident_id)
        if resident:
            print("  当前信息:")
            print(f"    姓名: {resident.name}")
            print(f"    电话: {resident.phone}")
            print(f"    地址: {resident.address}")
            
            print("\n  请输入新信息（直接回车保持原值）:")
            name = self.get_input("姓名")
            phone = self.get_input("电话")
            address = self.get_input("地址")
            
            updates = {}
            if name:
                updates['name'] = name
            if phone:
                updates['phone'] = phone
            if address:
                updates['address'] = address
            
            if updates:
                self.resident_service.update_resident(resident_id, **updates)
                self.storage.save(self.system)
                print("  ✓ 修改成功！")
            else:
                print("  未进行任何修改")
        else:
            print("  未找到住户信息")
        
        input("\n  按回车键返回...")
    
    def submit_repair(self, resident_id: str):
        """提交报修"""
        if not resident_id:
            print("  未关联住户信息")
            input("  按回车键返回...")
            return
        
        self.clear_screen()
        self.print_header("提交报修")
        
        repair_id = f"REP{datetime.now().strftime('%Y%m%d%H%M%S')}"
        description = self.get_input("请输入报修描述")
        
        self.repair_service.add_repair(repair_id, resident_id, description)
        self.storage.save(self.system)
        print("  ✓ 报修提交成功！")
        input("  按回车键返回...")
    
    def submit_complaint(self, resident_id: str):
        """提交投诉"""
        if not resident_id:
            print("  未关联住户信息")
            input("  按回车键返回...")
            return
        
        self.clear_screen()
        self.print_header("提交投诉")
        
        complaint_id = f"COM{datetime.now().strftime('%Y%m%d%H%M%S')}"
        content = self.get_input("请输入投诉内容")
        
        self.complaint_service.add_complaint(complaint_id, resident_id, content)
        self.storage.save(self.system)
        print("  ✓ 投诉提交成功！")
        input("  按回车键返回...")
    
    def view_own_parking(self, resident_id: str):
        """查看自己的车位信息"""
        if not resident_id:
            print("  未关联住户信息")
            input("  按回车键返回...")
            return
        
        self.clear_screen()
        self.print_header("我的车位信息")
        
        parking = self.parking_service.find_parking_by_resident(resident_id)
        if parking:
            print(f"  车位编号: {parking.space_id}")
            print(f"  车位位置: {parking.location}")
        else:
            print("  您暂无车位信息")
        
        input("\n  按回车键返回...")
    
    def run(self):
        """运行主程序"""
        while True:
            if not self.auth.is_logged_in():
                if not self.login_menu():
                    continue
            
            # 根据用户角色显示不同菜单
            if self.auth.is_admin():
                self.admin_menu()
            elif self.auth.is_normal_user():
                self.user_menu()
            else:
                break


def main():
    """主函数"""
    ui = PropertyManagementUI()
    ui.run()


if __name__ == "__main__":
    main()


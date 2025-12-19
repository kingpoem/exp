"""
小区物业管理系统 - GUI主程序
使用tkinter实现图形界面，增强错误处理能力
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import traceback
from datetime import datetime
from typing import Optional

from models import PropertyManagementSystem, User
from storage import StorageManager
from auth import AuthManager
from services import (
    CommunityService, RoomTypeService, ResidentService,
    RepairService, ComplaintService, ParkingService, FeeService
)


class ErrorHandler:
    """错误处理器，统一处理异常"""
    
    @staticmethod
    def handle_error(func):
        """装饰器：统一处理函数异常"""
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except ValueError as e:
                messagebox.showerror("输入错误", f"输入数据格式错误：{str(e)}")
                return None
            except KeyError as e:
                messagebox.showerror("数据错误", f"找不到指定的数据：{str(e)}")
                return None
            except Exception as e:
                error_msg = f"发生错误：{str(e)}\n\n详细信息：\n{traceback.format_exc()}"
                messagebox.showerror("系统错误", error_msg)
                return None
        return wrapper


class LoginWindow:
    """登录窗口"""
    
    def __init__(self, parent, auth_manager, on_success):
        """
        初始化登录窗口
        @param parent: 父窗口
        @param auth_manager: 认证管理器
        @param on_success: 登录成功回调函数
        """
        self.auth_manager = auth_manager
        self.on_success = on_success
        
        self.window = tk.Toplevel(parent)
        self.window.title("用户登录")
        self.window.geometry("400x200")
        self.window.resizable(False, False)
        self.window.transient(parent)
        self.window.grab_set()
        
        # 居中显示
        self.window.update_idletasks()
        x = (self.window.winfo_screenwidth() // 2) - (400 // 2)
        y = (self.window.winfo_screenheight() // 2) - (200 // 2)
        self.window.geometry(f"400x200+{x}+{y}")
        
        self._create_widgets()
    
    def _create_widgets(self):
        """创建界面组件"""
        # 标题
        title_label = tk.Label(self.window, text="小区物业管理系统", font=("Arial", 16, "bold"))
        title_label.pack(pady=20)
        
        # 用户名
        username_frame = tk.Frame(self.window)
        username_frame.pack(pady=10)
        tk.Label(username_frame, text="用户名:", width=10).pack(side=tk.LEFT)
        self.username_entry = tk.Entry(username_frame, width=20)
        self.username_entry.pack(side=tk.LEFT, padx=5)
        
        # 密码
        password_frame = tk.Frame(self.window)
        password_frame.pack(pady=10)
        tk.Label(password_frame, text="密码:", width=10).pack(side=tk.LEFT)
        self.password_entry = tk.Entry(password_frame, width=20, show="*")
        self.password_entry.pack(side=tk.LEFT, padx=5)
        
        # 按钮
        button_frame = tk.Frame(self.window)
        button_frame.pack(pady=20)
        tk.Button(button_frame, text="登录", command=self._login, width=10).pack(side=tk.LEFT, padx=5)
        tk.Button(button_frame, text="取消", command=self.window.destroy, width=10).pack(side=tk.LEFT, padx=5)
        
        # 绑定回车键
        self.window.bind('<Return>', lambda e: self._login())
        self.username_entry.focus()
    
    @ErrorHandler.handle_error
    def _login(self):
        """处理登录"""
        username = self.username_entry.get().strip()
        password = self.password_entry.get().strip()
        
        if not username or not password:
            messagebox.showwarning("输入提示", "请输入用户名和密码")
            return
        
        if self.auth_manager.login(username, password):
            self.window.destroy()
            self.on_success()
        else:
            messagebox.showerror("登录失败", "用户名或密码错误")


class MainWindow:
    """主窗口"""
    
    def __init__(self):
        """初始化主窗口"""
        self.root = tk.Tk()
        self.root.title("小区物业管理系统")
        self.root.geometry("1000x700")
        
        # 初始化数据
        self.storage = StorageManager()
        self.system = self.storage.load()
        self.auth = AuthManager(self.system)
        
        # 初始化服务
        self.community_service = CommunityService(self.system)
        self.room_type_service = RoomTypeService(self.system)
        self.resident_service = ResidentService(self.system)
        self.repair_service = RepairService(self.system)
        self.complaint_service = ComplaintService(self.system)
        self.parking_service = ParkingService(self.system)
        self.fee_service = FeeService(self.system)
        
        # 初始化默认数据
        self._init_default_data()
        
        # 创建界面
        self._create_menu()
        self._create_status_bar()
        
        # 显示登录窗口
        self._show_login()
    
    def _init_default_data(self):
        """初始化默认数据"""
        try:
            if not self.system.users:
                self.system.users.append(
                    User(username="admin", password="admin123", role="超级管理员")
                )
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
        except Exception as e:
            messagebox.showerror("初始化错误", f"初始化默认数据失败：{str(e)}")
    
    def _create_menu(self):
        """创建菜单栏"""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # 文件菜单
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="文件", menu=file_menu)
        file_menu.add_command(label="保存数据", command=self._save_data)
        file_menu.add_separator()
        file_menu.add_command(label="退出", command=self.root.quit)
        
        # 帮助菜单
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="帮助", menu=help_menu)
        help_menu.add_command(label="关于", command=self._show_about)
    
    def _create_status_bar(self):
        """创建状态栏"""
        self.status_bar = tk.Label(
            self.root, text="未登录", bd=1, relief=tk.SUNKEN, anchor=tk.W
        )
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
    
    def _update_status(self, message: str):
        """更新状态栏"""
        self.status_bar.config(text=message)
        self.root.update_idletasks()
    
    def _show_login(self):
        """显示登录窗口"""
        LoginWindow(self.root, self.auth, self._on_login_success)
    
    def _on_login_success(self):
        """登录成功后的处理"""
        user = self.auth.get_current_user()
        if user:
            role = user.role
            self._update_status(f"当前用户: {user.username} ({role})")
            self._create_main_interface()
    
    def _create_main_interface(self):
        """创建主界面"""
        # 清除现有内容
        for widget in self.root.winfo_children():
            if isinstance(widget, tk.Menu):
                continue
            widget.destroy()
        
        # 重新创建状态栏
        self._create_status_bar()
        
        # 创建笔记本（标签页）
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # 根据用户角色显示不同标签页
        if self.auth.is_admin():
            self._create_admin_tabs()
        elif self.auth.is_normal_user():
            self._create_user_tabs()
        
        # 添加退出登录按钮
        logout_frame = tk.Frame(self.root)
        logout_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=5, pady=5)
        tk.Button(
            logout_frame, text="退出登录", command=self._logout,
            bg="#ff6b6b", fg="white", font=("Arial", 10, "bold")
        ).pack(side=tk.RIGHT)
    
    def _create_admin_tabs(self):
        """创建管理员标签页"""
        # 小区资料
        community_frame = self._create_community_tab()
        self.notebook.add(community_frame, text="小区资料")
        
        # 房型管理
        room_type_frame = self._create_room_type_tab()
        self.notebook.add(room_type_frame, text="房型管理")
        
        # 住户管理
        resident_frame = self._create_resident_tab()
        self.notebook.add(resident_frame, text="住户管理")
        
        # 报修管理
        repair_frame = self._create_repair_tab()
        self.notebook.add(repair_frame, text="报修管理")
        
        # 投诉管理
        complaint_frame = self._create_complaint_tab()
        self.notebook.add(complaint_frame, text="投诉管理")
        
        # 停车位管理
        parking_frame = self._create_parking_tab()
        self.notebook.add(parking_frame, text="停车位管理")
        
        # 收费管理
        fee_frame = self._create_fee_tab()
        self.notebook.add(fee_frame, text="收费管理")
        
        # 统计查询
        stats_frame = self._create_stats_tab()
        self.notebook.add(stats_frame, text="统计查询")
    
    def _create_user_tabs(self):
        """创建普通用户标签页"""
        user = self.auth.get_current_user()
        resident_id = user.resident_id if user else None
        
        # 个人信息
        info_frame = self._create_user_info_tab(resident_id)
        self.notebook.add(info_frame, text="个人信息")
        
        # 报修
        repair_frame = self._create_user_repair_tab(resident_id)
        self.notebook.add(repair_frame, text="提交报修")
        
        # 投诉
        complaint_frame = self._create_user_complaint_tab(resident_id)
        self.notebook.add(complaint_frame, text="提交投诉")
        
        # 车位信息
        parking_frame = self._create_user_parking_tab(resident_id)
        self.notebook.add(parking_frame, text="我的车位")
    
    # 以下是各个标签页的创建方法
    def _create_community_tab(self):
        """创建小区资料标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 显示当前信息
        info_frame = ttk.LabelFrame(frame, text="小区信息", padding=10)
        info_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        community = self.community_service.get_community()
        if community:
            tk.Label(info_frame, text=f"小区名称: {community.name}", font=("Arial", 12)).pack(anchor=tk.W)
            tk.Label(info_frame, text=f"楼宇总数: {community.building_count}", font=("Arial", 12)).pack(anchor=tk.W)
        else:
            tk.Label(info_frame, text="暂无小区资料", font=("Arial", 12)).pack(anchor=tk.W)
        
        # 编辑区域
        edit_frame = ttk.LabelFrame(frame, text="编辑小区资料", padding=10)
        edit_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(edit_frame, text="小区名称:").grid(row=0, column=0, sticky=tk.W, pady=5)
        name_entry = tk.Entry(edit_frame, width=30)
        name_entry.grid(row=0, column=1, pady=5)
        if community:
            name_entry.insert(0, community.name)
        
        tk.Label(edit_frame, text="楼宇总数:").grid(row=1, column=0, sticky=tk.W, pady=5)
        building_entry = tk.Entry(edit_frame, width=30)
        building_entry.grid(row=1, column=1, pady=5)
        if community:
            building_entry.insert(0, str(community.building_count))
        
        def save_community():
            try:
                name = name_entry.get().strip()
                building_count = int(building_entry.get().strip())
                if not name:
                    messagebox.showwarning("输入提示", "请输入小区名称")
                    return
                self.community_service.set_community(name, building_count)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "小区资料已更新")
                # 刷新显示
                for widget in info_frame.winfo_children():
                    widget.destroy()
                tk.Label(info_frame, text=f"小区名称: {name}", font=("Arial", 12)).pack(anchor=tk.W)
                tk.Label(info_frame, text=f"楼宇总数: {building_count}", font=("Arial", 12)).pack(anchor=tk.W)
            except ValueError:
                messagebox.showerror("输入错误", "楼宇总数必须是整数")
            except Exception as e:
                messagebox.showerror("错误", f"保存失败：{str(e)}")
        
        tk.Button(edit_frame, text="保存", command=save_community).grid(row=2, column=1, pady=10, sticky=tk.E)
        
        return frame
    
    def _create_room_type_tab(self):
        """创建房型管理标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 列表显示
        list_frame = ttk.LabelFrame(frame, text="房型列表", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        tree = ttk.Treeview(list_frame, columns=("ID", "房型", "面积"), show="headings", height=10)
        tree.heading("ID", text="房型编号")
        tree.heading("房型", text="房型")
        tree.heading("面积", text="建筑面积(㎡)")
        tree.column("ID", width=100)
        tree.column("房型", width=150)
        tree.column("面积", width=150)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for rt in self.room_type_service.get_all_room_types():
                tree.insert("", tk.END, values=(rt.room_type_id, rt.room_type, rt.area))
        
        refresh_list()
        
        # 添加区域
        add_frame = ttk.LabelFrame(frame, text="添加房型", padding=10)
        add_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(add_frame, text="房型编号:").grid(row=0, column=0, sticky=tk.W, pady=5)
        id_entry = tk.Entry(add_frame, width=20)
        id_entry.grid(row=0, column=1, pady=5)
        
        tk.Label(add_frame, text="房型:").grid(row=1, column=0, sticky=tk.W, pady=5)
        type_entry = tk.Entry(add_frame, width=20)
        type_entry.grid(row=1, column=1, pady=5)
        
        tk.Label(add_frame, text="建筑面积:").grid(row=2, column=0, sticky=tk.W, pady=5)
        area_entry = tk.Entry(add_frame, width=20)
        area_entry.grid(row=2, column=1, pady=5)
        
        def add_room_type():
            try:
                room_type_id = id_entry.get().strip()
                room_type = type_entry.get().strip()
                area = float(area_entry.get().strip())
                if not room_type_id or not room_type:
                    messagebox.showwarning("输入提示", "请填写完整信息")
                    return
                self.room_type_service.add_room_type(room_type_id, room_type, area)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "房型已添加")
                id_entry.delete(0, tk.END)
                type_entry.delete(0, tk.END)
                area_entry.delete(0, tk.END)
                refresh_list()
            except ValueError:
                messagebox.showerror("输入错误", "建筑面积必须是数字")
            except Exception as e:
                messagebox.showerror("错误", f"添加失败：{str(e)}")
        
        tk.Button(add_frame, text="添加", command=add_room_type).grid(row=3, column=1, pady=10, sticky=tk.E)
        
        # 统计信息
        stats_label = tk.Label(frame, text=f"房型种类数: {self.room_type_service.get_room_type_count()}", font=("Arial", 10, "bold"))
        stats_label.pack(pady=5)
        
        return frame
    
    def _create_resident_tab(self):
        """创建住户管理标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 工具栏
        toolbar = tk.Frame(frame)
        toolbar.pack(fill=tk.X, padx=10, pady=5)
        
        def show_all():
            refresh_list(self.resident_service.get_all_residents())
        
        def show_arrears():
            refresh_list(self.resident_service.get_residents_with_arrears())
        
        def show_sorted():
            refresh_list(self.resident_service.sort_by_arrears())
        
        tk.Button(toolbar, text="全部住户", command=show_all).pack(side=tk.LEFT, padx=5)
        tk.Button(toolbar, text="欠费住户", command=show_arrears).pack(side=tk.LEFT, padx=5)
        tk.Button(toolbar, text="按欠费排序", command=show_sorted).pack(side=tk.LEFT, padx=5)
        
        # 列表显示
        list_frame = ttk.LabelFrame(frame, text="住户列表", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        tree = ttk.Treeview(
            list_frame, 
            columns=("ID", "姓名", "电话", "地址", "预付", "欠费"),
            show="headings",
            height=12
        )
        tree.heading("ID", text="住户编号")
        tree.heading("姓名", text="姓名")
        tree.heading("电话", text="联系电话")
        tree.heading("地址", text="联系地址")
        tree.heading("预付", text="预付金额")
        tree.heading("欠费", text="欠费金额")
        tree.column("ID", width=80)
        tree.column("姓名", width=100)
        tree.column("电话", width=120)
        tree.column("地址", width=150)
        tree.column("预付", width=100)
        tree.column("欠费", width=100)
        tree.pack(fill=tk.BOTH, expand=True, side=tk.LEFT)
        
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=tree.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        tree.configure(yscrollcommand=scrollbar.set)
        
        def refresh_list(residents):
            for item in tree.get_children():
                tree.delete(item)
            for r in residents:
                tree.insert("", tk.END, values=(
                    r.resident_id, r.name, r.phone, r.address,
                    f"{r.prepaid_amount:.2f}", f"{r.arrears:.2f}"
                ))
        
        show_all()
        
        # 添加住户区域
        add_frame = ttk.LabelFrame(frame, text="添加住户", padding=10)
        add_frame.pack(fill=tk.X, padx=10, pady=10)
        
        entries = {}
        fields = [
            ("住户编号", "resident_id"),
            ("姓名", "name"),
            ("电话", "phone"),
            ("地址", "address"),
            ("预付金额", "prepaid"),
            ("欠费金额", "arrears"),
            ("房型编号", "room_type_id")
        ]
        
        for i, (label, key) in enumerate(fields):
            row, col = divmod(i, 4)
            tk.Label(add_frame, text=f"{label}:").grid(row=row*2, column=col*2, sticky=tk.W, pady=5, padx=5)
            entry = tk.Entry(add_frame, width=15)
            entry.grid(row=row*2, column=col*2+1, pady=5, padx=5)
            entries[key] = entry
        
        def add_resident():
            try:
                resident_id = entries["resident_id"].get().strip()
                name = entries["name"].get().strip()
                phone = entries["phone"].get().strip()
                address = entries["address"].get().strip()
                prepaid = float(entries["prepaid"].get().strip() or "0")
                arrears = float(entries["arrears"].get().strip() or "0")
                room_type_id = entries["room_type_id"].get().strip()
                
                if not all([resident_id, name, phone, address, room_type_id]):
                    messagebox.showwarning("输入提示", "请填写完整信息")
                    return
                
                self.resident_service.add_resident(
                    resident_id, name, phone, address, prepaid, arrears, room_type_id
                )
                self.storage.save(self.system)
                messagebox.showinfo("成功", "住户已添加")
                for entry in entries.values():
                    entry.delete(0, tk.END)
                show_all()
            except ValueError:
                messagebox.showerror("输入错误", "金额必须是数字")
            except Exception as e:
                messagebox.showerror("错误", f"添加失败：{str(e)}")
        
        tk.Button(add_frame, text="添加", command=add_resident).grid(row=4, column=6, pady=10)
        
        return frame
    
    def _create_repair_tab(self):
        """创建报修管理标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 列表显示
        list_frame = ttk.LabelFrame(frame, text="报修报表", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        tree = ttk.Treeview(
            list_frame,
            columns=("ID", "住户", "描述", "状态", "时间"),
            show="headings",
            height=15
        )
        tree.heading("ID", text="报修编号")
        tree.heading("住户", text="住户")
        tree.heading("描述", text="报修描述")
        tree.heading("状态", text="状态")
        tree.heading("时间", text="创建时间")
        tree.column("ID", width=120)
        tree.column("住户", width=100)
        tree.column("描述", width=200)
        tree.column("状态", width=80)
        tree.column("时间", width=150)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for r in self.repair_service.get_repair_report():
                resident = self.resident_service.get_resident(r.resident_id)
                name = resident.name if resident else "未知"
                tree.insert("", tk.END, values=(
                    r.repair_id, name, r.description, r.status, r.create_time
                ))
        
        refresh_list()
        
        return frame
    
    def _create_complaint_tab(self):
        """创建投诉管理标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 列表显示
        list_frame = ttk.LabelFrame(frame, text="投诉报表", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        tree = ttk.Treeview(
            list_frame,
            columns=("ID", "住户", "内容", "状态", "时间"),
            show="headings",
            height=15
        )
        tree.heading("ID", text="投诉编号")
        tree.heading("住户", text="住户")
        tree.heading("内容", text="投诉内容")
        tree.heading("状态", text="状态")
        tree.heading("时间", text="创建时间")
        tree.column("ID", width=120)
        tree.column("住户", width=100)
        tree.column("内容", width=250)
        tree.column("状态", width=80)
        tree.column("时间", width=150)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for c in self.complaint_service.get_complaint_report():
                resident = self.resident_service.get_resident(c.resident_id)
                name = resident.name if resident else "未知"
                tree.insert("", tk.END, values=(
                    c.complaint_id, name, c.content, c.status, c.create_time
                ))
        
        refresh_list()
        
        return frame
    
    def _create_parking_tab(self):
        """创建停车位管理标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 列表显示
        list_frame = ttk.LabelFrame(frame, text="停车位列表", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        tree = ttk.Treeview(
            list_frame,
            columns=("车位ID", "住户ID", "住户姓名", "位置"),
            show="headings",
            height=12
        )
        tree.heading("车位ID", text="车位编号")
        tree.heading("住户ID", text="住户编号")
        tree.heading("住户姓名", text="住户姓名")
        tree.heading("位置", text="车位位置")
        tree.column("车位ID", width=100)
        tree.column("住户ID", width=100)
        tree.column("住户姓名", width=100)
        tree.column("位置", width=200)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for ps in self.parking_service.system.parking_spaces:
                resident = self.resident_service.get_resident(ps.resident_id)
                name = resident.name if resident else "未知"
                tree.insert("", tk.END, values=(
                    ps.space_id, ps.resident_id, name, ps.location
                ))
        
        refresh_list()
        
        # 添加区域
        add_frame = ttk.LabelFrame(frame, text="添加停车位", padding=10)
        add_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(add_frame, text="车位编号:").grid(row=0, column=0, sticky=tk.W, pady=5)
        space_id_entry = tk.Entry(add_frame, width=20)
        space_id_entry.grid(row=0, column=1, pady=5)
        
        tk.Label(add_frame, text="住户编号:").grid(row=1, column=0, sticky=tk.W, pady=5)
        resident_id_entry = tk.Entry(add_frame, width=20)
        resident_id_entry.grid(row=1, column=1, pady=5)
        
        tk.Label(add_frame, text="车位位置:").grid(row=2, column=0, sticky=tk.W, pady=5)
        location_entry = tk.Entry(add_frame, width=20)
        location_entry.grid(row=2, column=1, pady=5)
        
        def add_parking():
            try:
                space_id = space_id_entry.get().strip()
                resident_id = resident_id_entry.get().strip()
                location = location_entry.get().strip()
                if not all([space_id, resident_id, location]):
                    messagebox.showwarning("输入提示", "请填写完整信息")
                    return
                self.parking_service.add_parking_space(space_id, resident_id, location)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "停车位已添加")
                space_id_entry.delete(0, tk.END)
                resident_id_entry.delete(0, tk.END)
                location_entry.delete(0, tk.END)
                refresh_list()
            except Exception as e:
                messagebox.showerror("错误", f"添加失败：{str(e)}")
        
        tk.Button(add_frame, text="添加", command=add_parking).grid(row=3, column=1, pady=10, sticky=tk.E)
        
        # 查找区域
        search_frame = ttk.LabelFrame(frame, text="查找车位", padding=10)
        search_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(search_frame, text="住户编号:").grid(row=0, column=0, sticky=tk.W, pady=5)
        search_entry = tk.Entry(search_frame, width=20)
        search_entry.grid(row=0, column=1, pady=5)
        
        result_text = scrolledtext.ScrolledText(search_frame, height=3, width=50)
        result_text.grid(row=1, column=0, columnspan=2, pady=5)
        
        def search_parking():
            try:
                resident_id = search_entry.get().strip()
                if not resident_id:
                    messagebox.showwarning("输入提示", "请输入住户编号")
                    return
                parking = self.parking_service.find_parking_by_resident(resident_id)
                result_text.delete(1.0, tk.END)
                if parking:
                    resident = self.resident_service.get_resident(resident_id)
                    name = resident.name if resident else "未知"
                    result_text.insert(1.0, f"住户: {name}({resident_id})\n车位编号: {parking.space_id}\n车位位置: {parking.location}")
                else:
                    result_text.insert(1.0, "未找到该住户的车位信息")
            except Exception as e:
                messagebox.showerror("错误", f"查找失败：{str(e)}")
        
        tk.Button(search_frame, text="查找", command=search_parking).grid(row=0, column=2, padx=5)
        
        return frame
    
    def _create_fee_tab(self):
        """创建收费管理标签页"""
        frame = ttk.Frame(self.notebook)
        
        # 列表显示
        list_frame = ttk.LabelFrame(frame, text="收费项目列表", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        tree = ttk.Treeview(
            list_frame,
            columns=("ID", "名称", "金额", "单位", "周期"),
            show="headings",
            height=12
        )
        tree.heading("ID", text="收费编号")
        tree.heading("名称", text="收费名称")
        tree.heading("金额", text="收费金额")
        tree.heading("单位", text="收费单位")
        tree.heading("周期", text="收费周期")
        tree.column("ID", width=100)
        tree.column("名称", width=150)
        tree.column("金额", width=100)
        tree.column("单位", width=100)
        tree.column("周期", width=100)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for f in self.fee_service.get_all_fees():
                tree.insert("", tk.END, values=(
                    f.fee_id, f.name, f"{f.amount:.2f}", f.unit, f.cycle
                ))
        
        refresh_list()
        
        # 添加区域
        add_frame = ttk.LabelFrame(frame, text="添加收费项目", padding=10)
        add_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(add_frame, text="收费编号:").grid(row=0, column=0, sticky=tk.W, pady=5)
        fee_id_entry = tk.Entry(add_frame, width=20)
        fee_id_entry.grid(row=0, column=1, pady=5)
        
        tk.Label(add_frame, text="收费名称:").grid(row=1, column=0, sticky=tk.W, pady=5)
        name_entry = tk.Entry(add_frame, width=20)
        name_entry.grid(row=1, column=1, pady=5)
        
        tk.Label(add_frame, text="收费金额:").grid(row=2, column=0, sticky=tk.W, pady=5)
        amount_entry = tk.Entry(add_frame, width=20)
        amount_entry.grid(row=2, column=1, pady=5)
        
        tk.Label(add_frame, text="收费单位:").grid(row=3, column=0, sticky=tk.W, pady=5)
        unit_entry = tk.Entry(add_frame, width=20)
        unit_entry.grid(row=3, column=1, pady=5)
        
        tk.Label(add_frame, text="收费周期:").grid(row=4, column=0, sticky=tk.W, pady=5)
        cycle_entry = tk.Entry(add_frame, width=20)
        cycle_entry.grid(row=4, column=1, pady=5)
        
        def add_fee():
            try:
                fee_id = fee_id_entry.get().strip()
                name = name_entry.get().strip()
                amount = float(amount_entry.get().strip())
                unit = unit_entry.get().strip()
                cycle = cycle_entry.get().strip()
                if not all([fee_id, name, unit, cycle]):
                    messagebox.showwarning("输入提示", "请填写完整信息")
                    return
                self.fee_service.add_fee(fee_id, name, amount, unit, cycle)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "收费项目已添加")
                for entry in [fee_id_entry, name_entry, amount_entry, unit_entry, cycle_entry]:
                    entry.delete(0, tk.END)
                refresh_list()
            except ValueError:
                messagebox.showerror("输入错误", "收费金额必须是数字")
            except Exception as e:
                messagebox.showerror("错误", f"添加失败：{str(e)}")
        
        tk.Button(add_frame, text="添加", command=add_fee).grid(row=5, column=1, pady=10, sticky=tk.E)
        
        return frame
    
    def _create_stats_tab(self):
        """创建统计查询标签页"""
        frame = ttk.Frame(self.notebook)
        
        stats_frame = ttk.LabelFrame(frame, text="统计信息", padding=20)
        stats_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        def refresh_stats():
            for widget in stats_frame.winfo_children():
                widget.destroy()
            
            room_type_count = self.room_type_service.get_room_type_count()
            arrears_count = len(self.resident_service.get_residents_with_arrears())
            total_residents = len(self.resident_service.get_all_residents())
            total_repairs = len(self.repair_service.get_repair_report())
            total_complaints = len(self.complaint_service.get_complaint_report())
            total_parking = len(self.parking_service.system.parking_spaces)
            
            stats = [
                ("房型种类数", room_type_count),
                ("欠费住户数", arrears_count),
                ("总住户数", total_residents),
                ("总报修数", total_repairs),
                ("总投诉数", total_complaints),
                ("总停车位数", total_parking)
            ]
            
            for i, (label, value) in enumerate(stats):
                row_frame = tk.Frame(stats_frame)
                row_frame.pack(fill=tk.X, pady=10)
                tk.Label(row_frame, text=f"{label}:", font=("Arial", 12), width=15, anchor=tk.W).pack(side=tk.LEFT)
                tk.Label(row_frame, text=str(value), font=("Arial", 12, "bold"), fg="blue").pack(side=tk.LEFT)
        
        refresh_stats()
        
        tk.Button(stats_frame, text="刷新", command=refresh_stats).pack(pady=10)
        
        return frame
    
    def _create_user_info_tab(self, resident_id: Optional[str]):
        """创建用户个人信息标签页"""
        frame = ttk.Frame(self.notebook)
        
        if not resident_id:
            tk.Label(frame, text="未关联住户信息", font=("Arial", 12)).pack(pady=50)
            return frame
        
        info_frame = ttk.LabelFrame(frame, text="个人信息", padding=20)
        info_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        resident = self.resident_service.get_resident(resident_id)
        if not resident:
            tk.Label(info_frame, text="未找到住户信息", font=("Arial", 12)).pack(pady=50)
            return frame
        
        # 显示信息
        fields = [
            ("住户编号", resident.resident_id),
            ("姓名", resident.name),
            ("电话", resident.phone),
            ("地址", resident.address),
            ("预付金额", f"{resident.prepaid_amount:.2f}元"),
            ("欠费金额", f"{resident.arrears:.2f}元")
        ]
        
        for label, value in fields:
            row_frame = tk.Frame(info_frame)
            row_frame.pack(fill=tk.X, pady=8)
            tk.Label(row_frame, text=f"{label}:", font=("Arial", 11), width=12, anchor=tk.W).pack(side=tk.LEFT)
            tk.Label(row_frame, text=str(value), font=("Arial", 11)).pack(side=tk.LEFT)
        
        # 编辑区域
        edit_frame = ttk.LabelFrame(frame, text="修改信息", padding=20)
        edit_frame.pack(fill=tk.X, padx=20, pady=20)
        
        tk.Label(edit_frame, text="姓名:").grid(row=0, column=0, sticky=tk.W, pady=5)
        name_entry = tk.Entry(edit_frame, width=25)
        name_entry.insert(0, resident.name)
        name_entry.grid(row=0, column=1, pady=5)
        
        tk.Label(edit_frame, text="电话:").grid(row=1, column=0, sticky=tk.W, pady=5)
        phone_entry = tk.Entry(edit_frame, width=25)
        phone_entry.insert(0, resident.phone)
        phone_entry.grid(row=1, column=1, pady=5)
        
        tk.Label(edit_frame, text="地址:").grid(row=2, column=0, sticky=tk.W, pady=5)
        address_entry = tk.Entry(edit_frame, width=25)
        address_entry.insert(0, resident.address)
        address_entry.grid(row=2, column=1, pady=5)
        
        def update_info():
            try:
                name = name_entry.get().strip()
                phone = phone_entry.get().strip()
                address = address_entry.get().strip()
                if not all([name, phone, address]):
                    messagebox.showwarning("输入提示", "请填写完整信息")
                    return
                self.resident_service.update_resident(resident_id, name=name, phone=phone, address=address)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "信息已更新")
                # 刷新显示
                resident = self.resident_service.get_resident(resident_id)
                for widget in info_frame.winfo_children():
                    widget.destroy()
                fields = [
                    ("住户编号", resident.resident_id),
                    ("姓名", resident.name),
                    ("电话", resident.phone),
                    ("地址", resident.address),
                    ("预付金额", f"{resident.prepaid_amount:.2f}元"),
                    ("欠费金额", f"{resident.arrears:.2f}元")
                ]
                for label, value in fields:
                    row_frame = tk.Frame(info_frame)
                    row_frame.pack(fill=tk.X, pady=8)
                    tk.Label(row_frame, text=f"{label}:", font=("Arial", 11), width=12, anchor=tk.W).pack(side=tk.LEFT)
                    tk.Label(row_frame, text=str(value), font=("Arial", 11)).pack(side=tk.LEFT)
            except Exception as e:
                messagebox.showerror("错误", f"更新失败：{str(e)}")
        
        tk.Button(edit_frame, text="保存", command=update_info).grid(row=3, column=1, pady=10, sticky=tk.E)
        
        return frame
    
    def _create_user_repair_tab(self, resident_id: Optional[str]):
        """创建用户报修标签页"""
        frame = ttk.Frame(self.notebook)
        
        if not resident_id:
            tk.Label(frame, text="未关联住户信息", font=("Arial", 12)).pack(pady=50)
            return frame
        
        # 提交报修
        submit_frame = ttk.LabelFrame(frame, text="提交报修", padding=20)
        submit_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        tk.Label(submit_frame, text="报修描述:", font=("Arial", 11)).pack(anchor=tk.W, pady=5)
        description_text = scrolledtext.ScrolledText(submit_frame, height=8, width=50)
        description_text.pack(fill=tk.BOTH, expand=True, pady=5)
        
        def submit_repair():
            try:
                description = description_text.get(1.0, tk.END).strip()
                if not description:
                    messagebox.showwarning("输入提示", "请输入报修描述")
                    return
                repair_id = f"REP{datetime.now().strftime('%Y%m%d%H%M%S')}"
                self.repair_service.add_repair(repair_id, resident_id, description)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "报修已提交")
                description_text.delete(1.0, tk.END)
            except Exception as e:
                messagebox.showerror("错误", f"提交失败：{str(e)}")
        
        tk.Button(submit_frame, text="提交", command=submit_repair, width=15).pack(pady=10)
        
        # 我的报修记录
        list_frame = ttk.LabelFrame(frame, text="我的报修记录", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        tree = ttk.Treeview(
            list_frame,
            columns=("ID", "描述", "状态", "时间"),
            show="headings",
            height=8
        )
        tree.heading("ID", text="报修编号")
        tree.heading("描述", text="报修描述")
        tree.heading("状态", text="状态")
        tree.heading("时间", text="创建时间")
        tree.column("ID", width=150)
        tree.column("描述", width=250)
        tree.column("状态", width=80)
        tree.column("时间", width=150)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for r in self.repair_service.get_repairs_by_resident(resident_id):
                tree.insert("", tk.END, values=(r.repair_id, r.description, r.status, r.create_time))
        
        refresh_list()
        tk.Button(list_frame, text="刷新", command=refresh_list).pack(pady=5)
        
        return frame
    
    def _create_user_complaint_tab(self, resident_id: Optional[str]):
        """创建用户投诉标签页"""
        frame = ttk.Frame(self.notebook)
        
        if not resident_id:
            tk.Label(frame, text="未关联住户信息", font=("Arial", 12)).pack(pady=50)
            return frame
        
        # 提交投诉
        submit_frame = ttk.LabelFrame(frame, text="提交投诉", padding=20)
        submit_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        tk.Label(submit_frame, text="投诉内容:", font=("Arial", 11)).pack(anchor=tk.W, pady=5)
        content_text = scrolledtext.ScrolledText(submit_frame, height=8, width=50)
        content_text.pack(fill=tk.BOTH, expand=True, pady=5)
        
        def submit_complaint():
            try:
                content = content_text.get(1.0, tk.END).strip()
                if not content:
                    messagebox.showwarning("输入提示", "请输入投诉内容")
                    return
                complaint_id = f"COM{datetime.now().strftime('%Y%m%d%H%M%S')}"
                self.complaint_service.add_complaint(complaint_id, resident_id, content)
                self.storage.save(self.system)
                messagebox.showinfo("成功", "投诉已提交")
                content_text.delete(1.0, tk.END)
            except Exception as e:
                messagebox.showerror("错误", f"提交失败：{str(e)}")
        
        tk.Button(submit_frame, text="提交", command=submit_complaint, width=15).pack(pady=10)
        
        # 我的投诉记录
        list_frame = ttk.LabelFrame(frame, text="我的投诉记录", padding=10)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        tree = ttk.Treeview(
            list_frame,
            columns=("ID", "内容", "状态", "时间"),
            show="headings",
            height=8
        )
        tree.heading("ID", text="投诉编号")
        tree.heading("内容", text="投诉内容")
        tree.heading("状态", text="状态")
        tree.heading("时间", text="创建时间")
        tree.column("ID", width=150)
        tree.column("内容", width=250)
        tree.column("状态", width=80)
        tree.column("时间", width=150)
        tree.pack(fill=tk.BOTH, expand=True)
        
        def refresh_list():
            for item in tree.get_children():
                tree.delete(item)
            for c in self.complaint_service.get_complaints_by_resident(resident_id):
                tree.insert("", tk.END, values=(c.complaint_id, c.content, c.status, c.create_time))
        
        refresh_list()
        tk.Button(list_frame, text="刷新", command=refresh_list).pack(pady=5)
        
        return frame
    
    def _create_user_parking_tab(self, resident_id: Optional[str]):
        """创建用户车位信息标签页"""
        frame = ttk.Frame(self.notebook)
        
        if not resident_id:
            tk.Label(frame, text="未关联住户信息", font=("Arial", 12)).pack(pady=50)
            return frame
        
        info_frame = ttk.LabelFrame(frame, text="我的车位信息", padding=30)
        info_frame.pack(fill=tk.BOTH, expand=True, padx=50, pady=50)
        
        parking = self.parking_service.find_parking_by_resident(resident_id)
        if parking:
            tk.Label(info_frame, text=f"车位编号: {parking.space_id}", font=("Arial", 14)).pack(pady=15)
            tk.Label(info_frame, text=f"车位位置: {parking.location}", font=("Arial", 14)).pack(pady=15)
        else:
            tk.Label(info_frame, text="您暂无车位信息", font=("Arial", 14), fg="gray").pack(pady=50)
        
        return frame
    
    @ErrorHandler.handle_error
    def _save_data(self):
        """保存数据"""
        if self.storage.save(self.system):
            messagebox.showinfo("成功", "数据已保存")
        else:
            messagebox.showerror("错误", "保存失败")
    
    def _show_about(self):
        """显示关于信息"""
        messagebox.showinfo(
            "关于",
            "小区物业管理系统 v1.0\n\n"
            "功能包括：\n"
            "- 小区资料管理\n"
            "- 房型管理\n"
            "- 住户管理\n"
            "- 报修管理\n"
            "- 投诉管理\n"
            "- 停车位管理\n"
            "- 收费管理\n"
            "- 统计查询"
        )
    
    def _logout(self):
        """退出登录"""
        if messagebox.askyesno("确认", "确定要退出登录吗？"):
            self.auth.logout()
            self.storage.save(self.system)
            # 清除界面
            for widget in self.root.winfo_children():
                if isinstance(widget, tk.Menu):
                    continue
                widget.destroy()
            self._create_status_bar()
            self._update_status("未登录")
            self._show_login()
    
    def run(self):
        """运行主程序"""
        self.root.mainloop()


def main():
    """主函数"""
    try:
        app = MainWindow()
        app.run()
    except Exception as e:
        messagebox.showerror("启动错误", f"程序启动失败：{str(e)}\n\n{traceback.format_exc()}")


if __name__ == "__main__":
    main()


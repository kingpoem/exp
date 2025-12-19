"""
用户认证和权限管理
实现普通用户和超级管理员的不同权限
"""

from typing import Optional
from models import PropertyManagementSystem, User


class AuthManager:
    """认证管理器，负责用户登录和权限验证"""
    
    def __init__(self, system: PropertyManagementSystem):
        """
        初始化认证管理器
        @param system: 物业管理系统对象
        """
        self.system = system
        self.current_user: Optional[User] = None
    
    def login(self, username: str, password: str) -> bool:
        """
        用户登录
        @param username: 用户名
        @param password: 密码
        @return: 是否登录成功
        """
        for user in self.system.users:
            if user.username == username and user.password == password:
                self.current_user = user
                return True
        return False
    
    def logout(self):
        """用户登出"""
        self.current_user = None
    
    def is_logged_in(self) -> bool:
        """
        检查是否已登录
        @return: 是否已登录
        """
        return self.current_user is not None
    
    def is_admin(self) -> bool:
        """
        检查当前用户是否为超级管理员
        @return: 是否为超级管理员
        """
        return self.current_user is not None and self.current_user.role == "超级管理员"
    
    def is_normal_user(self) -> bool:
        """
        检查当前用户是否为普通用户
        @return: 是否为普通用户
        """
        return self.current_user is not None and self.current_user.role == "普通用户"
    
    def get_current_user(self) -> Optional[User]:
        """
        获取当前登录用户
        @return: 当前用户对象
        """
        return self.current_user
    
    def can_access_resident(self, resident_id: str) -> bool:
        """
        检查当前用户是否可以访问指定住户信息
        普通用户只能访问自己的信息，管理员可以访问所有信息
        @param resident_id: 住户编号
        @return: 是否有权限访问
        """
        if self.is_admin():
            return True
        if self.is_normal_user() and self.current_user.resident_id == resident_id:
            return True
        return False


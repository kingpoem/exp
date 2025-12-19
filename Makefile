.PHONY: a b1 b2 b22 b3 b4 clean

# A题：线性时间选择问题
# 执行编译、测试和报告生成的完整流程
a:
	@echo "=========================================="
	@echo "A题：线性时间选择问题"
	@echo "=========================================="
	@echo "步骤1: 编译程序..."
	@cd a && make
	@echo "步骤2: 运行测试..."
	@cd a && make test
	@echo "步骤3: 生成HTML报告..."
	@cd a && make report
	@echo ""
	@echo "✓ 所有步骤完成！"
	@echo "  文本报告: a/test_report.txt"
	@echo "  HTML报告: a/test_report.html"

# B题：小区物业管理系统 - Python + tkinter
b1:
	@echo "运行B1：Python + tkinter GUI版本..."
	cd b1 && uv run python gui_main.py

# B题：小区物业管理系统 - Dart + Flutter
b2:
	@echo "运行B2：Dart + Flutter版本..."
	cd b2 && flutter run -d chrome

# B题：小区物业管理系统 - Dart + Flutter (构建APK)
b22:
	@echo "=========================================="
	@echo "B2：构建Flutter APK安装包"
	@echo "=========================================="
	@echo "步骤1: 检查Flutter环境..."
	@cd b2 && flutter doctor
	@echo ""
	@echo "步骤2: 获取依赖..."
	@cd b2 && flutter pub get
	@echo ""
	@echo "步骤3: 构建APK..."
	@cd b2 && flutter build apk --release
	@echo ""
	@echo "✓ APK构建完成！"
	@echo "  APK位置: b2/build/app/outputs/flutter-apk/app-release.apk"

# B题：小区物业管理系统 - Rust + Bun + Tauri
b3:
	@echo "运行B3：Rust + Bun + Tauri版本..."
	cd b3 && bun run tauri dev

# B题：小区物业管理系统 - Rust + Tauri
b4:
	@echo "运行B4：Rust + Tauri版本..."
	cd b4 && cargo tauri dev

# 清理所有生成的文件
clean:
	@echo "=========================================="
	@echo "清理所有生成的文件"
	@echo "=========================================="
	@echo "清理A题生成的文件..."
	@cd a && make clean
	@echo ""
	@echo "清理B1题生成的文件..."
	@cd b1 && rm -rf __pycache__ *.pyc property_management_system.egg-info .pytest_cache .mypy_cache dist build .coverage htmlcov .tox
	@echo "  ✓ 已清理Python缓存和构建文件"
	@echo ""
	@echo "清理B2题生成的文件..."
	@cd b2 && flutter clean 2>/dev/null || true
	@cd b2 && rm -rf .dart_tool .flutter-plugins .flutter-plugins-dependencies .packages build
	@echo "  ✓ 已清理Flutter构建文件"
	@echo ""
	@echo "✓ 所有清理完成！"


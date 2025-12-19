CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2
TARGET = select
SOURCE = select.c
PYTHON = python3
REPORT_SCRIPT = generate_report.py

.PHONY: all clean test report

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

test: $(TARGET)
	@echo "运行测试..."
	./$(TARGET) > test_report.txt
	@echo "测试报告已保存到 test_report.txt"
	@cat test_report.txt

report: test_report.txt
	@echo "生成HTML测试报告..."
	@chmod +x $(REPORT_SCRIPT)
	$(PYTHON) $(REPORT_SCRIPT) test_report.txt
	@echo "HTML报告已生成: test_report.html"
	@echo "可以在浏览器中打开 test_report.html 查看详细报告"

clean:
	rm -f $(TARGET) test_report.txt test_report.html


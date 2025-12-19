#!/usr/bin/env python3
"""
测试报告生成器
将test_report.txt转换为HTML格式，提供更直观的可视化展示

只使用Python标准库，不依赖任何外部库
"""

import re
import sys
from datetime import datetime


def parse_test_report(file_path):
    """
    解析测试报告文件
    
    Args:
        file_path: 测试报告文件路径
        
    Returns:
        dict: 包含测试结果的字典
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"错误：找不到文件 {file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"错误：读取文件失败 - {e}")
        sys.exit(1)
    
    # 提取标题
    title_match = re.search(r'线性时间选择问题 - 二次取中法测试', content)
    
    # 解析测试用例
    tests = []
    # 匹配测试用例的模式：=== 测试名称 ===
    # 排除随机测试（随机测试以"随机测试"开头）
    test_pattern = r'=== (测试\d+[^=]+?) ===\n(.*?)(?=\n=== |\n随机测试|$)'
    
    for match in re.finditer(test_pattern, content, re.DOTALL):
        test_name = match.group(1)
        test_content = match.group(2)
        
        # 跳过随机测试（应该以"随机测试"开头）
        if '随机测试' in test_name:
            continue
        
        # 提取原数组
        array_match = re.search(r'原数组: (.+)', test_content)
        array_str = array_match.group(1).strip() if array_match else ""
        
        # 提取查找的k值
        k_match = re.search(r'查找第 (\d+) 小的元素', test_content)
        k_value = int(k_match.group(1)) if k_match else 0
        
        # 提取结果
        result_match = re.search(r'结果: (\d+)', test_content)
        result = int(result_match.group(1)) if result_match else None
        
        # 提取耗时
        time_match = re.search(r'耗时: ([\d.]+) 毫秒', test_content)
        time_taken = float(time_match.group(1)) if time_match else 0.0
        
        # 提取测试状态
        # 如果包含"✓ 测试通过"或"✓ 结果验证通过"，且不包含"✗"，则认为通过
        passed = ('✓ 测试通过' in test_content or '✓ 结果验证通过' in test_content) and '✗' not in test_content
        failed = '✗' in test_content
        
        # 提取期望值（如果有）
        expected_match = re.search(r'期望: (\d+)', test_content)
        expected = int(expected_match.group(1)) if expected_match else None
        
        tests.append({
            'name': test_name,
            'array': array_str,
            'k': k_value,
            'result': result,
            'time': time_taken,
            'passed': passed and not failed,
            'expected': expected
        })
    
    # 解析随机测试
    random_tests = []
    random_pattern = r'=== 随机测试 \(n=(\d+), seed=(\d+)\) ===\n(.*?)(?=\n=== |$)'
    
    for match in re.finditer(random_pattern, content, re.DOTALL):
        n = int(match.group(1))
        seed = int(match.group(2))
        test_content = match.group(3)
        
        # 提取数组预览
        array_preview_match = re.search(r'原数组（前20个）: (.+)', test_content)
        array_preview = array_preview_match.group(1).strip() if array_preview_match else ""
        
        # 提取k值测试结果
        k_results = []
        k_result_pattern = r'k=(\d+): 结果=(\d+), 耗时=([\d.]+) ms(.*?)(?=\nk=|$)'
        
        for k_match in re.finditer(k_result_pattern, test_content, re.DOTALL):
            k = int(k_match.group(1))
            result = int(k_match.group(2))
            time_taken = float(k_match.group(3))
            status = k_match.group(4).strip()
            passed = '✓' in status
            
            k_results.append({
                'k': k,
                'result': result,
                'time': time_taken,
                'passed': passed
            })
        
        random_tests.append({
            'n': n,
            'seed': seed,
            'array_preview': array_preview,
            'k_results': k_results
        })
    
    return {
        'title': '线性时间选择问题 - 二次取中法测试报告',
        'tests': tests,
        'random_tests': random_tests,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }


def generate_html(data):
    """
    生成HTML报告
    
    Args:
        data: 包含测试结果的字典
        
    Returns:
        str: HTML内容
    """
    html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{data['title']}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: #333;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            padding: 30px;
        }}
        
        h1 {{
            color: #667eea;
            margin-bottom: 10px;
            font-size: 28px;
        }}
        
        .subtitle {{
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }}
        
        .section {{
            margin-bottom: 40px;
        }}
        
        .section-title {{
            font-size: 22px;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }}
        
        .test-card {{
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            border-left: 4px solid #667eea;
            transition: transform 0.2s, box-shadow 0.2s;
        }}
        
        .test-card:hover {{
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }}
        
        .test-card.passed {{
            border-left-color: #28a745;
        }}
        
        .test-card.failed {{
            border-left-color: #dc3545;
        }}
        
        .test-name {{
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
        }}
        
        .test-info {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }}
        
        .info-item {{
            display: flex;
            flex-direction: column;
        }}
        
        .info-label {{
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}
        
        .info-value {{
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }}
        
        .array-display {{
            background: white;
            padding: 10px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            word-break: break-all;
            margin-top: 10px;
        }}
        
        .status-badge {{
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            margin-top: 10px;
        }}
        
        .status-badge.passed {{
            background: #d4edda;
            color: #155724;
        }}
        
        .status-badge.failed {{
            background: #f8d7da;
            color: #721c24;
        }}
        
        .time-badge {{
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            background: #e7f3ff;
            color: #004085;
            margin-left: 10px;
        }}
        
        .random-test-card {{
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #17a2b8;
        }}
        
        .random-test-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }}
        
        .random-test-title {{
            font-size: 18px;
            font-weight: 600;
            color: #333;
        }}
        
        .k-results {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin-top: 15px;
        }}
        
        .k-result-item {{
            background: white;
            padding: 12px;
            border-radius: 6px;
            text-align: center;
        }}
        
        .k-result-item.passed {{
            border: 2px solid #28a745;
        }}
        
        .k-result-item.failed {{
            border: 2px solid #dc3545;
        }}
        
        .k-value {{
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }}
        
        .k-result {{
            font-size: 18px;
            font-weight: 600;
            color: #333;
        }}
        
        .k-time {{
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }}
        
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        
        .stat-card {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }}
        
        .stat-value {{
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 5px;
        }}
        
        .stat-label {{
            font-size: 14px;
            opacity: 0.9;
        }}
        
        @media (max-width: 768px) {{
            .container {{
                padding: 15px;
            }}
            
            .test-info {{
                grid-template-columns: 1fr;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>{data['title']}</h1>
        <div class="subtitle">生成时间: {data['timestamp']}</div>
        
        <!-- 统计信息 -->
        <div class="section">
            <div class="stats">
"""
    
    # 计算统计信息
    total_tests = len(data['tests'])
    passed_tests = sum(1 for t in data['tests'] if t['passed'])
    failed_tests = total_tests - passed_tests
    avg_time = sum(t['time'] for t in data['tests']) / total_tests if total_tests > 0 else 0
    
    html += f"""
                <div class="stat-card">
                    <div class="stat-value">{total_tests}</div>
                    <div class="stat-label">总测试数</div>
                </div>
                <div class="stat-card" style="background: linear-gradient(135deg, #28a745 0%, #20c997 100%);">
                    <div class="stat-value">{passed_tests}</div>
                    <div class="stat-label">通过测试</div>
                </div>
                <div class="stat-card" style="background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);">
                    <div class="stat-value">{failed_tests}</div>
                    <div class="stat-label">失败测试</div>
                </div>
                <div class="stat-card" style="background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);">
                    <div class="stat-value">{avg_time:.4f}</div>
                    <div class="stat-label">平均耗时(ms)</div>
                </div>
            </div>
        </div>
        
        <!-- 基础测试用例 -->
        <div class="section">
            <h2 class="section-title">基础测试用例</h2>
"""
    
    for test in data['tests']:
        status_class = 'passed' if test['passed'] else 'failed'
        status_text = '通过' if test['passed'] else '失败'
        
        html += f"""
            <div class="test-card {status_class}">
                <div class="test-name">{test['name']}</div>
                <div class="test-info">
                    <div class="info-item">
                        <span class="info-label">查找位置</span>
                        <span class="info-value">第 {test['k']} 小</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">查找结果</span>
                        <span class="info-value">{test['result']}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">执行时间</span>
                        <span class="info-value">{test['time']:.4f} ms</span>
                    </div>
"""
        
        if test['expected'] is not None:
            html += f"""
                    <div class="info-item">
                        <span class="info-label">期望值</span>
                        <span class="info-value">{test['expected']}</span>
                    </div>
"""
        
        html += f"""
                </div>
                <div class="array-display">原数组: {test['array']}</div>
                <span class="status-badge {status_class}">{status_text}</span>
                <span class="time-badge">{test['time']:.4f} ms</span>
            </div>
"""
    
    html += """
        </div>
        
        <!-- 随机测试用例 -->
        <div class="section">
            <h2 class="section-title">随机测试用例</h2>
"""
    
    for random_test in data['random_tests']:
        html += f"""
            <div class="random-test-card">
                <div class="random-test-header">
                    <div class="random-test-title">数组大小: {random_test['n']}, 随机种子: {random_test['seed']}</div>
                </div>
                <div class="array-display">数组预览: {random_test['array_preview']}</div>
                <div class="k-results">
"""
        
        for k_result in random_test['k_results']:
            status_class = 'passed' if k_result['passed'] else 'failed'
            html += f"""
                    <div class="k-result-item {status_class}">
                        <div class="k-value">k = {k_result['k']}</div>
                        <div class="k-result">{k_result['result']}</div>
                        <div class="k-time">{k_result['time']:.4f} ms</div>
                    </div>
"""
        
        html += """
                </div>
            </div>
"""
    
    html += """
        </div>
    </div>
</body>
</html>
"""
    
    return html


def main():
    """主函数"""
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = 'test_report.txt'
    
    output_file = 'test_report.html'
    
    print(f"正在解析测试报告: {input_file}")
    data = parse_test_report(input_file)
    
    print(f"正在生成HTML报告: {output_file}")
    html = generate_html(data)
    
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f"✓ HTML报告已生成: {output_file}")
        print(f"  总测试数: {len(data['tests'])}")
        print(f"  随机测试数: {len(data['random_tests'])}")
    except Exception as e:
        print(f"错误：写入文件失败 - {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()


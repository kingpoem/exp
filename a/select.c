/**
 * 线性时间选择问题 - 使用二次取中法（Median of Medians）
 * 
 * 题目：给定线性序集中n个元素和一个整数k，1≤k≤n，
 * 要求使用二次取中法在线性时间内找出这n个元素中第k小的元素。
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

/**
 * 交换两个元素的值
 * @param a 指向第一个元素的指针
 * @param b 指向第二个元素的指针
 */
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

/**
 * 使用插入排序对数组进行排序（用于小数组）
 * 将数组分为“已排序”和“未排序”两部分，每次从未排序部分取一个数插入到已排序部分的正确位置
 * @param arr 待排序数组
 * @param left 左边界
 * @param right 右边界
 */
void insertion_sort(int arr[], int left, int right) {
    int i, j, key;
    for (i = left + 1; i <= right; i++) {
        key = arr[i];
        j = i - 1;
        while (j >= left && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
}

/**
 * 找到数组的中位数（使用插入排序）
 * @param arr 数组
 * @param left 左边界
 * @param right 右边界
 * @return 中位数的值
 */
int find_median(int arr[], int left, int right) {
    insertion_sort(arr, left, right);
    return arr[left + (right - left) / 2];
}

/**
 * 使用二次取中法找到pivot元素（Median of Medians算法）
 *
 * 算法复杂度分析：
 * - 分组：O(n) - 将数组分成n/5组
 * - 每组排序找中位数：O(n) - 每组5个元素，插入排序O(1)，共n/5组
 * - 递归找中位数的中位数：T(n/5) - 递归处理中位数数组
 * - 总复杂度：T(n) = T(n/5) + O(n) = O(n)
 * 
 * @param arr 数组
 * @param left 左边界（包含）
 * @param right 右边界（包含）
 * @return pivot元素的值，这个值能保证至少有30%的元素小于它，至少有30%的元素大于它
 */
int median_of_medians(int arr[], int left, int right) {
    int n = right - left + 1;  // 当前数组长度
    int i;
    // 分配空间存储每组的中位数，最多需要(n+4)/5个位置
    int median[(n + 4) / 5];
    
    // 第一步：将数组分成每组5个元素，找到每组的中位数
    for (i = 0; i < n / 5; i++) {
        // 处理完整的5元素组：[left+i*5, left+i*5+4]
        median[i] = find_median(arr, left + i * 5, left + i * 5 + 4);
    }
    
    // 第二步：处理剩余的元素（不足5个的情况）
    if (i * 5 < n) {
        median[i] = find_median(arr, left + i * 5, left + i * 5 + (n % 5) - 1);
        i++;  // 中位数数组长度增加
    }
    
    // 第三步：递归找到中位数的中位数
    // 如果只有一个中位数，直接返回（递归终止条件）
    if (i == 1) {
        return median[0];
    } else {
        // 递归调用，在median数组中找中位数
        return median_of_medians(median, 0, i - 1);
    }
}

/**
 * 分区函数（Partition），将数组分为小于等于pivot和大于pivot两部分
 * 算法步骤：
 * 1. 找到pivot在数组中的位置，并将其交换到数组末尾（right位置）
 * 2. 使用双指针技术进行分区：
 *    - i指针：指向小于等于pivot区域的末尾（下一个位置）
 *    - j指针：遍历数组，寻找小于等于pivot的元素
 * 3. 将pivot从末尾交换回正确位置（i位置）
 * 
 * 时间复杂度：O(n)，只需要一次遍历
 * 空间复杂度：O(1)，原地操作
 * 
 * @param arr 数组（会被修改）
 * @param left 左边界（包含）
 * @param right 右边界（包含）
 * @param pivot 基准值（pivot的值，不是索引）
 * @return pivot的最终位置（索引），分区后arr[pos] == pivot
 */
int partition(int arr[], int left, int right, int pivot) {
    int i;
    // 第一步：找到pivot在数组中的位置，并将其交换到数组末尾
    for (i = left; i < right; i++) {
        if (arr[i] == pivot) {
            swap(&arr[i], &arr[right]); 
            break;
        }
    }
    
    // 第二步：标准分区过程
    // 使用双指针技术：i指向小于等于pivot区域的末尾，j遍历数组
    i = left; 
    for (int j = left; j < right; j++) {
        // 如果当前元素小于等于pivot，将其交换到i位置，并扩展小于等于区域
        if (arr[j] <= pivot) {
            swap(&arr[i], &arr[j]);
            i++;  // 扩展小于等于pivot的区域
        }
        // 如果arr[j] > pivot，j继续前进，元素保持在大于pivot的区域
    }
    
    swap(&arr[i], &arr[right]);
    return i;
}

/**
 * 使用二次取中法（BFPRT算法）在线性时间内找到第k小的元素
 * 
 * 时间复杂度分析：
 * - 最坏情况：T(n) = T(n/5) + T(7n/10) + O(n)
 *   - T(n/5): 递归找中位数的中位数
 *   - T(7n/10): 最坏情况下，pivot至少能排除30%的元素，最多需要处理70%的元素
 *   - O(n): partition和median_of_medians的线性时间开销
 * 
 * @param arr 数组（会被修改，因为partition和排序会改变数组）
 * @param left 左边界（包含）
 * @param right 右边界（包含）
 * @param k 要查找的第k小元素的位置（从1开始，k=1表示最小值，k=n表示最大值）
 * @return 第k小的元素值
 */
int linear_select(int arr[], int left, int right, int k) {
    // 边界情况1：如果只有一个元素，直接返回，这是递归的终止条件之一
    if (left == right) {
        return arr[left];
    }
    
    // 边界情况2：如果数组较小（<=5个元素），直接使用插入排序
    if (right - left + 1 <= 5) {
        insertion_sort(arr, left, right);  // 排序后，第k小的元素就在arr[left+k-1]
        return arr[left + k - 1];
    }
    
    // 核心步骤1：使用二次取中法找到一个好的pivot
    int pivot = median_of_medians(arr, left, right);
    
    // 核心步骤2：使用pivot对数组进行分区，pos为pivot在数组中的绝对位置
    int pos = partition(arr, left, right, pivot);
    
    // 核心步骤3：计算pivot在当前数组中的排名（从1开始）
    // 例如：如果pos=5, left=0，则pivot是第6小的元素（排名为6）
    int current_rank = pos - left + 1;
    
    // 核心步骤4：根据k与current_rank的关系决定下一步操作
    if (k == current_rank) {
        // 情况1：k正好等于pivot的排名，pivot就是我们要找的元素
        return arr[pos];
    } else if (k < current_rank) {
        // 情况2：k小于pivot的排名，说明第k小的元素在左半部分
        return linear_select(arr, left, pos - 1, k);
    } else {
        // 情况3：k大于pivot的排名，说明第k小的元素在右半部分
        // k需要减去current_rank，因为左半部分和pivot本身已经排除了current_rank个元素
        return linear_select(arr, pos + 1, right, k - current_rank);
    }
}

/**
 * 打印数组
 * @param arr 数组
 * @param n 数组长度
 */
void print_array(int arr[], int n) {
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

/**
 * 测试函数
 * @param test_name 测试名称
 * @param arr 测试数组
 * @param n 数组长度
 * @param k 要查找的第k小元素
 * @param expected 期望的结果（如果为-1则不验证）
 */
void run_test(const char *test_name, int arr[], int n, int k, int expected) {
    // 创建数组副本，因为算法会修改数组
    int *arr_copy = (int *)malloc(n * sizeof(int));
    memcpy(arr_copy, arr, n * sizeof(int));
    
    printf("\n=== %s ===\n", test_name);
    printf("原数组: ");
    print_array(arr, n);
    printf("查找第 %d 小的元素\n", k);
    
    clock_t start = clock();
    int result = linear_select(arr_copy, 0, n - 1, k);
    clock_t end = clock();
    
    double time_taken = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    
    printf("结果: %d\n", result);
    printf("耗时: %.4f 毫秒\n", time_taken);
    
    if (expected != -1) {
        if (result == expected) {
            printf("✓ 测试通过\n");
        } else {
            printf("✗ 测试失败，期望: %d, 实际: %d\n", expected, result);
        }
    }
    
    // 验证结果：排序后检查
    insertion_sort(arr_copy, 0, n - 1);
    if (arr_copy[k - 1] == result) {
        printf("✓ 结果验证通过\n");
    } else {
        printf("✗ 结果验证失败\n");
    }
    
    free(arr_copy);
}

/**
 * 生成随机测试用例
 * @param n 数组大小
 * @param seed 随机种子
 */
void generate_random_test(int n, int seed) {
    srand(seed);
    int *arr = (int *)malloc(n * sizeof(int));
    
    printf("\n=== 随机测试 (n=%d, seed=%d) ===\n", n, seed);
    for (int i = 0; i < n; i++) {
        arr[i] = rand() % 1000;
    }
    
    printf("原数组（前20个）: ");
    int print_count = n < 20 ? n : 20;
    for (int i = 0; i < print_count; i++) {
        printf("%d ", arr[i]);
    }
    if (n > 20) printf("...");
    printf("\n");
    
    // 测试多个k值：最小值、1/4分位、中位数、3/4分位、最大值
    int test_k[] = {1, n / 4, n / 2, 3 * n / 4, n};
    int test_count = sizeof(test_k) / sizeof(test_k[0]);
    
    for (int i = 0; i < test_count; i++) {
        int k = test_k[i];
        if (k < 1 || k > n) continue;
        
        int *arr_copy = (int *)malloc(n * sizeof(int));
        memcpy(arr_copy, arr, n * sizeof(int));
        
        clock_t start = clock();
        int result = linear_select(arr_copy, 0, n - 1, k);
        clock_t end = clock();
        double time_taken = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
        
        // 验证：通过排序验证结果正确性
        insertion_sort(arr_copy, 0, n - 1);
        int expected = arr_copy[k - 1];
        
        printf("k=%d: 结果=%d, 耗时=%.4f ms", k, result, time_taken);
        if (result == expected) {
            printf(" ✓\n");
        } else {
            printf(" ✗ (期望: %d)\n", expected);
        }
        
        free(arr_copy);
    }
    
    free(arr);
}

/**
 * 生成特殊分布的测试用例
 * @param n 数组大小
 * @param type 测试类型：1=大量重复, 2=递增, 3=递减, 4=双峰分布
 */
void generate_special_test(int n, int type) {
    int *arr = (int *)malloc(n * sizeof(int));
    const char *type_names[] = {"", "大量重复元素", "递增序列", "递减序列", "双峰分布"};
    
    printf("\n=== 特殊分布测试: %s (n=%d) ===\n", type_names[type], n);
    
    switch (type) {
        case 1:  // 大量重复元素
            // 生成只有几个不同值的数组，测试重复元素处理
            for (int i = 0; i < n; i++) {
                arr[i] = (i % 10) * 100;  // 只有10个不同的值：0, 100, 200, ..., 900
            }
            // 打乱顺序
            srand(99999);
            for (int i = n - 1; i > 0; i--) {
                int j = rand() % (i + 1);
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
            break;
            
        case 2:  // 递增序列
            for (int i = 0; i < n; i++) {
                arr[i] = i + 1;
            }
            break;
            
        case 3:  // 递减序列
            for (int i = 0; i < n; i++) {
                arr[i] = n - i;
            }
            break;
            
        case 4:  // 双峰分布：前半部分小值，后半部分大值
            for (int i = 0; i < n / 2; i++) {
                arr[i] = i + 1;  // 1 到 n/2
            }
            for (int i = n / 2; i < n; i++) {
                arr[i] = (i - n / 2) + 1000;  // 1000 到 1000+n/2
            }
            // 打乱顺序
            srand(88888);
            for (int i = n - 1; i > 0; i--) {
                int j = rand() % (i + 1);
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
            break;
    }
    
    printf("原数组（前20个）: ");
    int print_count = n < 20 ? n : 20;
    for (int i = 0; i < print_count; i++) {
        printf("%d ", arr[i]);
    }
    if (n > 20) printf("...");
    printf("\n");
    
    // 测试多个k值，包括边界值
    int test_k[] = {1, 2, n / 4, n / 2, 3 * n / 4, n - 1, n};
    int test_count = sizeof(test_k) / sizeof(test_k[0]);
    
    for (int i = 0; i < test_count; i++) {
        int k = test_k[i];
        if (k < 1 || k > n) continue;
        
        int *arr_copy = (int *)malloc(n * sizeof(int));
        memcpy(arr_copy, arr, n * sizeof(int));
        
        clock_t start = clock();
        int result = linear_select(arr_copy, 0, n - 1, k);
        clock_t end = clock();
        double time_taken = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
        
        // 验证
        insertion_sort(arr_copy, 0, n - 1);
        int expected = arr_copy[k - 1];
        
        printf("k=%d: 结果=%d, 耗时=%.4f ms", k, result, time_taken);
        if (result == expected) {
            printf(" ✓\n");
        } else {
            printf(" ✗ (期望: %d)\n", expected);
        }
        
        free(arr_copy);
    }
    
    free(arr);
}

int main() {
    printf("========================================\n");
    printf("线性时间选择问题 - 二次取中法测试\n");
    printf("========================================\n");
    
    // 测试1: 基本测试
    // 数组: {3, 1, 4, 1, 5, 9, 2, 6, 5, 3}
    // 排序后: {1, 1, 2, 3, 3, 4, 5, 5, 6, 9}
    // 第5小的元素是3（索引4，因为k从1开始）
    int arr1[] = {3, 1, 4, 1, 5, 9, 2, 6, 5, 3};
    run_test("测试1: 基本数组", arr1, 10, 5, 3);
    
    // 测试2: 已排序数组
    int arr2[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    run_test("测试2: 已排序数组", arr2, 10, 3, 3);
    
    // 测试3: 逆序数组
    int arr3[] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    run_test("测试3: 逆序数组", arr3, 10, 7, 7);
    
    // 测试4: 重复元素
    int arr4[] = {5, 5, 5, 5, 5, 5, 5, 5};
    run_test("测试4: 重复元素", arr4, 8, 4, 5);
    
    // 测试5: 单个元素
    int arr5[] = {42};
    run_test("测试5: 单个元素", arr5, 1, 1, 42);
    
    // 测试6: 两个元素
    int arr6[] = {2, 1};
    run_test("测试6: 两个元素", arr6, 2, 1, 1);
    
    // 测试7: 查找最小元素
    int arr7[] = {9, 3, 7, 1, 5, 8, 2, 6, 4};
    run_test("测试7: 查找最小元素", arr7, 9, 1, 1);
    
    // 测试8: 查找最大元素
    int arr8[] = {9, 3, 7, 1, 5, 8, 2, 6, 4};
    run_test("测试8: 查找最大元素", arr8, 9, 9, 9);
    
    // 测试9: 中等大小数组
    // 数组为逆序：[50, 49, 48, ..., 2, 1]
    // 排序后：[1, 2, 3, ..., 25, 26, ..., 49, 50]
    // 第25小的元素是25（索引24，因为k从1开始）
    int arr9[50];
    for (int i = 0; i < 50; i++) {
        arr9[i] = 50 - i;
    }
    run_test("测试9: 中等大小数组(50个元素)", arr9, 50, 25, 25);
    
    // 测试10: 全相同元素
    int arr10[100];
    for (int i = 0; i < 100; i++) {
        arr10[i] = 42;
    }
    run_test("测试10: 全相同元素(100个)", arr10, 100, 50, 42);
    
    // 测试11: 锯齿形数组（先增后减）
    int arr11[30];
    for (int i = 0; i < 15; i++) {
        arr11[i] = i + 1;
    }
    for (int i = 15; i < 30; i++) {
        arr11[i] = 30 - i;
    }
    // 数组: [1,2,...,15,15,14,...,1]，排序后中位数约为8
    run_test("测试11: 锯齿形数组(30个元素)", arr11, 30, 15, -1);
    
    // 测试12: 大范围数值（包含负数）
    int arr12[] = {100, -50, 200, -100, 0, 150, -25, 75, -75, 25};
    run_test("测试12: 包含负数", arr12, 10, 5, -1);
    
    // 测试13: 大数组 - 已排序
    int arr13[200];
    for (int i = 0; i < 200; i++) {
        arr13[i] = i + 1;
    }
    run_test("测试13: 大数组已排序(200个元素)", arr13, 200, 100, 100);
    
    // 测试14: 大数组 - 逆序
    // 数组: [200, 199, ..., 2, 1]
    // 排序后: [1, 2, ..., 199, 200]
    // 第100小的元素是100
    int arr14[200];
    for (int i = 0; i < 200; i++) {
        arr14[i] = 200 - i;
    }
    run_test("测试14: 大数组逆序(200个元素)", arr14, 200, 100, 100);
    
    // 测试15: 查找中位数（k = n/2）
    int arr15[100];
    for (int i = 0; i < 100; i++) {
        arr15[i] = (i * 7 + 13) % 1000;  // 伪随机分布
    }
    run_test("测试15: 查找中位数(100个元素)", arr15, 100, 50, -1);
    
    // 测试16: 查找接近边界的值（k = 2）
    int arr16[500];
    for (int i = 0; i < 500; i++) {
        arr16[i] = 500 - i;
    }
    run_test("测试16: 查找第2小(500个元素)", arr16, 500, 2, 2);
    
    // 测试17: 查找接近边界的值（k = n-1）
    int arr17[500];
    for (int i = 0; i < 500; i++) {
        arr17[i] = i + 1;
    }
    run_test("测试17: 查找第n-1小(500个元素)", arr17, 500, 499, 499);
    
    // 随机测试
    printf("\n\n========================================\n");
    printf("随机测试用例\n");
    printf("========================================\n");
    
    generate_random_test(100, 12345);
    generate_random_test(500, 23456);
    generate_random_test(1000, 34567);
    generate_random_test(5000, 45678);
    generate_random_test(10000, 56789);
    
    // 大数据量测试
    printf("\n\n========================================\n");
    printf("大数据量测试用例\n");
    printf("========================================\n");
    
    generate_random_test(20000, 67890);
    generate_random_test(50000, 78901);
    generate_random_test(100000, 89012);
    
    // 特殊分布测试
    printf("\n\n========================================\n");
    printf("特殊分布测试用例\n");
    printf("========================================\n");
    
    // 测试18: 大量重复元素
    generate_special_test(1000, 1);  // 类型1：大量重复
    
    // 测试19: 递增序列
    generate_special_test(5000, 2);  // 类型2：递增
    
    // 测试20: 递减序列
    generate_special_test(5000, 3);  // 类型3：递减
    
    // 测试21: 双峰分布
    generate_special_test(2000, 4);  // 类型4：双峰
    
    printf("\n\n========================================\n");
    printf("所有测试完成！\n");
    printf("========================================\n");
    
    return 0;
}


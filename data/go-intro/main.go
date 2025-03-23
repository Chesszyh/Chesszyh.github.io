// main.go - Go语言综合示例
package main

import (
	"errors"
	"fmt"
	"log"
	"math/rand"
	"os"
	"sync"
	"time"
)

// 自定义类型
type Task struct {
	ID        int
	Name      string
	Completed bool
}

// 为Task类型定义方法
func (t *Task) Complete() {
	t.Completed = true
}

func (t Task) String() string {
	status := "未完成"
	if t.Completed {
		status = "已完成"
	}
	return fmt.Sprintf("任务 #%d: %s [%s]", t.ID, t.Name, status)
}

// 接口定义
type Storer interface {
	Save(filename string) error
	Load(filename string) error
}

// TaskManager实现Storer接口
type TaskManager struct {
	tasks  []Task
	nextID int
	mu     sync.Mutex // 互斥锁用于并发安全
}

// 添加任务
func (tm *TaskManager) AddTask(name string) Task {
	tm.mu.Lock()
	defer tm.mu.Unlock()

	task := Task{
		ID:        tm.nextID,
		Name:      name,
		Completed: false,
	}
	tm.tasks = append(tm.tasks, task)
	tm.nextID++
	return task
}

// 获取所有任务
func (tm *TaskManager) GetAllTasks() []Task {
	tm.mu.Lock()
	defer tm.mu.Unlock()
	
	// 创建副本以避免外部修改
	result := make([]Task, len(tm.tasks))
	copy(result, tm.tasks)
	return result
}

// 完成任务
func (tm *TaskManager) CompleteTask(id int) error {
	tm.mu.Lock()
	defer tm.mu.Unlock()

	for i := range tm.tasks {
		if tm.tasks[i].ID == id {
			tm.tasks[i].Complete()
			return nil
		}
	}
	return errors.New("任务未找到")
}

// 实现Storer接口的Save方法
func (tm *TaskManager) Save(filename string) error {
	tm.mu.Lock()
	defer tm.mu.Unlock()

	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	// 简单起见，这里只是将任务文本写入文件
	for _, task := range tm.tasks {
		_, err := fmt.Fprintln(file, task.String())
		if err != nil {
			return err
		}
	}
	return nil
}

// 实现Storer接口的Load方法
func (tm *TaskManager) Load(filename string) error {
	// 在实际应用中，这里应该实现从文件加载任务
	// 为了示例简单，这里只返回未实现错误
	return errors.New("加载功能未实现")
}

// 使用goroutine和channel的并发示例
func simulateWork(taskName string, duration time.Duration, results chan<- string) {
	fmt.Printf("开始处理任务: %s\n", taskName)
	time.Sleep(duration) // 模拟工作耗时
	results <- fmt.Sprintf("任务 '%s' 已完成，耗时 %.2f 秒", taskName, duration.Seconds())
}

func concurrencyDemo() {
	fmt.Println("\n=== 并发示例 ===")
	
	// 创建一个带缓冲的channel
	results := make(chan string, 3)

	// 启动三个goroutine并行工作
	go simulateWork("数据处理", time.Duration(rand.Intn(3)+1)*time.Second, results)
	go simulateWork("文件上传", time.Duration(rand.Intn(3)+1)*time.Second, results)
	go simulateWork("发送通知", time.Duration(rand.Intn(3)+1)*time.Second, results)

	// 等待并收集所有任务的结果
	for i := 0; i < 3; i++ {
		fmt.Println(<-results)
	}
}

// 错误处理示例
func errorHandlingDemo() {
	fmt.Println("\n=== 错误处理示例 ===")
	
	// 尝试打开不存在的文件
	_, err := os.Open("不存在的文件.txt")
	if err != nil {
		fmt.Println("常规错误处理:", err)
	}

	// 使用defer确保资源释放
	func() {
		fmt.Println("使用defer进行清理...")
		defer fmt.Println("defer: 该语句会在函数结束时执行")
		fmt.Println("函数主体执行完毕")
	}()

	// panic和recover
	func() {
		defer func() {
			if r := recover(); r != nil {
				fmt.Println("已恢复的panic:", r)
			}
		}()
		fmt.Println("即将引发panic...")
		panic("这是一个示例panic")
		// 此行代码不会执行
	}()
}

// 展示Go的基本语法和特性
func syntaxDemo() {
	fmt.Println("\n=== 语法特性示例 ===")
	
	// 变量声明
	var a int = 10
	b := 20 // 短变量声明
	
	// 常量
	const Pi = 3.14159
	
	fmt.Println("变量和常量:", a, b, Pi)
	
	// 基本数据类型
	var (
		integer int     = 42
		float   float64 = 3.14
		str     string  = "Go语言"
		boolean bool    = true
	)
	fmt.Printf("基本类型: %d, %.2f, %s, %t\n", integer, float, str, boolean)
	
	// 数组
	numbers := [5]int{1, 2, 3, 4, 5}
	fmt.Println("数组:", numbers)
	
	// 切片
	slice := numbers[1:4] // 包含索引1到3的元素
	fmt.Println("切片:", slice)
	
	dynamicSlice := make([]string, 0, 5) // 长度0，容量5
	dynamicSlice = append(dynamicSlice, "Go", "是", "一门", "强大的", "语言")
	fmt.Println("动态切片:", dynamicSlice)
	
	// 映射(Map)
	dict := map[string]int{
		"一": 1,
		"二": 2,
		"三": 3,
	}
	fmt.Println("映射:", dict)
	
	// 判断键是否存在
	if val, exists := dict["四"]; exists {
		fmt.Println("四的值:", val)
	} else {
		fmt.Println("键'四'不存在")
	}
	
	// 控制结构
	// if语句
	if x := rand.Intn(10); x < 5 {
		fmt.Println("生成的随机数小于5:", x)
	} else {
		fmt.Println("生成的随机数大于等于5:", x)
	}
	
	// for循环的三种形式
	fmt.Println("for循环示例:")
	
	// 1. 类似C的for循环
	for i := 0; i < 3; i++ {
		fmt.Printf("%d ", i)
	}
	fmt.Println()
	
	// 2. 类似while的for循环
	count := 0
	for count < 3 {
		fmt.Printf("%d ", count)
		count++
	}
	fmt.Println()
	
	// 3. 迭代切片、数组、映射等
	for index, value := range dynamicSlice[:3] {
		fmt.Printf("索引:%d 值:%s, ", index, value)
	}
	fmt.Println()
	
	// switch语句
	dayOfWeek := time.Now().Weekday()
	switch dayOfWeek {
	case time.Saturday, time.Sunday:
		fmt.Println("今天是周末")
	default:
		fmt.Println("今天是工作日")
	}
}

// 示例初始化函数，在main之前执行
func init() {
	fmt.Println("init函数: 在main函数之前执行")
	rand.Seed(time.Now().UnixNano()) // 初始化随机数生成器
}

// 主函数
func main() {
	fmt.Println("=== Go语言综合示例 ===")
	
	// 基本语法示例
	syntaxDemo()
	
	// 任务管理器示例
	tm := TaskManager{nextID: 1}
	
	fmt.Println("\n=== 任务管理器示例 ===")
	
	// 添加几个任务
	tm.AddTask("学习Go基础语法")
	tm.AddTask("理解Go的并发模型")
	tm.AddTask("实现一个小项目")
	
	// 完成一个任务
	err := tm.CompleteTask(1)
	if err != nil {
		log.Printf("完成任务时出错: %v", err)
	}
	
	// 打印所有任务
	fmt.Println("所有任务:")
	for _, task := range tm.GetAllTasks() {
		fmt.Println(task)
	}
	
	// 尝试保存任务到文件
	err = tm.Save("tasks.txt")
	if err != nil {
		log.Printf("保存任务时出错: %v", err)
	} else {
		fmt.Println("任务已保存到tasks.txt文件")
	}
	
	// 错误处理示例
	errorHandlingDemo()
	
	// 并发示例
	concurrencyDemo()
	
	fmt.Println("\n=== 示例结束 ===")
}
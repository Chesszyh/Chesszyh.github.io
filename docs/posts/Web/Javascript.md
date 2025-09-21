# JavaScript

- [MDN-JavaScript](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Guide)

- `(function(){"use strict"; <code> })();`： 立即执行函数，防止变量污染全局作用域

- Hashbang： `#!/`，在代码被 JavaScript 引擎（比如 V8，用于把 JavaScript 代码编译为高效的机器码并执行）真正执行之前，宿主环境（如 Node.js）会先对源码做一些预处理，比如把 hashbang（#! 开头的那一行）去掉、剥离BOM，然后再把剩下的代码交给 JS 引擎去解析和运行。

## 语法与数据类型

- 变量
    - **变量提升**： 变量声明提升到作用域顶部，变量赋值不提升，声明前访问被赋值变量值为 `undefined`，未声明变量访问报错
    - `var`： 函数作用域，局部/全局变量，允许重复声明，变量提升
    - `let`： 块级作用域(`{}`)，局部变量，不允许重复声明，不存在变量提升
    - `const`： 块级作用域(`{}`)，常量，不允许重复声明，不存在变量提升，必须初始化
        - 不可重复赋值，但可以修改引用类型的属性；常量数组元素也不受保护

- 数字和字符串

```js
"37" + 7; // "377"
"37" - 7; // 30
"37" * 7; // 259
parseInt("101", 2); // 5
"1.1" + "1.1" = "1.11.1"
(+"1.1") + (+"1.1") = 2.2
```

- 字面量
    - 数组
        - 允许空槽，`[1, ,3]`，长度为3，索引1为空槽(`undefined`)，`[1,,3].map(x => 2*x)` 结果为 `[2, ,6]`
        - 写时推荐使用 `undefined` 代替空槽，或者用`/* 空 */`占位
        - 数组的**尾后逗号**在多行数组中能保持 git diff 整洁，建议使用
    - 布尔
    - 数字
    - 对象
        - 属性名可以是数字或字符串，可以嵌套对象
        - 属性的名字不合法，那么便不能用点（.）访问属性值，需要用中括号（[]）访问
    - RegExp
    - 字符串
    - 模板字符串（Template String）
        - 反引号（`` ` ``）包裹的字符串，可以包含占位符`${expression}`，支持多行字符串
        - NOTE JS Template string

```js
const obj = {
  // __proto__
  __proto__: theProtoObj,
  // “handler: handler”的简写
  handler,
  // 方法
  toString() {
    // Super 调用
    return "d " + super.toString();
  },
  // 计算（动态的）属性名
  ["prop_" + (() => 42)()]: 42,
};
```

## 控制流与错误处理

- 块语句： `{ statement1; statement2; ... }`
    - 用 var 声明的变量不是块级作用域的，而是函数作用域或脚本作用域的
- 条件语句(基本与C++相同)
    - `if (condition) { ... } else { ... }`
    - `switch (expression) { case n: ... break; default: ... }`
    - `false`: `false`, `0`, `-0`, `0n`, `""`, `null`, `undefined`, `NaN`
- try...catch
    - `try { ... } catch (err) { ... } finally { ... }`
    - `catch` 块可选，但必须与 `finally` 一起使用
    - `finally` 块可选，无论是否抛出异常都会执行，`finally` return 会覆盖 `try` 或 `catch` 中的 return
    - 使用：`console.error(err.message);` 打印错误信息

## 循环与迭代

- label：类似`goto`
- `for...in`/`for...of`：for...in 循环遍历的结果是数组元素的下标(对象的所有可枚举属性)，而 for...of 遍历的结果是**可迭代对象**的元素的值，不包含自定义属性

## 函数

- 通过`function`或者函数表达式定义
    - 函数可以作为参数，具名的函数表达式比较方便调试
    - 可以根据条件来定义函数
- 普通参数按值传递，修改参数不会影响外部
- 对象参数按引用传递（比如数组），修改参数会影响外部
- **函数提升**：函数声明提升到作用域顶部，函数表达式不提升

- 嵌套函数：
    - 内部函数只能通过外部函数访问，包含外部函数的作用域；外部函数不能访问内部函数的参数和变量
    - 内存管理：每一次对外部函数的调用都会创建一个新的内部函数，只有当返回的内部函数不再被引用时，才会被回收

- 闭包：
    - 感觉类似cpp的类：外部函数（类）定义变量，为局部变量，局部变量在函数执行结束后依然存在（没有被销毁），并且只对内部函数(成员函数)可见。

- 使用 `arguments` 对象
    - 类似`main(argc, argv)`中的`argv`，包含传递给函数的所有参数，下标从0开始

- 函数参数
    - 默认参数
    - 剩余参数：`function(...args) { }`
        - 允许将不确定数量的参数表示为数组

- 箭头（胖箭头，`=>`）函数
    - 匿名，没有`this`, `arguments`, `super`, `new.target`
        - 普通函数的`this`：构造函数中是一个新的对象；在严格模式下是 undefined；在作为“对象方法”调用的函数中指向这个对象
        - 箭头函数：使用封闭执行上下文的 `this` 值

- 预定义函数
    - `eval()`：将字符串作为 JavaScript 代码执行
    - `isFinite()`: 检测有限数
    - `isNaN()`: 检测非数字
    - `parseFloat()`: 解析字符串并返回浮点数
    - `parseInt()`: 解析字符串并返回整数
    - `decodeURI()`: 解码 URI
    - `decodeURIComponent()`: 解码 URI 组件
    - `encodeURI()`
    - `encodeURIComponent()`

## 表达式与运算符

### 运算符

- 相等/不相等：
    - `==`： 相等，类型转换后比较
    - `===`： 全等，类型和值都相等
    - `!=`： 不相等，类型转换后比较
    - `!==`： 不全等，类型或值不相等
- 短路运算
- 一元操作符
    - `DELETE`：删除对象的属性，删除后属性为`undefined`，属性的索引失效，操作符返回布尔值`true`(可删除，并删除成功)
    - `TYPEOF`：返回变量的类型
    - `VOID`：计算表达式但不返回值，可用于超链接文本
    - `IN`： 检测对象是否包含指定属性，返回布尔值
        ```js
        var trees = new Array("redwood", "bay", "cedar", "oak", "maple");
        0 in trees; // returns true
        3 in trees; // returns true
        6 in trees; // returns false
        "bay" in trees; // returns false (you must specify the index number,
        // not the value at that index)
        "length" in trees; // returns true (length is an Array property)
        ```
    - `INSTANCEOF`：检测对象是否是某个类的实例，返回布尔值

- [优先级、结合性](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/Operator_precedence)

### 表达式

- 基本表达式
    - `this`：指代方法中正在被调用的对象
    - 

--> https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Guide/Expressions_and_operators#%E8%A1%A8%E8%BE%BE%E5%BC%8F
# Vue

- [Vue.js 官方文档](https://cn.vuejs.org/guide/introduction.html)

## 简介

- Vue支持单文件组件
- API
    - 选项式: 把组件的逻辑分门别类地写在不同的“选项”里，像填表一样
    - 组合式: 用函数（如 ref、reactive、computed 等）直接在 setup() 里声明和组合响应式变量与逻辑
- ES 模块
    - [JavaScript模块](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Guide/Modules)
    - `mjs`：Module JavaScript
    - 通常在`package.json`中配置，或者用`<script type="module">`标签来引入模块，而不是用`mjs`后缀标识，因为部分服务器不支持`mjs`后缀
    - 用于在不同文件之间导入和导出代码，`import` 和 `export` 必须写在模块的顶层作用域
    - `<script type="importmap">`：导入映射表
    - 不能通过 `file://` 协议工作，只能通过 HTTP(S) 协议工作

## 创建应用

Vue 使用 `createApp` 函数创建一个应用实例，传入根组件选项对象作为参数，然后调用 `mount` 方法将应用挂载到一个 DOM 元素上。

根组件（Root Component）是 Vue 应用的入口组件，所有其他组件都是它的子组件。根组件的模板（template）通常有两种来源：

1. 直接在组件选项对象中定义 `template` 属性，包含 HTML 字符串
2. 如果没有在根组件里写 template，Vue 会自动把挂载容器的内容作为模板

`createApp` 允许在同一个页面上创建多个 Vue 应用，每个应用都有独立作用域和生命周期。

## 模板语法

Vue 默认推荐用模板语法（template）来描述界面，模板编译时自动优化，比如只更新必要的DOM节点。

### 文本插值

使用双大括号(“Mustache”语法) `{{ }}` 语法插入变量或表达式的值

```html
<span>{{ message }}</span>
```

插入html内容，使用 `v-html` 指令

```html
<div v-html="rawHtml"></div>
```

不能用 v-html 来动态拼接或组合多个模板片段，然后让 Vue 把它们当作组件模板来解析和渲染。比如`<div v-html="html1 + html2"></div>`。

```js
data() {
  return {
    html1: '<div>部分1</div>',
    html2: '<div>部分2</div>'
  }
}
```

### attribute 绑定

使用`v-bind`指令绑定 HTML 属性

```html
<div v-bind:id="dynamicId"></div>
<div :id="dynamicId"></div> <!-- 可以省略v-bind -->
<div :id> </div> <!-- 如果属性名和JavaScript变量名相同，可以省略变量名(属性值) -->
<div v-bind="objectOfAttrs"></div> <!-- 通过不带参数的 v-bind，绑定多个属性 -->
```

### 使用js表达式

只支持能够写在`return`后面的单一表达式。

绑定在表达式中的方法在组件每次更新时都会被重新调用，因此应该是“纯函数”，只做数据计算和格式化，不应该产生任何副作用，比如改变数据或触发异步操作（否则可能内存泄漏等）。

模板中的表达式将被沙盒化。

### 指令参数

通过`v-command:argument`的形式传递参数。`v-bind:`可简写为`:`，`v-on:`可简写为`@`。参数可以使用js表达式，成为动态参数。

动态参数中表达式的值应当是一个字符串，或者是 `null`。字符串有一些语法限制，比如空格和引号.

完整的指令语法：![alt text](./images/指令语法.png)

## 响应式

### 状态声明

#### `ref`

初始化时自动推导类型，返回带有`.value`属性的响应式引用对象。

```js
import { ref } from 'vue'
const year = ref(2020)
year.value = '2025' // string it not assignable to number

// 1. 使用`Ref`类型注解
import type { Ref } from 'vue' 
const year: Ref<string | number> = ref('2020')

// 2. 初始化时传入泛型参数
const year = ref<string | number>('2020')
const year_wo_init = ref<number>() // 得到包含undefined的联合类型
```

--> https://cn.vuejs.org/guide/essentials/reactivity-fundamentals.html#declaring-reactive-state-1

[xss](https://zh.wikipedia.org/wiki/%E8%B7%A8%E7%B6%B2%E7%AB%99%E6%8C%87%E4%BB%A4%E7%A2%BC)


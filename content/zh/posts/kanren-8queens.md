---
title: 'Kanren 8queens'
date: 2025-04-20T13:22:36+08:00
draft: false
categories: ["Python", "Algothrim"] 
tags: ["Kanren", "8queens", "Logic Programming"]
---

<!-- 文章内容开始 -->
# Kanren Python Library & 8-Queens Problem

Source: 同济大学“人工智能原理与技术课”大作业1：`逻辑推理模块：八皇后问题`，要求使用一个老古董仓库`kanren`实现8皇后解法，还要写实验报告。

byd实验报告要求太多，跟八股文一样，我直接Gemini Deep Research解决。(不得不说Deep Research是真的很强，能联网搜索之后总结出逻辑完备的长文档，但仍然免除不了幻觉问题。)

写这篇博客就自由多了，没那么多byd要求，可以按照自己思路自由发挥。

Kanren基本都是我自己写的，后面8queens部分参考Gemini。

## Kanren库

[Kanren](https://github.com/logpy/logpy)：Python逻辑编程库，允许用户定义逻辑变量、关系（事实和规则）以及目标（goals），并通过其核心引擎（基于 unification）来搜索满足这些目标的变量绑定（bindings）。

### 环境配置

```bash
conda create -n kanren-learn python=3.6 # 更高版本python可能有问题
conda activate kanren-learn
pip install kanren
```

### 逻辑编程

Kanren体现的思想，是**声明式编程（Declarative Programming）**中的子范式：**逻辑式编程（Logic Programming）**的典型示例。与**命令式编程（Imperative Programming）**，即通过明确的指令告诉计算机如何一步步完成任务、比如使用函数或过程来组织代码（如 C）的**过程式编程（Procedural Programming）**不同，**逻辑式编程**只告诉计算机要“**做什么**”、“**满足什么**”，而不是“怎么做”。

以`8-Queens`问题为例，我们不需要编写详细的回溯搜索算法步骤，也不需要手动管理状态或检查冲突。相反，我们只是声明了一个有效的八皇后解 必须满足 的条件（约束）。kanren 库负责解释这些声明，并运用其内置的**合一**和**搜索**机制来找到满足所有条件的解。

### Kanren基础

- **逻辑变量(Var)**：在逻辑编程中，变量代表未知的量。kanren 使用 `var()` 函数创建逻辑变量。逻辑变量是**符号占位符**，其值在求解过程中通过满足**约束（目标）**来确定。例如，`x = var()` 创建一个名为 x 的逻辑变量。
- **目标 (Goal)**: 目标是需要被满足的**逻辑条件或谓词**。在 kanren 中，目标通常是接受一个“**替换**”状态（substitution）并返回一个满足该目标的新的替换状态流（stream）的函数。目标执行过程就是对替换进行**操作和生成**的过程。
    - 基本目标：`eq(u, v)`：当其参数 u 和 v 可以被合一（unify）时成功。
    - **合一**：就是“想办法让u和v变得一样（如果可能的话），并在这个过程中确定变量值”的过程。
    - **目标构造器**：
        - `lall(*goals)`: 多目标的逻辑与(AND)，会依次执行子目标，将一个目标产生的成功替换传递给下一个目标。
        - `lany(*goals)`: 多目标的逻辑或(OR)
        - `conde(*goal_sequences)`: 多目标的逻辑或(OR)，如`conde((A, B), (C, D))`表示 (A AND B) OR (C AND D)
- **流 (Stream)**: 目标可以产生零个、一个或多个满足条件的替换。kanren 使用惰性求值的迭代器（生成器）来表示这些可能的解（替换）流。

- `run(n, x, *goals):` 执行逻辑程序并获取结果的主要接口函数。
    - n: 指定需要查找的解的数量（1 表示查找一个，0 表示查找所有，None 表示返回一个惰性序列）。
    - x: 输出变量或表达式，run 将返回这个变量在成功替换中的具体绑定值。
    - `*goals`: 一个或多个需要同时满足的目标（隐式地使用 lall 连接）。

**示例代码**：

```python
from kanren import run, eq, var, membero

# run 单条件约束
x = var()
print(run(0, x, eq(x, 1))) # 输出：(1,)
# 解释：eq 合一成功，kanren 找到了一个替换，即 x 必须是 1。因为我们查询的是 x 的值，所以 run 返回包含这个解的元组 (1,)。

y = var()
print(run(0, y, eq(2, 2))) # 输出：(~_2,)
# 解释：eq目标恒成立，因此不需要给逻辑变量 y 赋任何具体的值。即 y 在 run 的执行过程中始终没有被绑定。
# 由于 y 没有被绑定到具体值，run 就返回了 y 对应的内部逻辑变量表示（通常是 ~_ 加上一个数字，这里是 2）。

z = var()
print(run(0, z, eq(3, 4))) # 输出：()
# 解释：eq 目标不成立，因此没有任何替换可以满足这个条件。run 返回空流，表示没有解。

w = var()
print(run(0, w, eq(x, y))) # 输出：(~_4,)
# 解释：eq 目标要求 x 和 y 相等，但它们都是逻辑变量，因此没有具体值(注意，x 和 y 并不是之前 run 调用中可能被绑定的值)。
# eq(x, y) 目标是成功的，只要 x 和 y 代表同一个未知值即可。但这个目标的成功同样不需要给逻辑变量 w 赋任何值。
# 因此，w 也是未绑定状态，run 返回内部逻辑值 ~_4。

# run 多条件约束
print(run(0, x, eq(x, z), eq(z, 1))) # 输出：(1,)
# 解释：z=1=x，因此x只能为1

## membero()
print(membero(x, (1,2,3))) 
# 输出：(<function lany at 0x7f44bc486bf8>, (<function eq at 0x7f44bc4869d8>, ~_1, 1), (<function eq at 0x7f44bc4869d8>, ~_1, 2), (<function eq at 0x7f44bc4869d8>, ~_1, 3))
# 解释：由于 membero 没有被 run 执行，它不会去查找解，而是直接返回一个内部的逻辑目标对象。
# `<function lany at ...>`：逻辑“或”目标
# `(<function eq at ...>, ~_1, 1/2/3)`：表示逻辑变量 ~_1 等于 1 or 2 or 3
# 这些条件组合起来表示“x 是 (2, 3, 4) 的成员”。

print(run(0, x, membero(x, (1,2,3)), membero(x, (2,3,4)))) # 输出：(2, 3)
# 解释：x 取(1, 2, 3) 和 (2, 3, 4) 的交集，结果是 (2, 3)。

# Relation, facts: Knowledge representation
from kanren import Relation, facts

parent = Relation()
facts(parent, ("Homer", "Bart"),
            ("Homer", "Lisa"),
            ("Abe",  "Homer"))

print(run(0, x, parent(x, "Bart"))) # 输出：('Homer',)

print(run(0, x, parent("Homer", x))) # 输出：('Lisa', 'Bart')

print(run(0, x, parent(x,y), parent(y, "Bart"))) # 输出：('Abe',) ，即 Bart 的祖父是 Abe
```

### Kanren源码阅读

TODO 有空再写(其实我也不是很想看……)

目前暂时只有Gemini DR的参考文档。https://docs.google.com/document/d/1AKkBnChueXJEUqGym_dSVgQLXEm3wFYQdB_tBZhXHBw/edit?usp=sharing

## 8-Queens问题

源代码：`main.py`

```python
# main.py
# -*- coding: utf-8 -*-

# 导入 kanren 库的核心组件
from kanren import run, var, lall, isvar, reify
# 导入 permuteq 用于列约束
from kanren.goals import permuteq
# 可能需要导入 fail (虽然在此实现中通过返回空流隐式失败)
# from kanren import fail

# --- 问题定义 ---
N = 8 # 棋盘大小 (N x N) 和皇后数量

# --- 逻辑变量和常量 ---
# 定义一个逻辑变量来代表解：一个长度为 N 的元组，
# 其中索引是行号，值是该行皇后的列号。
queens_var = var('queens')

# 创建一个包含所有列号的元组，用于 permuteq 约束
cols = tuple(range(N))

# --- 约束目标定义 ---

# 1. 行约束: 通过 queens_var[row] = col 的表示法隐式满足。

# 2. 列约束: 使用 permuteq 确保 queens_var 是 cols 的一个排列。
#    这保证了所有列号都是 0 到 N-1 之间唯一的整数。
column_constraint_goal = permuteq(queens_var, cols)

# 3. 对角线约束: 自定义目标来检查所有皇后对。
def diagonal_constraint_goal(q_tuple_var, N=8):
    """
    生成一个 Kanren 目标，用于检查 q_tuple_var (代表皇后位置元组)
    是否满足对角线约束 (|row1 - row2|!= |col1 - col2| for all pairs)。
    体现了约束满足的思想：检查一个候选解是否符合规则。
    """
    def goal(substitution):
        """Kanren 目标函数，接收一个替换并产生一个替换流。"""
        # 使用 reify 获取 q_tuple_var 在当前替换下的具体值。
        # 这是逻辑编程中连接逻辑世界和 Python 值的桥梁。
        _q_tuple = reify(q_tuple_var, substitution)

        # 如果 q_tuple_var 仍是逻辑变量 (未绑定)，暂时无法检查。
        # 目标暂时成功，依赖 kanren 的执行顺序或回溯。
        if isvar(_q_tuple):
            yield substitution
            return

        # 检查具体化的值是否是有效的棋盘表示结构。
        if not isinstance(_q_tuple, (tuple, list)) or len(_q_tuple)!= N:
            return # 无效结构，目标失败

        # 检查所有不同的皇后对。这是将问题的数学约束直接翻译成代码。
        for r1 in range(N):
            for r2 in range(r1 + 1, N):
                # 获取列号 (col = queens[row])
                c1 = _q_tuple[r1]
                c2 = _q_tuple[r2]

                # 基本类型检查 (可能冗余，但确保安全)
                if not isinstance(c1, int) or not isinstance(c2, int):
                     return # 类型错误，目标失败

                # 对角线攻击检查
                if abs(r1 - r2) == abs(c1 - c2):
                    # 发现攻击，此解无效，目标失败。
                    return # 返回空流表示失败

        # 若所有对都检查通过，说明满足对角线约束。
        # 目标成功，产生（传递）当前的有效替换。
        yield substitution

    # 返回这个目标生成器函数
    return goal

# --- 组合所有约束 ---
# 使用 lall (逻辑与) 将所有显式约束组合成一个总目标。
# 求解器需要找到满足 *所有* 这些约束的 queens_var 的绑定。
# 这体现了逻辑编程的声明性：我们声明了解必须满足的条件。
eight_queens_goal = lall(
    column_constraint_goal, # 列约束
    diagonal_constraint_goal(queens_var, N) # 对角线约束
)

# --- 执行求解 ---
print(f"正在使用 kanren 求解 {N} 皇后问题...")

# 使用 run 函数执行求解。
# run(n, result_var, *goals)
# n=0 表示查找所有解。
# result_var=queens_var 表示我们关心 queens_var 的绑定值。
# *goals=eight_queens_goal 是要满足的总目标。
solutions = run(0, queens_var, eight_queens_goal)

# --- 输出结果 ---
print(f"找到 {len(solutions)} 个解。")

# 打印找到的解。run 函数返回的已经是 reify 后的具体 Python 值。
# 每个解是一个元组，表示 (col0, col1,..., colN-1)。
for i, sol in enumerate(solutions):
    print(f"解 {i+1}: {sol}")

# 可选：将解可视化打印为棋盘 (美化版)
def print_board(solution, N=8):
    """
    打印一个更美观的 N 皇后棋盘。
    使用 Unicode 字符绘制边框和皇后。
    """
    # 顶部边框
    print("┌" + "───┬" * (N - 1) + "───┐")

    for r in range(N):
        line = "│" # 行起始
        for c in range(N):
            # 如果当前行 r 的皇后在列 c
            if solution[r] == c:
                # 使用 Unicode 皇后符号 '♕' 或 '♛'，并添加空格以保持宽度
                line += " ♕ │"
            else:
                # 空白格子，使用三个空格保持宽度
                line += "   │"
        print(line)
        # 行间分隔符，最后一行下方是底部边框
        if r < N - 1:
            print("├" + "───┼" * (N - 1) + "───┤")
        else:
            # 底部边框
            print("└" + "───┴" * (N - 1) + "───┘")

if solutions:
    for i in range(min(3, len(solutions))):
        print(f"\n解 {i+1} 的棋盘:")
        print_board(solutions[i], N)
```

### 1. 建模八皇后问题

#### 1.1 核心约束

根据八皇后问题的定义，一个有效的解必须满足以下所有约束条件：

行约束: 每行必须且仅能放置一个皇后。

列约束: 每列必须且仅能放置一个皇后。

主对角线约束: 每条从左上到右下的对角线上最多只能放置一个皇后。

副对角线约束: 每条从右上到左下的对角线上最多只能放置一个皇后。

#### 1.2 解的表示

为了在 kanren 中处理这个问题，我们需要一种表示棋盘状态和皇后位置的方式。一个常用且高效的表示方法是使用一个长度为 N（对于八皇后问题，N=8）的列表或元组 `queens`。在这个表示中，列表的 **索引** 代表棋盘的行号（从 0 到 N-1），而列表中该索引处的 **值** 代表位于该行的皇后的列号（同样从 0 到 N-1）。

例如，如果 `queens = (1, 3, 0, 2, 4, 6, 7, 5)`，这表示：
- 第 0 行的皇后在第 1 列。
- 第 1 行的皇后在第 3 列。
- ...
- 第 7 行的皇后在第 5 列。

#### 1.3 隐式满足的约束

采用上述 `queens[row] = col` 的表示方法，**行约束**（每行一个皇后）被隐式地满足了。因为列表的**每个索引（行号）都恰好对应一个元素（该行皇后的列号）**，天然保证了每行有且仅有一个皇后。因此，在后续的 kanren 实现中，我们无需为行约束显式地创建目标。

接下来的任务是将剩余的**列约束**和**对角线约束**转化为 kanren 可以理解和求解的目标。

### 2. 将约束实现为 kanren 目标

#### 2.1 列约束：`permuteq` 的运用

列约束要求每列只有一个皇后。在我们选择的表示法中，这意味着 `queens` 列表（或元组）中的所有值（列号）必须是唯一的，并且恰好是 0 到 7 的一个**排列**。

kanren 在其 `goals` 模块中提供了一个名为 `permuteq(a, b)` 的目标，该目标**在序列 a 是序列 b 的一个排列时返回`success`**。我们可以利用这个目标来实现列约束。

我们定义一个逻辑变量 `queens_var` 来代表我们的解（即长度为 8 的皇后列号元组）。同时，我们创建一个包含所有可能列号的元组 `cols = (0, 1, 2, 3, 4, 5, 6, 7)`。列约束目标可以表示为：

```python
from kanren import var
from kanren.goals import permuteq

N = 8
queens_var = var('queens')
cols = tuple(range(N))

# 列约束目标
column_constraint = permuteq(queens_var, cols)
```

当 kanren 求解这个目标时，它会尝试将 queens_var 绑定到 cols 的各种排列上。例如，`(0, 1, 2, 3, 4, 5, 6, 7), (1, 0, 2, 3, 4, 5, 6, 7), (7, 6, 5, 4, 3, 2, 1, 0)` 等都是可能的绑定。这确保了任何满足此目标的 `queens_var` 的绑定都自动满足列约束（所有列号唯一且在 0-7 范围内）。

#### 2.2 对角线约束：自定义目标

对角线约束是最复杂的。对于棋盘上任意两个不同位置的皇后 `(row1, col1)` 和 `(row2, col2)`，它们不能位于同一对角线上。这可以通过以下数学条件来表达：$$\vert row1−row2 \vert \neq \vert col1−col2 \vert$$

其中，`col1=queens[row1]` 且 `col2=queens[row2]`。我们需要创建一个 kanren 目标来检查一个给定的 queens 排列是否满足这个条件。

```python
from kanren import isvar, reify

def diagonal_constraint_goal(q_tuple_var, N=8):
    """
    生成一个 Kanren 目标，用于检查 q_tuple_var (代表皇后位置元组)
    是否满足对角线约束 (|row1 - row2|!= |col1 - col2| for all pairs)。
    体现了约束满足的思想：检查一个候选解是否符合规则。
    """
    def goal(substitution):
        """Kanren 目标函数，接收一个替换并产生一个替换流。"""
        # 使用 reify 获取 q_tuple_var 在当前替换下的具体值。
        # 这是逻辑编程中连接逻辑世界和 Python 值的桥梁。
        _q_tuple = reify(q_tuple_var, substitution)

        # 如果 q_tuple_var 仍是逻辑变量 (未绑定)，暂时无法检查。
        # 目标暂时成功，依赖 kanren 的执行顺序或回溯。
        if isvar(_q_tuple):
            yield substitution
            return

        # 检查具体化的值是否是有效的棋盘表示结构。
        if not isinstance(_q_tuple, (tuple, list)) or len(_q_tuple)!= N:
            return # 无效结构，目标失败

        # 检查所有不同的皇后对。这是将问题的数学约束直接翻译成代码。
        for r1 in range(N):
            for r2 in range(r1 + 1, N):
                # 获取列号 (col = queens[row])
                c1 = _q_tuple[r1]
                c2 = _q_tuple[r2]

                # 基本类型检查 (可能冗余，但确保安全)
                if not isinstance(c1, int) or not isinstance(c2, int):
                     return # 类型错误，目标失败

                # 对角线攻击检查
                if abs(r1 - r2) == abs(c1 - c2):
                    # 发现攻击，此解无效，目标失败。
                    return # 返回空流表示失败

        # 若所有对都检查通过，说明满足对角线约束。
        # 目标成功，产生（传递）当前的有效替换。
        yield substitution

    # 返回这个目标生成器函数
    return goal
```

#### 2.3 组合所有约束：lall 的力量

现在我们有了列约束目标 (permuteq) 和对角线约束目标 (diagonal_constraint_goal)。八皇后问题的解必须同时满足这两个约束（以及隐式满足的行约束）。kanren 的 `lall (logical all)` 目标构造器正是用于此目的，它确保其包含的所有子目标都必须成功。

最终的八皇后问题求解目标可以定义如下：

```python
from kanren import lall

# 最终的八皇后求解目标
eight_queens_goal = lall(
    # 约束 1: queens_var 必须是 (0, 1,..., N-1) 的一个排列 (列约束)
    permuteq(queens_var, cols),
    # 约束 2: 这个排列必须满足对角线约束
    diagonal_constraint_goal(queens_var, N)
    # 行约束已由表示法隐式满足
)
```

当使用 run 函数执行`eight_queens_goal`目标时，kanren 的引擎将搜索 `queens_var` 的绑定，这些绑定首先是 `cols` 的一个排列，并且这个排列还能通过 `diagonal_constraint_goal` 的检查。kanren 内部的合一和回溯机制将处理搜索过程。

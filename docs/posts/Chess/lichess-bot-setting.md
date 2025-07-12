`config.yml` 示例配置文件解读：

**1. 基础设置**

*   `token`: **必需**。你的 Lichess API 访问令牌，用于授权机器人代表你的账户进行操作。
*   `url`: Lichess 服务器的 URL，通常保持默认 `https://lichess.org/`。

**2. 引擎设置 (`engine`)**

这部分配置了机器人使用的国际象棋引擎。

*   `dir`: 引擎可执行文件所在的目录。可以是相对于 `lichess-bot` 运行目录的相对路径，也可以是绝对路径。**重要**：在 Docker 环境下，这通常是容器内的路径，例如挂载卷后的路径 `/lichess-bot/config/engines/`。
*   `name`: 引擎可执行文件的名称。
*   `interpreter`, `interpreter_options`: 如果引擎需要解释器（如 Java 引擎需要 `java -jar`），在这里指定。
*   `working_dir`: 引擎读写文件的工作目录。如果留空，则使用当前目录。**注意**：设置后，引擎会相对于此目录查找文件，而不是 `lichess-bot` 的启动目录。
*   `protocol`: 引擎使用的通信协议，可以是 "uci"（通用国际象棋接口）、"xboard" 或 "homemade"（自定义）。
*   `ponder`: 是否允许引擎在对手思考时也进行思考。

    *   **`polyglot` (开局库)**:
        *   `enabled`: 是否启用 Polyglot 格式的开局库。
        *   book: 按变体（standard, atomic 等）指定开局库文件（`.bin`）的路径列表。
        *   `min_weight`: 不选择权重低于此值的开局库着法。
        *   `selection`: 开局库着法的选择策略："weighted\_random"（按权重随机）、"uniform\_random"（均匀随机）或 "best\_move"（最佳着法）。
        *   `max_depth`: 从开局开始最多使用多少步开局库着法。

    *   **`draw_or_resign` (和棋/认输逻辑)**:
        *   `resign_enabled`: 是否允许机器人认输。
        *   `resign_score`: 当引擎评估分数低于或等于此值（单位：厘兵 centipawn）时考虑认输。
        *   `resign_for_egtb_minus_two`: 如果在线残局库返回 WDL（赢/和/输）为 -2（必败），是否认输。
        *   `resign_moves`: 需要连续多少步分数低于 `resign_score` 才认输。
        *   `offer_draw_enabled`: 是否允许机器人提和/接受和棋。
        *   `offer_draw_score`: 当引擎评估分数的绝对值低于或等于此值时考虑提和/接受和棋。
        *   `offer_draw_for_egtb_zero`: 如果在线残局库返回 WDL 为 0（和棋），是否提和/接受和棋。
        *   `offer_draw_moves`: 需要连续多少步分数绝对值低于 `offer_draw_score` 才提和/接受和棋。
        *   `offer_draw_pieces`: 只有当盘面上的棋子总数少于或等于此值时，才考虑提和/接受和棋。

    *   **`online_moves` (在线着法来源)**:
        *   `max_out_of_book_moves`: 在线开局库连续多少次没有提供着法后停止使用它。
        *   `max_retries`: 获取在线着法失败时的最大重试次数。
        *   `chessdb_book`: 配置是否使用 ChessDB 开局库及其参数。
        *   `lichess_cloud_analysis`: 配置是否使用 Lichess 云分析及其参数。
        *   `lichess_opening_explorer`: 配置是否使用 Lichess 开局库浏览器及其参数（可以选择大师库、Lichess 库或特定玩家库）。
        *   `online_egtb`: 配置是否使用在线残局库（Lichess 或 ChessDB）及其参数（最大棋子数、最低思考时间等）。

    *   **`lichess_bot_tbs` (机器人本地残局库)**:
        *   这部分配置由 `lichess-bot` 程序本身读取的本地残局库，而不是引擎。
        *   `syzygy`: 配置 Syzygy 残局库（`.rtbw`, `.rtbz`）。
        *   `gaviota`: 配置 Gaviota 残局库（`.gtb`）。
        *   `paths`: 残局库文件所在的路径列表。
        *   `max_pieces`: 使用残局库的最大棋子数。
        *   `move_quality`: "best"（只走最佳着法）或 "suggest"（告诉引擎只考虑 WDL 相同的着法）。

    *   **`engine_options`, `homemade_options`, `uci_options`, `xboard_options`**:
        *   用于向引擎传递特定协议的自定义参数。
        *   `uci_options`: 常用于设置 UCI 引擎的参数，如 `Threads`（线程数）、`Hash`（哈希表大小 MB）、`SyzygyPath`（引擎读取的 Syzygy 路径）、`Move Overhead`（着法时间开销，防止超时）等。
        *   `go_commands`: 可以为 UCI 或 XBoard 的 `go` 命令附加额外参数，如 `depth`（搜索深度）、`nodes`（节点数）、`movetime`（固定思考时间）。

    *   `silence_stderr`: 是否抑制引擎的标准错误输出（有些引擎如 Leela 输出信息较多）。

**3. 机器人行为设置**

*   `abort_time`: 如果游戏长时间没有活动（对手掉线等），多少秒后中止游戏。
*   `fake_think_time`: 是否人为地让机器人延迟出招，模拟思考。
*   `rate_limiting_delay`: 每次发送着法后延迟多少毫秒，防止因请求过于频繁而被 Lichess 限制。
*   `move_overhead`: 额外的着法时间开销（毫秒），用于网络延迟和处理时间，防止超时。与 `uci_options` 中的 `Move Overhead` 类似但作用于不同层面。
*   `max_takebacks_accepted`: 允许对手悔棋的最大次数。
*   `quit_after_all_games_finish`: 如果为 `true`，按下 Ctrl+C 时，机器人会等待所有当前对局结束后再退出。

**4. 通信对局设置 (`correspondence`)**

*   `move_time`: 在通信对局中每次思考的时间（秒）。
*   `checkin_period`: 断开连接后，每隔多少秒检查一次对手是否走了棋。
*   `disconnect_time`: 在通信对局中无活动多少秒后断开连接。
*   `ponder`: 是否在连接的通信对局中进行 Ponder。

**5. 挑战处理设置 (`challenge`)**

这部分配置机器人如何处理收到的挑战。

*   `concurrency`: 同时进行的最大游戏数量。
*   `sort_by`: 接受挑战的顺序："best"（优先接受评分接近的对手）或 "first"（先到先得）。
*   `preference`: 优先接受来自 "human"（人类）、"bot"（机器人）还是 "none"（无偏好）的挑战。
*   `accept_bot`: 是否接受来自其他机器人的挑战。
*   `only_bot`: 是否只接受来自机器人的挑战。
*   `max_increment`, `min_increment`: 接受挑战的最大/最小每步加秒数。
*   `max_base`, `min_base`: 接受挑战的最大/最小基础时间（秒）。
*   `max_days`, `min_days`: 接受通信对局挑战的最大/最小每步天数。
*   `variants`: 接受的棋类变体列表。
*   `time_controls`: 接受的时间控制类型列表（bullet, blitz, rapid, classical, correspondence）。
*   `modes`: 接受的游戏模式列表（casual - 非等级分, rated - 等级分）。
*   `block_list`: 总是拒绝来自这些用户的挑战。
*   `allow_list`: 只接受来自这些用户的挑战（如果列表为空，则接受所有用户）。
*   `recent_bot_challenge_age`, `max_recent_bot_challenges`: 防止短时间内接受来自同一个机器人的过多挑战。
*   `bullet_requires_increment`: 是否要求来自机器人的 bullet 挑战必须有加秒。
*   `max_simultaneous_games_per_user`: 限制与同一个用户同时进行的最大游戏数。

**6. 问候语设置 (`greeting`)**

*   `hello`, `goodbye`: 在游戏开始和结束时发送给对手的聊天消息。
*   `hello_spectators`, `goodbye_spectators`: 在游戏开始和结束时发送给观战者的聊天消息。
*   可以使用 `{opponent}` 和 `{me}` 作为占位符。

**7. PGN 保存设置**

*   `pgn_directory`: 保存游戏记录（PGN 格式）的目录。
*   `pgn_file_grouping`: PGN 文件的组织方式："game"（每个游戏一个文件）、"opponent"（每个对手一个文件）或 "all"（所有游戏一个文件）。

**8. 自动匹配设置 (`matchmaking`)**

这部分配置机器人主动发起挑战的行为。

*   `allow_matchmaking`: 是否允许机器人主动发起挑战。
*   `allow_during_games`: 是否允许在进行长时对局时也发起新的挑战。
*   `challenge_variant`: 发起挑战的变体，可以是具体变体或 "random"。
*   `challenge_timeout`: 空闲多少分钟后发起挑战。
*   `challenge_initial_time`, `challenge_increment`, `challenge_days`: 发起挑战时随机选择的基础时间、加秒或天数。
*   `opponent_min_rating`, `opponent_max_rating`: 挑战对手的最低/最高等级分。
*   `opponent_rating_difference`: 挑战对手与自身等级分的最大差距。
*   `rating_preference`: 优先挑战 "high"（高分）、"low"（低分）还是 "none"（无偏好）的对手。
*   `opponent_allow_tos_violation`: 是否允许挑战违反了 Lichess 服务条款的机器人。
*   `challenge_mode`: 发起挑战的模式（casual, rated, random）。
*   `challenge_filter`: 如果一个机器人拒绝了挑战，是否避免向其发送类似的挑战（none, coarse, fine）。
*   `block_list`: 不会主动挑战这些用户。
*   `include_challenge_block_list`: 是否也将 `challenge.block_list` 中的用户加入不挑战列表。
*   `overrides`: 允许定义多个不同的匹配场景配置，机器人会随机选择一个默认或覆盖配置来发起挑战。这允许你设置例如“只挑战低分对手下 Chess960”或“只下快速 Horde”等特定场景。
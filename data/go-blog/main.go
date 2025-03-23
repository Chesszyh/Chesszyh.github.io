// main.go - 主程序入口

package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	_ "github.com/mattn/go-sqlite3" // SQLite驱动
	"github.com/gorilla/mux"        // 路由库
)

// 数据模型

// Post 表示博客文章
type Post struct {
	ID        int       `json:"id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
}

// Comment 表示评论
type Comment struct {
	ID        int       `json:"id"`
	PostID    int       `json:"post_id"`
	Author    string    `json:"author"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
}

// 全局变量
var (
	db  *sql.DB
	tpl *template.Template
)

// 初始化数据库
func initDB() {
	var err error
	// 打开SQLite数据库，如果不存在则创建
	db, err = sql.Open("sqlite3", "./blog.db")
	if err != nil {
		log.Fatal(err)
	}

	// 创建文章表
	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS posts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			title TEXT NOT NULL,
			content TEXT NOT NULL,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP
		)
	`)
	if err != nil {
		log.Fatal(err)
	}

	// 创建评论表
	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS comments (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			post_id INTEGER NOT NULL,
			author TEXT NOT NULL,
			content TEXT NOT NULL,
			created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
			FOREIGN KEY (post_id) REFERENCES posts(id)
		)
	`)
	if err != nil {
		log.Fatal(err)
	}
}

// 初始化模板
func initTemplates() {
	// 创建templates目录如果不存在
	if _, err := os.Stat("templates"); os.IsNotExist(err) {
		os.Mkdir("templates", 0755)
	}

	// 创建基础模板文件
	baseTemplate := `
<!DOCTYPE html>
<html>
<head>
    <title>{{.Title}}</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; max-width: 800px; margin: 0 auto; }
        header { margin-bottom: 20px; border-bottom: 1px solid #eee; }
        nav a { margin-right: 15px; }
        .post { margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
        .post h2 { margin-bottom: 5px; }
        .post-meta { color: #666; font-size: 0.8em; margin-bottom: 15px; }
        .comment { margin: 10px 0; padding: 10px; background: #f9f9f9; }
        form { margin: 20px 0; }
        label { display: block; margin: 10px 0 5px; }
        input, textarea { width: 100%; padding: 8px; margin-bottom: 10px; }
        button { padding: 10px 15px; background: #4CAF50; color: white; border: none; cursor: pointer; }
        button:hover { background: #45a049; }
    </style>
</head>
<body>
    <header>
        <h1>Go博客</h1>
        <nav>
            <a href="/">首页</a>
            <a href="/new">发布文章</a>
        </nav>
    </header>
    <main>
        {{template "content" .}}
    </main>
    <footer>
        <p>&copy; {{.Year}} Go博客示例</p>
    </footer>
</body>
</html>
`

	indexTemplate := `
{{define "content"}}
    <h2>最新文章</h2>
    {{range .Posts}}
    <div class="post">
        <h2><a href="/post/{{.ID}}">{{.Title}}</a></h2>
        <div class="post-meta">发布于 {{.CreatedAt.Format "2006-01-02 15:04"}}</div>
        <p>{{if gt (len .Content) 200}}{{slice .Content 0 200}}...{{else}}{{.Content}}{{end}}</p>
        <a href="/post/{{.ID}}">阅读全文</a>
    </div>
    {{else}}
    <p>还没有文章，<a href="/new">发布一篇</a>吧！</p>
    {{end}}
{{end}}
`

	postTemplate := `
{{define "content"}}
    <div class="post">
        <h2>{{.Post.Title}}</h2>
        <div class="post-meta">发布于 {{.Post.CreatedAt.Format "2006-01-02 15:04"}}</div>
        <div class="post-content">
            {{.Post.Content}}
        </div>
    </div>
    
    <h3>评论 ({{len .Comments}})</h3>
    {{range .Comments}}
    <div class="comment">
        <div class="comment-meta">
            <strong>{{.Author}}</strong> 于 {{.CreatedAt.Format "2006-01-02 15:04"}} 发表
        </div>
        <div class="comment-content">
            {{.Content}}
        </div>
    </div>
    {{else}}
    <p>还没有评论，来发表第一个评论吧！</p>
    {{end}}
    
    <h3>发表评论</h3>
    <form action="/post/{{.Post.ID}}/comment" method="post">
        <div>
            <label for="author">昵称</label>
            <input type="text" id="author" name="author" required>
        </div>
        <div>
            <label for="content">评论内容</label>
            <textarea id="content" name="content" rows="5" required></textarea>
        </div>
        <button type="submit">发表评论</button>
    </form>
{{end}}
`

	newPostTemplate := `
{{define "content"}}
    <h2>发布新文章</h2>
    <form action="/new" method="post">
        <div>
            <label for="title">标题</label>
            <input type="text" id="title" name="title" required>
        </div>
        <div>
            <label for="content">内容</label>
            <textarea id="content" name="content" rows="10" required></textarea>
        </div>
        <button type="submit">发布</button>
    </form>
{{end}}
`

	// 写入模板文件
	os.WriteFile("templates/base.html", []byte(baseTemplate), 0644)
	os.WriteFile("templates/index.html", []byte(indexTemplate), 0644)
	os.WriteFile("templates/post.html", []byte(postTemplate), 0644)
	os.WriteFile("templates/new.html", []byte(newPostTemplate), 0644)

	// 解析模板
	tpl = template.Must(template.ParseGlob("templates/*.html"))
}

// 处理首页请求
func indexHandler(w http.ResponseWriter, r *http.Request) {
	// 查询所有文章，按创建时间倒序排列
	rows, err := db.Query("SELECT id, title, content, created_at FROM posts ORDER BY created_at DESC")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var posts []Post
	for rows.Next() {
		var p Post
		var createdAt string
		if err := rows.Scan(&p.ID, &p.Title, &p.Content, &createdAt); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		// 解析时间字符串
		p.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAt)
		posts = append(posts, p)
	}

	// 渲染模板
	data := struct {
		Title string
		Year  int
		Posts []Post
	}{
		Title: "Go博客 - 首页",
		Year:  time.Now().Year(),
		Posts: posts,
	}

	if err := tpl.ExecuteTemplate(w, "base.html", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// 显示单篇文章
func postHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "无效的文章ID", http.StatusBadRequest)
		return
	}

	// 查询文章
	var post Post
	var createdAt string
	err = db.QueryRow("SELECT id, title, content, created_at FROM posts WHERE id = ?", id).
		Scan(&post.ID, &post.Title, &post.Content, &createdAt)
	if err != nil {
		if err == sql.ErrNoRows {
			http.NotFound(w, r)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	post.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAt)

	// 查询评论
	rows, err := db.Query("SELECT id, author, content, created_at FROM comments WHERE post_id = ? ORDER BY created_at", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var comments []Comment
	for rows.Next() {
		var c Comment
		var commentCreatedAt string
		if err := rows.Scan(&c.ID, &c.Author, &c.Content, &commentCreatedAt); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		c.PostID = id
		c.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", commentCreatedAt)
		comments = append(comments, c)
	}

	// 渲染模板
	data := struct {
		Title    string
		Year     int
		Post     Post
		Comments []Comment
	}{
		Title:    post.Title + " - Go博客",
		Year:     time.Now().Year(),
		Post:     post,
		Comments: comments,
	}

	if err := tpl.ExecuteTemplate(w, "base.html", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// 发布评论
func addCommentHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "仅支持POST请求", http.StatusMethodNotAllowed)
		return
	}

	vars := mux.Vars(r)
	postID, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "无效的文章ID", http.StatusBadRequest)
		return
	}

	// 解析表单
	if err := r.ParseForm(); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	author := r.FormValue("author")
	content := r.FormValue("content")

	if author == "" || content == "" {
		http.Error(w, "昵称和评论内容不能为空", http.StatusBadRequest)
		return
	}

	// 插入评论
	_, err = db.Exec("INSERT INTO comments (post_id, author, content) VALUES (?, ?, ?)",
		postID, author, content)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 重定向回文章页面
	http.Redirect(w, r, fmt.Sprintf("/post/%d", postID), http.StatusSeeOther)
}

// 新建文章表单页面
func newPostFormHandler(w http.ResponseWriter, r *http.Request) {
	data := struct {
		Title string
		Year  int
	}{
		Title: "发布新文章 - Go博客",
		Year:  time.Now().Year(),
	}

	if err := tpl.ExecuteTemplate(w, "base.html", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// 处理新建文章的提交
func createPostHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "仅支持POST请求", http.StatusMethodNotAllowed)
		return
	}

	// 解析表单
	if err := r.ParseForm(); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	title := r.FormValue("title")
	content := r.FormValue("content")

	if title == "" || content == "" {
		http.Error(w, "标题和内容不能为空", http.StatusBadRequest)
		return
	}

	// 插入文章
	result, err := db.Exec("INSERT INTO posts (title, content) VALUES (?, ?)",
		title, content)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 获取新插入的文章ID
	id, err := result.LastInsertId()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// 重定向到新文章页面
	http.Redirect(w, r, fmt.Sprintf("/post/%d", id), http.StatusSeeOther)
}

// 添加RESTful API接口 - 获取所有文章
func apiGetPostsHandler(w http.ResponseWriter, r *http.Request) {
	// 设置响应头
	w.Header().Set("Content-Type", "application/json")

	// 查询所有文章
	rows, err := db.Query("SELECT id, title, content, created_at FROM posts ORDER BY created_at DESC")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var posts []Post
	for rows.Next() {
		var p Post
		var createdAt string
		if err := rows.Scan(&p.ID, &p.Title, &p.Content, &createdAt); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		p.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAt)
		posts = append(posts, p)
	}

	// 转换为JSON并响应
	json.NewEncoder(w).Encode(posts)
}

// 添加RESTful API接口 - 获取单篇文章
func apiGetPostHandler(w http.ResponseWriter, r *http.Request) {
	// 设置响应头
	w.Header().Set("Content-Type", "application/json")

	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "无效的文章ID", http.StatusBadRequest)
		return
	}

	// 查询文章
	var post Post
	var createdAt string
	err = db.QueryRow("SELECT id, title, content, created_at FROM posts WHERE id = ?", id).
		Scan(&post.ID, &post.Title, &post.Content, &createdAt)
	if err != nil {
		if err == sql.ErrNoRows {
			http.NotFound(w, r)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	post.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAt)

	// 转换为JSON并响应
	json.NewEncoder(w).Encode(post)
}

// Go程序入口函数
func main() {
	// 初始化数据库
	initDB()
	defer db.Close()

	// 初始化模板
	initTemplates()

	// 创建路由器
	r := mux.NewRouter()

	// 注册Web页面路由
	r.HandleFunc("/", indexHandler).Methods("GET")
	r.HandleFunc("/post/{id:[0-9]+}", postHandler).Methods("GET")
	r.HandleFunc("/post/{id:[0-9]+}/comment", addCommentHandler).Methods("POST")
	r.HandleFunc("/new", newPostFormHandler).Methods("GET")
	r.HandleFunc("/new", createPostHandler).Methods("POST")

	// 注册API路由
	r.HandleFunc("/api/posts", apiGetPostsHandler).Methods("GET")
	r.HandleFunc("/api/posts/{id:[0-9]+}", apiGetPostHandler).Methods("GET")

	// 启动服务器
	port := 8080
	log.Printf("服务器启动在 http://localhost:%d", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), r))
}
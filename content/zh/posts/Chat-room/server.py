import socket
import threading

# 服务器配置
HOST = '127.0.0.1'  # 服务器IP地址，使用 '0.0.0.0' 监听所有可用接口
PORT = 12345        # 服务器端口号

# 存储客户端连接和昵称
clients = {}  # {nickname: client_socket}
nicknames = [] # [nickname1, nickname2, ...]

# 广播消息给所有连接的客户端
def broadcast(message, _client_socket=None):
    for nickname, client_sock in clients.items():
        if client_sock != _client_socket: # 不把消息发回给发送者自己 (可选)
            try:
                client_sock.send(message)
            except:
                # 如果发送失败，假定客户端已断开
                remove_client(nickname, client_sock)

# 移除客户端
def remove_client(nickname, client_socket):
    if nickname in nicknames:
        nicknames.remove(nickname)
    if nickname in clients:
        del clients[nickname]
    try:
        client_socket.close()
    except:
        pass
    print(f"用户 {nickname} 已断开连接。")
    broadcast(f"通知: 用户 {nickname} 已离开聊天室。\n".encode('utf-8'))

# 处理单个客户端连接
def handle_client(client_socket, client_address):
    print(f"接受来自 {client_address} 的新连接。")
    
    # 获取昵称
    while True:
        try:
            client_socket.send("请输入您的昵称: ".encode('utf-8'))
            nickname = client_socket.recv(1024).decode('utf-8').strip()
            if nickname:
                if nickname not in nicknames:
                    client_socket.send("昵称设置成功！\n".encode('utf-8'))
                    break
                else:
                    client_socket.send("错误: 昵称已被占用，请重新输入。\n".encode('utf-8'))
            else:
                client_socket.send("错误: 昵称不能为空。\n".encode('utf-8'))
        except:
            print(f"与 {client_address} 的连接在昵称设置阶段断开。")
            client_socket.close()
            return

    nicknames.append(nickname)
    clients[nickname] = client_socket
    
    print(f"用户 {nickname} ({client_address}) 已加入聊天室。")
    broadcast(f"通知: 用户 {nickname} 已加入聊天室！\n".encode('utf-8'), client_socket)
    client_socket.send(f"欢迎来到聊天室, {nickname}！\n".encode('utf-8'))
    client_socket.send("输入 /list 查看在线用户。\n".encode('utf-8'))
    client_socket.send("输入 /msg <昵称> <消息> 发送私聊消息。\n".encode('utf-8'))


    # 接收和广播消息
    while True:
        try:
            message = client_socket.recv(1024)
            if message:
                decoded_message = message.decode('utf-8').strip()
                if decoded_message.startswith('/list'):
                    online_users = "在线用户: " + ", ".join(nicknames) + "\n"
                    client_socket.send(online_users.encode('utf-8'))
                elif decoded_message.startswith('/msg'):
                    parts = decoded_message.split(" ", 2)
                    if len(parts) == 3:
                        target_nickname = parts[1]
                        private_message = parts[2]
                        if target_nickname in clients:
                            target_socket = clients[target_nickname]
                            try:
                                target_socket.send(f"(私聊) {nickname}: {private_message}\n".encode('utf-8'))
                                client_socket.send(f"(私聊发送给 {target_nickname}): {private_message}\n".encode('utf-8'))
                            except:
                                client_socket.send(f"错误: 无法发送私聊消息给 {target_nickname}。\n".encode('utf-8'))
                                remove_client(target_nickname, target_socket) # 目标可能已掉线
                        else:
                            client_socket.send(f"错误: 用户 {target_nickname} 不在线或不存在。\n".encode('utf-8'))
                    else:
                        client_socket.send("错误: 私聊格式错误。应为 /msg <昵称> <消息>\n".encode('utf-8'))
                else:
                    print(f"收到来自 {nickname} 的消息: {decoded_message}")
                    broadcast(f"{nickname}: {decoded_message}\n".encode('utf-8'), client_socket)
            else:
                # 空消息表示客户端断开
                remove_client(nickname, client_socket)
                break
        except Exception as e:
            print(f"处理客户端 {nickname} 时发生错误: {e}")
            remove_client(nickname, client_socket)
            break

# 服务器主函数
def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) # 允许重用地址
    
    try:
        server_socket.bind((HOST, PORT))
    except socket.error as e:
        print(f"绑定失败: {e}")
        return
        
    server_socket.listen(5) # 最大连接数
    print(f"服务器正在监听 {HOST}:{PORT} ...")

    while True:
        try:
            client_socket, client_address = server_socket.accept()
            thread = threading.Thread(target=handle_client, args=(client_socket, client_address))
            thread.daemon = True # 主线程退出时，子线程也退出
            thread.start()
        except KeyboardInterrupt:
            print("\n服务器正在关闭...")
            break
        except Exception as e:
            print(f"接受连接时发生错误: {e}")
            break
            
    for nick, sock in list(clients.items()): # 使用list复制，因为字典在迭代时可能被修改
        sock.send("通知: 服务器即将关闭。\n".encode('utf-8'))
        remove_client(nick, sock)
    server_socket.close()
    print("服务器已关闭。")

if __name__ == "__main__":
    start_server()
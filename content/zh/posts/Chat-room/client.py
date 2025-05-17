import socket
import threading
import sys

# 接收消息的函数
def receive_messages(client_socket):
    while True:
        try:
            message = client_socket.recv(1024).decode('utf-8')
            if message:
                print(message.strip())
            else:
                # 服务器关闭连接或发生错误
                print("与服务器的连接已断开。")
                client_socket.close()
                break
        except ConnectionResetError:
            print("与服务器的连接被重置。")
            client_socket.close()
            break
        except Exception as e:
            print(f"接收消息时发生错误: {e}")
            client_socket.close()
            break
    # 尝试优雅地退出主线程或整个程序
    print("接收线程结束。按 Enter 退出。")


# 发送消息的函数
def send_messages(client_socket, nickname):
    print("输入消息开始聊天。输入 'exit' 退出。")
    while True:
        try:
            message_to_send = input() # 等待用户输入
            if not client_socket._closed: # 检查套接字是否仍然打开
                if message_to_send.lower() == 'exit':
                    print("正在断开连接...")
                    client_socket.close()
                    break
                
                # 客户端不需要显式地在消息前添加昵称，服务器会处理
                # 但对于私聊，客户端需要发送特定格式
                # 例如: /msg target_user message_content
                # 服务器会解析这个格式
                
                client_socket.send(message_to_send.encode('utf-8'))
            else:
                print("无法发送消息，连接已关闭。")
                break
        except EOFError: # Ctrl+D
            print("正在断开连接 (EOF)...")
            if not client_socket._closed:
                client_socket.close()
            break
        except KeyboardInterrupt: # Ctrl+C
            print("正在断开连接 (Interrupt)...")
            if not client_socket._closed:
                client_socket.close()
            break
        except Exception as e:
            print(f"发送消息时发生错误: {e}")
            if not client_socket._closed:
                client_socket.close()
            break
    print("发送线程结束。")


# 客户端主函数
def start_client():
    host = input("请输入服务器IP地址 (默认为 127.0.0.1): ") or '127.0.0.1'
    port_str = input("请输入服务器端口号 (默认为 12345): ") or '12345'
    
    try:
        port = int(port_str)
    except ValueError:
        print("错误: 端口号必须是数字。")
        return

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        client_socket.connect((host, port))
        print(f"成功连接到服务器 {host}:{port}")
    except ConnectionRefusedError:
        print(f"错误: 无法连接到服务器 {host}:{port}。请确保服务器正在运行并且地址正确。")
        return
    except socket.gaierror:
        print(f"错误: 无效的服务器IP地址或主机名 {host}。")
        return
    except Exception as e:
        print(f"连接服务器时发生错误: {e}")
        return

    # 接收并处理昵称设置
    nickname = ""
    while True:
        try:
            server_prompt = client_socket.recv(1024).decode('utf-8')
            print(server_prompt.strip()) # 显示服务器的提示，如 "请输入您的昵称: "
            
            if "昵称设置成功！" in server_prompt or "欢迎来到聊天室" in server_prompt:
                # 昵称可能在欢迎消息中，或者在单独的成功消息中
                # 简单起见，我们假设昵称已在客户端输入并被服务器接受
                # 如果服务器在欢迎消息中回显昵称，可以解析出来
                if not nickname: # 如果之前没有成功设置昵称
                    # 尝试从欢迎消息中提取昵称（如果服务器设计如此）
                    # 否则，这里的nickname变量可能还是空的，但服务器已经知道了
                    pass # 假设昵称已在服务器端确认
                break 
            
            if "错误:" in server_prompt: # 如果服务器返回错误，例如昵称被占用
                user_input_nickname = input()
                client_socket.send(user_input_nickname.encode('utf-8'))
                nickname = user_input_nickname # 临时存储，等待服务器确认
            else: # 初始提示输入昵称
                user_input_nickname = input()
                client_socket.send(user_input_nickname.encode('utf-8'))
                nickname = user_input_nickname # 临时存储，等待服务器确认

        except Exception as e:
            print(f"设置昵称时发生错误: {e}")
            client_socket.close()
            return
    
    # 启动接收和发送消息的线程
    receive_thread = threading.Thread(target=receive_messages, args=(client_socket,))
    receive_thread.daemon = True
    receive_thread.start()

    send_thread = threading.Thread(target=send_messages, args=(client_socket, nickname))
    send_thread.daemon = True # 允许主线程退出时，发送线程也退出
    send_thread.start()

    # 等待发送线程结束（例如用户输入exit）或接收线程因连接断开而结束
    # 这是一个简化的处理，实际中可能需要更复杂的线程管理
    try:
        while receive_thread.is_alive() and send_thread.is_alive():
            # 保持主线程活动，直到子线程结束
            # 或者直到套接字关闭
            if client_socket._closed:
                break
            threading.Event().wait(0.1) # 短暂等待，避免CPU空转
    except KeyboardInterrupt:
        print("\n客户端正在关闭 (Ctrl+C)...")
    finally:
        if not client_socket._closed:
            client_socket.close()
        print("客户端已关闭。")
        # 等待线程真正结束
        receive_thread.join(timeout=1)
        send_thread.join(timeout=1)


if __name__ == "__main__":
    start_client()
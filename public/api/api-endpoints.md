## Chat Completions
Endpoint: POST /api/chat/completions

Description: Serves as an OpenAI API compatible chat completion endpoint for models on Open WebUI including Ollama models, OpenAI models, and Open WebUI Function models.

Curl Example:

curl -X POST http://localhost:3000/api/chat/completions \
-H "Authorization: Bearer YOUR_API_KEY" \
-H "Content-Type: application/json" \
-d '{
      "model": "llama3.1",
      "messages": [
        {
          "role": "user",
          "content": "Why is the sky blue?"
        }
      ]
    }'

## Retrieval Augmented Generation (RAG)

### Uploading Files
To utilize external data in RAG responses, you first need to upload the files. The content of the uploaded file is automatically extracted and stored in a vector database.

Endpoint: POST /api/v1/files/

Curl Example:

curl -X POST -H "Authorization: Bearer YOUR_API_KEY" -H "Accept: application/json" \
-F "file=@/path/to/your/file" http://localhost:3000/api/v1/files/

### Adding Files to Knowledge Collections
After uploading, you can group files into a knowledge collection or reference them individually in chats.

Endpoint: POST /api/v1/knowledge/{id}/file/add

Curl Example:

curl -X POST http://localhost:3000/api/v1/knowledge/{knowledge_id}/file/add \
-H "Authorization: Bearer YOUR_API_KEY" \
-H "Content-Type: application/json" \
-d '{"file_id": "your-file-id-here"}'

### Using Files and Collections in Chat Completions
You can reference both individual files or entire collections in your RAG queries for enriched responses.

Using an Individual File in Chat Completions
This method is beneficial when you want to focus the chat model's response on the content of a specific file.

Endpoint: POST /api/chat/completions

Curl Example:

curl -X POST http://localhost:3000/api/chat/completions \
-H "Authorization: Bearer YOUR_API_KEY" \
-H "Content-Type: application/json" \
-d '{
      "model": "gpt-4-turbo",
      "messages": [
        {"role": "user", "content": "Explain the concepts in this document."}
      ],
      "files": [
        {"type": "file", "id": "your-file-id-here"}
      ]
    }'

### Using a Knowledge Collection in Chat Completions
Leverage a knowledge collection to enhance the response when the inquiry may benefit from a broader context or multiple documents.

Endpoint: POST /api/chat/completions

Curl Example:

curl -X POST http://localhost:3000/api/chat/completions \
-H "Authorization: Bearer YOUR_API_KEY" \
-H "Content-Type: application/json" \
-d '{
      "model": "gpt-4-turbo",
      "messages": [
        {"role": "user", "content": "Provide insights on the historical perspectives covered in the collection."}
      ],
      "files": [
        {"type": "collection", "id": "your-collection-id-here"}
      ]
    }'

Open WebUI 使用 Swagger 来生成 API 文档，必须设置环境变量 ENV 为 dev 才能访问 Swagger 页面。

```shell
export ENV=dev # /docs
```
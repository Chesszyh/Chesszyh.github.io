// LLM-APIs-for-open-webui
// Reference: https://docs.openwebui.com/getting-started/api-endpoints/

function getApiKey() {
    return localStorage.getItem('apiKey');
}

function get_all_models() {
    // API Endpoints: curl -H "Authorization: Bearer YOUR_API_KEY" http://localhost:3000/api/models
    return fetch('/api/models', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${getApiKey()}`
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .catch(error => {
        console.error('Error fetching models:', error);
        return [];
    });
}

/**
 * Performs RAG (Retrieval Augmented Generation) by uploading a file
 * @param {Object} params - Parameters for the RAG operation
 * @param {File} params.file - The file to upload
 * @returns {Promise<Object>} - Response from the API
 */
function rag(params) {
    const formData = new FormData();
    formData.append('file', params.file);
    
    return fetch('/api/v1/files/', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${getApiKey()}`,
            'Accept': 'application/json'
        },
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .catch(error => {
        console.error('Error uploading file for RAG:', error);
        throw error;
    });
}

/**
 * Add a file to a knowledge collection
 * @param {string} knowledgeId - The ID of the knowledge collection
 * @param {string} fileId - The ID of the file to add
 * @returns {Promise<Object>} - Response from the API
 */
function addFileToKnowledge(knowledgeId, fileId) {
    return fetch(`/api/v1/knowledge/${knowledgeId}/file/add`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${getApiKey()}`
        },
        body: JSON.stringify({ file_id: fileId })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .catch(error => {
        console.error('Error adding file to knowledge collection:', error);
        throw error;
    });
}

/**
 * Send a chat completion request, optionally with RAG
 * @param {boolean} with_rag - Whether to use RAG
 * @param {Object} file - File or collection info for RAG
 * @param {string} file.type - Type of file ('file' or 'collection')
 * @param {string} file.id - ID of the file or collection
 * @param {string} model - The model to use
 * @param {Array} messages - Array of message objects
 * @returns {Promise<Object>} - Chat completion response
 */
function chat(with_rag, file, model, messages) {
    const requestBody = {
        model: model || 'gpt-4o-mini',
        messages: messages || []
    };
    
    if (with_rag && file) {
        requestBody.files = [
            {
                type: file.type, // 'file' or 'collection'
                id: file.id
            }
        ];
    }
    
    return fetch('/api/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${getApiKey()}`
        },
        body: JSON.stringify(requestBody)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .catch(error => {
        console.error('Error in chat completion:', error);
        throw error;
    });
}
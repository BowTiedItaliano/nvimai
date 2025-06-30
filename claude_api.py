import os
import json
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

def send_to_claude(content, prompt):
    """Send content to Claude API and return the response."""
    
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        raise Exception("ANTHROPIC_API_KEY environment variable not set")
    
    url = "https://api.anthropic.com/v1/messages"
    
    headers = {
        'Content-Type': 'application/json',
        'x-api-key': api_key,
        'anthropic-version': '2023-06-01'
    }
    
    data = {
        "model": "claude-3-5-sonnet-20241022",
        "max_tokens": 4000,
        "messages": [
            {
                "role": "user",
                "content": f"{prompt}\n\n{content}"
            }
        ]
    }
    
    try:
        req = Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)
        
        with urlopen(req, timeout=30) as response:
            response_data = json.loads(response.read().decode('utf-8'))
            
            if 'content' in response_data and len(response_data['content']) > 0:
                return response_data['content'][0]['text'].strip()
            else:
                raise Exception("Unexpected response format from Claude API")
                
    except HTTPError as e:
        error_msg = e.read().decode('utf-8') if e.fp else str(e)
        raise Exception(f"HTTP Error {e.code}: {error_msg}")
    except URLError as e:
        raise Exception(f"Network Error: {str(e)}")
    except Exception as e:
        raise Exception(f"API Error: {str(e)}")
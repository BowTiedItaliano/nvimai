if exists('g:loaded_claude_code')
  finish
endif
let g:loaded_claude_code = 1

if !has('python3')
  echohl ErrorMsg
  echomsg "ClaudeCode requires Python 3 support"
  echohl None
  finish
endif

let s:plugin_dir = expand('<sfile>:p:h:h')

function! ClaudeCode()
  let l:content = join(getline(1, '$'), "\n")
  let l:prompt = "Return only the code, no explanations or markdown formatting:"
  
  python3 << EOF
import vim
import sys
import os

plugin_dir = vim.eval('s:plugin_dir')
sys.path.insert(0, plugin_dir)

try:
    from claude_api import send_to_claude
    content = vim.eval('l:content')
    prompt = vim.eval('l:prompt')
    
    response = send_to_claude(content, prompt)
    
    if response:
        lines = response.split('\n')
        vim.current.buffer[:] = lines
        print("Code updated successfully")
    else:
        print("Failed to get response from Claude")
        
except Exception as e:
    print(f"Error: {str(e)}")
EOF
endfunction

nnoremap <leader>cc :call ClaudeCode()<CR>
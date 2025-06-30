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

function! ClaudeCode() range
  let l:has_selection = a:firstline != a:lastline || mode() ==# 'v' || mode() ==# 'V'
  
  if l:has_selection
    let l:start_line = a:firstline
    let l:end_line = a:lastline
    let l:selected_content = join(getline(l:start_line, l:end_line), "\n")
    
    let l:prompt_line = l:start_line > 1 ? l:start_line - 1 : 0
    let l:prompt = ""
    
    if l:prompt_line > 0
      let l:line_content = getline(l:prompt_line)
      if l:line_content =~# '^\s*[#"/\*]'
        let l:prompt = substitute(l:line_content, '^\s*[#"/\*]\+\s*', '', '')
      endif
    endif
    
    if empty(l:prompt)
      let l:prompt = "Return only the code, no explanations or markdown formatting:"
    endif
    
    let l:content = l:selected_content
    let l:replace_range = [l:start_line, l:end_line]
  else
    let l:content = join(getline(1, '$'), "\n")
    let l:prompt = "Return only the code, no explanations or markdown formatting:"
    let l:replace_range = [1, line('$')]
  endif
  
  python3 << EOF
import vim
import sys
import os

plugin_dir = vim.eval('s:plugin_dir')
sys.path.insert(0, plugin_dir)

try:
    from claude_api import send_to_claude_stream
    content = vim.eval('l:content')
    prompt = vim.eval('l:prompt')
    replace_range = vim.eval('l:replace_range')
    
    start_line = int(replace_range[0]) - 1
    end_line = int(replace_range[1]) - 1
    original_num_lines = end_line - start_line + 1
    
    vim.current.buffer[start_line:end_line+1] = ["Streaming response..."]
    vim.command('redraw')
    
    accumulated_response = ""
    
    for chunk in send_to_claude_stream(content, prompt):
        accumulated_response += chunk
        lines = accumulated_response.split('\n')
        
        # Calculate how many lines we need to replace
        new_num_lines = len(lines)
        
        # Replace exactly the range we need, preserving text below
        vim.current.buffer[start_line:start_line+original_num_lines] = lines
        
        # Update original_num_lines for next iteration
        original_num_lines = new_num_lines
        
        vim.command('redraw')
    
    print("Code updated successfully")
        
except Exception as e:
    print(f"Error: {str(e)}")
EOF
endfunction

nnoremap <leader>cc :call ClaudeCode()<CR>
vnoremap <leader>cc :call ClaudeCode()<CR>
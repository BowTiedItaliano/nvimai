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
    
    # Clear the original selection
    vim.current.buffer[start_line:end_line+1] = [""]
    
    # Position cursor at the start of replacement
    vim.current.window.cursor = (start_line + 1, 0)
    current_line = start_line
    current_col = 0
    
    for chunk in send_to_claude_stream(content, prompt):
        for char in chunk:
            if char == '\n':
                # Create new line
                vim.current.buffer.append("", current_line)
                current_line += 1
                current_col = 0
                vim.current.window.cursor = (current_line + 1, 0)
            else:
                # Add character to current line
                line_content = vim.current.buffer[current_line]
                vim.current.buffer[current_line] = line_content[:current_col] + char + line_content[current_col:]
                current_col += 1
                vim.current.window.cursor = (current_line + 1, current_col)
        
        vim.command('redraw')
    
    print("Code updated successfully")
        
except Exception as e:
    print(f"Error: {str(e)}")
EOF
endfunction

nnoremap <leader>cc :call ClaudeCode()<CR>
vnoremap <leader>cc :call ClaudeCode()<CR>
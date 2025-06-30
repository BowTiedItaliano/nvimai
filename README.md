# Claude Code Vim Plugin

A Vim plugin that sends your entire file to Claude and replaces it with the code response.

## Installation

### Using vim-plug (recommended)
Add this to your `.vimrc`:
```vim
Plug 'your-username/nvim-plugin'
```

### Manual Installation
1. Copy the plugin files to your Vim runtime path:
   - `plugin/claude_code.vim` → `~/.vim/plugin/`
   - `claude_api.py` → `~/.vim/`

## Setup

1. Get your Anthropic API key from https://console.anthropic.com/
2. Set the environment variable:
   ```bash
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```
3. Add the export to your shell profile (`.bashrc`, `.zshrc`, etc.)

## Usage

1. Open a file in Vim
2. Write your code or request
3. Press `<leader>cc` (default: `\cc`)
4. The entire file content will be sent to Claude
5. Claude's code response will replace the file content

## Requirements

- Vim with Python 3 support
- Internet connection
- Anthropic API key

## Customization

You can change the key mapping by adding this to your `.vimrc`:
```vim
nnoremap <your-preferred-keys> :call ClaudeCode()<CR>
```
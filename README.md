# vim-tmuxlike

Bring familiar tmux-style prefix commands to Vim and Neovim.

If you regularly use tmux, this plugin provides a similar workflow for
navigating, splitting, resizing, and managing editor windows and tabs.


<!-- vim-markdown-toc GFM -->

* [Requirements](#requirements)
* [Usage](#usage)
    * [Windows](#windows)
    * [Resize mode](#resize-mode)
    * [Tabs](#tabs)
    * [Other commands](#other-commands)
* [Installation](#installation)
* [Configuration](#configuration)
    * [Prefix key](#prefix-key)
    * [Split keys](#split-keys)
    * [Message history](#message-history)
    * [Vim window chooser](#vim-window-chooser)
    * [Neovim Lua configuration](#neovim-lua-configuration)

<!-- vim-markdown-toc -->


## Requirements

- Vim with popup-window support for the interactive resize mode and built-in
  window chooser
- Neovim 0.11 or later for the Lua-powered resize mode, message window, and
  built-in window chooser

## Usage

Like tmux, vim-tmuxlike uses a prefix key. The default prefix is `Ctrl-A`.
Every command below starts with `<prefix>`.

### Windows

- `h`, `j`, `k`, `l` or the arrow keys: move to the window in that direction
- `;`: move to the previously selected window
- `z`: toggle zoom for the current window

  ![Toggle window zoom](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/toggle_zoom.gif)

- `%`: create a vertical split with a new buffer

  ![Create a vertical split](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/vsplit_new.gif)

- `|`: vertically split the current buffer

  ![Vertically split the current buffer](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/vsplit_cur.gif)

- `"`: create a horizontal split with a new buffer

  ![Create a horizontal split](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/split_new.gif)

- `_`: horizontally split the current buffer

  ![Horizontally split the current buffer](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/split_cur.gif)

- `x`: confirm and close the current window
- `!`: move the current file to a new tab

  ![Move the current file to a new tab](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/break_cur.gif)

- `Space`: cycle through even-horizontal, even-vertical, main-horizontal, and
  main-vertical layouts
- `{`: swap the current pane with the previous pane
- `}`: swap the current pane with the next pane

Pane swapping wraps at the beginning and end of the window list. Focus follows
the original pane content to its new position.

### Resize mode

Press `H`, `J`, `K`, or `L` to resize once and enter resize mode:

- `H`: increase the current window's width
- `L`: decrease the current window's width
- `J`: increase the current window's height
- `K`: decrease the current window's height
- `Esc`, `Enter`, or `q`: leave resize mode

While resize mode is active, other keys are ignored. A small status window
remains visible until the mode exits.

![Resize mode](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/resize_mode.gif)

### Tabs

- `c`: open a new tab after the last tab
- `Ctrl-H` or `Ctrl-P`: select the previous tab
- `Ctrl-N` or `Ctrl-L`: select the next tab
- `&`: confirm and close the current tab

### Other commands

- `?`: open the vim-tmuxlike help page
- `~`: show message history

  ![Show message history](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/hist_msg.gif)

- `d`: suspend Vim or Neovim, like `Ctrl-Z`
- `r`: redraw the screen
- `t`: display the current time
- `]`: paste from the system clipboard (`+` register)

- `q`, `s`, `=`: open the window chooser

Vim and Neovim both include a built-in chooser that displays a label over each
window. Press a label in lowercase or uppercase to select that window, or
press `q`/`Esc` to cancel.
When more than one tab exists, the chooser also displays a numbered tab bar;
press `1`–`9` to jump directly to a tab.

Chooser markers use static A–Z glyphs generated with TOIlet. The available
fonts are `smblock` (default) and `pagga`. Pane labels are assigned from the
preset character sequence `ABEFHIJKLMNOPRSTUVWXYZ`; `C`, `D`, `G`, and `Q`
are excluded.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'karmenzind/vim-tmuxlike'
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "karmenzind/vim-tmuxlike",
  config = function()
    require("tmuxlike").setup()
  end,
}
```

## Configuration

### Prefix key

The plugin uses `Ctrl-A` when no mapping to `<Plug>(tmuxlike-prefix)` already
exists. Define your own mapping to replace it:

```vim
" Ctrl-A (default)
nmap <C-A> <Plug>(tmuxlike-prefix)

" Ctrl-Backslash
nmap <C-\> <Plug>(tmuxlike-prefix)

" Press the leader key twice
nmap <Leader><Leader> <Plug>(tmuxlike-prefix)
```

Neovim users can configure the prefix through Lua instead:

```lua
require("tmuxlike").setup({
  prefix = "<C-a>",
})
```

### Split keys

The keys used to split the current buffer can be changed before the plugin is
loaded:

```vim
let g:tmuxlike_key_vsplit = '\'  " Default: |
let g:tmuxlike_key_hsplit = '-'  " Default: _
```

### Message history

Message history opens in a scratch buffer by default:

```vim
let g:tmuxlike_messages_container = 'scratch'
```

Supported values are:

- `scratch`: open message history in a scratch buffer
- `float`: open message history in a popup on Vim or a scrollable floating
  window on Neovim
- any other value: use the standard `:messages` display

### Vim window chooser

Vim users can configure the built-in chooser before the plugin is loaded:

```vim
let g:tmuxlike_chooser_scope = 'current'  " current or all
let g:tmuxlike_chooser_font = 'smblock'   " smblock or pagga
let g:tmuxlike_chooser_characters = 'ABEFHIJKLMNOPRSTUVWXYZ'
```

### Neovim Lua configuration

Neovim users can configure resize behavior, message display, the window
chooser, and every command key:

```lua
require("tmuxlike").setup({
  prefix = "<C-a>",
  resize_step = 3,
  messages = "float",
  chooser = {
    scope = "current", -- "current" or "all"
    font = "smblock",  -- "smblock" or "pagga"
    characters = "ABEFHIJKLMNOPRSTUVWXYZ",
  },
  mappings = {
    messages = "~",
    choose_window = { "q", "s", "=" },
    split_vertical = "|",
    split_horizontal = "_",
    resize_left = "H",
    resize_down = "J",
    resize_up = "K",
    resize_right = "L",
    next_layout = "<Space>",
    swap_pane_previous = "{",
    swap_pane_next = "}",
  },
})
```

Mapping values may be a key, a list of keys, or `false` to disable the
command. Available mapping names are:

```text
help, zoom, new_horizontal, split_horizontal, new_vertical, split_vertical,
new_tab, previous_tab, next_tab, close_window, close_tab, messages,
break_pane, suspend, redraw, time, paste, previous_window, window_left,
window_down, window_up, window_right, resize_left, resize_down, resize_up,
resize_right, choose_window, next_layout, swap_pane_previous, swap_pane_next
```

The existing `g:tmuxlike_key_vsplit`, `g:tmuxlike_key_hsplit`,
`g:tmuxlike_messages_container`, and `g:tmuxlike_chooser_scope` variables
remain supported as defaults. `g:tmuxlike_chooser_font` selects the Vim
chooser font and is also used as the Neovim default.
Chooser labels `c`, `d`, `g`, `q`, and digits are reserved and automatically
excluded. Digits `1`–`9` select tabs when multiple tabs are open. Explicitly
configuring `C`, `D`, `G`, or `Q` raises an error.
See [Known Issues](KNOWN_ISSUES.md) for details.

If you find a problem, please
[open an issue](https://github.com/Karmenzind/vim-tmuxlike/issues/new).

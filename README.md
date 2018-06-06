# vim-tmuxlike
Add tmux operating habits to vim.

If you are quite addicted to tmux, you might need this plugin to make your vim work a bit like tmux.

**current status: DEVELOPING**

## TOC

<!-- vim-markdown-toc GFM -->

* [Installation](#installation)
* [Intro](#intro)
    * [Prefix key](#prefix-key)
    * [Features](#features)
* [Config](#config)
* [Problem or advice](#problem-or-advice)

<!-- vim-markdown-toc -->

## Installation

- use [vim-plug](https://github.com/junegunn/vim-plug):
    ```
    Plug 'karmenzind/vim-tmuxlike'
    ```
- use [Vundle](https://github.com/VundleVim/Vundle.vim):
    ```
    Plugin 'karmenzind/vim-tmuxlike'
    ```

## Intro

### Prefix key

Just like `<prefix>`(usually CTRL-B) in tmux, there's a prefix key in vim-tmuxlike.<br>
I use `<c-a>`(CTRL-A) as the default prefix key. You need to change it if you have the same keymap in tmux.

### Features

**original**

You should be familiar with these basic operation.

Every keymap should start with `<prefix>`.

-   `?`   open vim-tmuxlike's helppage
-   `z`   toggle buffer zoom mode
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/toggle_zoom.gif)
-   `%`   split window; open new buffer oh the right side
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/vsplit_new.gif)
-   `|`   split current buffer oh the right side
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/vsplit_cur.gif)
-   `"`   vertically split window; open new buffer downside
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/split_new.gif)
-   `_`   split current buffer downside
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/split_cur.gif)
-   `c`   open a new tab with an empty window after the last tab
-   `<c-h>` `<c-p>`  select previous tab
    `n` `<c-n>` `<c-l>`  select next tab
-   `x`   close current buffer
-   `&`   close current tab
-   `~`   show history messages
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/hist_msg.gif)
-   `!`   break current buffer (move current buffer to new tabpage)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/break_cur.gif)
-   `d`   detach/suspend vim (the same as CTRL-Z)
-   `r`   redraw current buffer
-   `]`   paste [from register *]
-   `;`   choose last buffer
-   `h` `j` `k` `l` `Left` `Down` `Up` `Right`  change buffer
-   `H` `J` `K` `L`  resize current window 

These keymaps need [t9md/vim-choosewin](https://github.com/t9md/vim-choosewin) installed.
-   `q` `s` `=`  enter choosewin mode
    ![choose_win](https://raw.githubusercontent.com/Karmenzind/i/master/vim-tmuxlike/choose_win.gif)

## Config

Feel free to change the prefix key.
I recommend using a 'CTRL-' key combination which will be really convenient (e.g. with default prefix `<c-a>`, you just need to hold CTRL and type 'ah' for `<prefix><c-h>`).

```vim
" use CTRL-A (default)
nmap <c-a> <Plug>(tmuxlike-prefix)
" use CTRL-\ 
nmap <c-\> <Plug>(tmuxlike-prefix)
" use double leader (it will be `\\` if you haven't change the mapleader)
nmap <Leader><Leader> <Plug>(tmuxlike-prefix)
```

## Problem or advice

Please [create an issue](https://github.com/Karmenzind/vim-tmuxlike/issues/new) and I'll fix it ASAP.

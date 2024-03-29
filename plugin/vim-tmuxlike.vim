" Name: vim-tmuxlike
" Version: 0.1000000001
" Author: github.com/Karmenzind

" TODO:
"   make `resize` and `change tab` repeatable
"   more interative

if exists("g:loaded_vim_tmuxlike")
    finish
endif
let g:loaded_vim_tmuxlike = 1

" --------------------------------------------
" variables
" --------------------------------------------

let g:tmuxlike_key_vsplit = get(g:, 'tmuxlike_key_vsplit', '\|')
let g:tmuxlike_key_hsplit = get(g:, 'tmuxlike_key_hsplit', '_')

" --------------------------------------------
" funcs
" --------------------------------------------


" /* keymap */
function! s:TmuxLikeMap(mapfunc, key, value)
    let l:_f = a:mapfunc
    let l:_k = a:key
    let l:_v = a:value
    execute l:_f . ' <silent> <Plug>(tmuxlike-prefix)' . l:_k . ' ' . l:_v
endfunction

" --------------------------------------------
" others
" --------------------------------------------

function! s:ShowMessages()
  execute 'messages'
  " TODO (k): <2022-10-10>
endfunction

" --------------------------------------------
" buffers
" --------------------------------------------

function! s:ChooseBuffer()
  " TODO (k): <2022-10-10>
endfunction

" --------------------------------------------
" tabs
" --------------------------------------------

function! s:CloseCurrentTab()
  if tabpagenr('$') == 1
    let prompt = "Kill the last tab?"
  else
    let prompt = printf("Kill tab %d?", tabpagenr())
  endif

  let choice = confirm(prompt, "&Yes\n&No", 2, "Warning")
  if choice == 1
    if tabpagenr('$') == 1
      exec 'qa!'
    else
      exec 'tabclose'
    endif
  endif
endfunction

function! s:CloseCurrentWin()
   let choice = confirm(printf("Kill window %d?", winnr()), "&Yes\n&No", 2, "Warning")
   if choice == 1
     exec 'q'
   endif
endfunction

" --------------------------------------------
" maps
" --------------------------------------------

" /* tmux origin */
" help
call s:TmuxLikeMap('nnoremap', '?', ':help tmuxlike<CR>')
" toggle zoom
call s:TmuxLikeMap('nnoremap', 'z', ':call tmuxlike#ZoomToggle()<CR>')
" h split
call s:TmuxLikeMap('nnoremap', '"', ':new<CR>')
" call s:TmuxLikeMap('nnoremap', '_', ':split<CR>')
call s:TmuxLikeMap('nnoremap', g:tmuxlike_key_hsplit, ':split<CR>')
" v split
call s:TmuxLikeMap('nnoremap', '%', ':vnew<CR>')
" call s:TmuxLikeMap('nnoremap', '\|', ':vsplit<CR>')
call s:TmuxLikeMap('nnoremap', g:tmuxlike_key_vsplit, ':vsplit<CR>')
" new tab
call s:TmuxLikeMap('nnoremap', 'c', ':$tabnew<CR>')
" change tab
call s:TmuxLikeMap('nnoremap', '<c-h>', ':tabprevious<CR>')
call s:TmuxLikeMap('nnoremap', '<c-p>', ':tabprevious<CR>')
call s:TmuxLikeMap('nnoremap', '<n>', ':tabnext<CR>')
call s:TmuxLikeMap('nnoremap', '<c-l>', ':tabnext<CR>')
call s:TmuxLikeMap('nnoremap', '<c-n>', ':tabnext<CR>')
" confirm quit current buffer
call s:TmuxLikeMap('nnoremap', 'x', ':call tmuxlike#CloseCurrentWin()<CR>')
" confirm close current tab
call s:TmuxLikeMap('nnoremap', '&', ':call tmuxlike#CloseCurrentTab()<CR>')
" show history
call s:TmuxLikeMap('nnoremap', '~', ':call tmuxlike#ShowMessages()<CR>')
" break pane  TODO: how to move the unsaved buffer?
call s:TmuxLikeMap('nnoremap', '!', ':call tmuxlike#TabSplitAndCloseCurrentBuf()<CR>')
" detach
call s:TmuxLikeMap('nnoremap', 'd', ':suspend<CR>')
" refresh
call s:TmuxLikeMap('nnoremap', 'r', ':redraw<CR>')
" time
call s:TmuxLikeMap('nnoremap', 't', ':echom strftime("%c")<CR>')
" buffers
" call s:TmuxLikeMap('nnoremap', 'w', ':call <SID>ShowBuffers()<CR>')

" TODO:
" toggle layout
" call s:TmuxLikeMap('nnoremap', '<space>', '<c-w>r')
" rotate window
" call s:TmuxLikeMap('nnoremap', '<c-o>', '"+p')

" /* unnecessary tmux origin */
" paste (from system clipboard)
call s:TmuxLikeMap('nnoremap', ']', '"+p')
" last buffer
call s:TmuxLikeMap('nnoremap', ';', '<c-w>p')
" select buffer
call s:TmuxLikeMap('nnoremap', 'h', '<c-w>h')
call s:TmuxLikeMap('nnoremap', 'j', '<c-w>j')
call s:TmuxLikeMap('nnoremap', 'k', '<c-w>k')
call s:TmuxLikeMap('nnoremap', 'l', '<c-w>l')
call s:TmuxLikeMap('nnoremap', '<Left>', '<c-w>h')
call s:TmuxLikeMap('nnoremap', '<Down>', '<c-w>j')
call s:TmuxLikeMap('nnoremap', '<Up>', '<c-w>k')
call s:TmuxLikeMap('nnoremap', '<Right>', '<c-w>l')

" resize
if has('nvim')
  call s:TmuxLikeMap('nnoremap', 'H', '<c-w>5<')
  call s:TmuxLikeMap('nnoremap', 'J', '<c-w>5+')
  call s:TmuxLikeMap('nnoremap', 'K', '<c-w>5-')
  call s:TmuxLikeMap('nnoremap', 'L', '<c-w>5>')
else
  call s:TmuxLikeMap('nnoremap', 'H', '<cmd>call tmuxlike#EnterResizeMode("H")<CR>')
  call s:TmuxLikeMap('nnoremap', 'J', '<cmd>call tmuxlike#EnterResizeMode("J")<CR>')
  call s:TmuxLikeMap('nnoremap', 'K', '<cmd>call tmuxlike#EnterResizeMode("K")<CR>')
  call s:TmuxLikeMap('nnoremap', 'L', '<cmd>call tmuxlike#EnterResizeMode("L")<CR>')
endif

" /* choose-win */
call s:TmuxLikeMap('nmap', 'q', '<Plug>(choosewin)')
call s:TmuxLikeMap('nmap', 's', '<Plug>(choosewin)')
call s:TmuxLikeMap('nmap', '=', '<Plug>(choosewin)')

" --------------------------------------------
" Initial
" --------------------------------------------

nnoremap <silent> <c-w>= :call tmuxlike#MakeWinEqual()<CR>

if !hasmapto('<Plug>(tmuxlike-prefix)')
  nmap <silent> <c-a> <Plug>(tmuxlike-prefix)
endif


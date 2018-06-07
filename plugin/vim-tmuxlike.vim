" Name: vim-tmuxlike
" Version: 0.1
" Author: github.com/Karmenzind

" --------------------------------------------
" funcs
" --------------------------------------------
function! s:TabSplitAndCloseCurrentBuf()
  let l:curbuf = expand('%')
  quit
  exec 'tabe ' . l:curbuf
endfunction

function! s:ZoomToggle()
  if !exists('b:current_zoom_mode')
    let b:current_zoom_mode = '='
  endif

  if b:current_zoom_mode ==# '='
    " if has nerdtree
    if exists('g:loaded_nerd_tree')
      execute 'NERDTreeClose'
    endif

    silent! execute 'resize | vertical resize'
    let b:current_zoom_mode = '+'

  elseif b:current_zoom_mode ==# '+'
    execute "normal! \<c-w>="
    let b:current_zoom_mode = '='
  endif
endfunction


function! s:TmuxLikeMap(mapfunc, key, value)
    let l:_func=a:mapfunc
    let l:_key=a:key
    let l:_value = a:value
    execute l:_func . ' <silent> <Plug>(tmuxlike-prefix)' . l:_key . ' ' . l:_value
endfunction

" --------------------------------------------
" maps
" --------------------------------------------

" /* tmux origin */
" help
call s:TmuxLikeMap('nnoremap', '?', ':help tmuxlike<CR>')
" toggle zoom
call s:TmuxLikeMap('nnoremap', 'z', ':call <SID>ZoomToggle()<CR>')
" h split
call s:TmuxLikeMap('nnoremap', '"', ':new<CR>')
call s:TmuxLikeMap('nnoremap', '_', ':split<CR>')
" v split
call s:TmuxLikeMap('nnoremap', '%', ':vnew<CR>')
call s:TmuxLikeMap('nnoremap', '\|', ':vsplit<CR>')
" new tab
call s:TmuxLikeMap('nnoremap', 'c', ':$tabnew<CR>')
" change tab
call s:TmuxLikeMap('nnoremap', '<c-h>', ':tabprevious<CR>')
call s:TmuxLikeMap('nnoremap', '<c-p>', ':tabprevious<CR>')
call s:TmuxLikeMap('nnoremap', '<n>', ':tabnext<CR>')
call s:TmuxLikeMap('nnoremap', '<c-l>', ':tabnext<CR>')
call s:TmuxLikeMap('nnoremap', '<c-n>', ':tabnext<CR>')
" confirm quit current buffer
call s:TmuxLikeMap('nnoremap', 'x', ':conf q<CR>')
" close current tab
call s:TmuxLikeMap('nnoremap', '&', ':tabclose<CR>')
" show history
call s:TmuxLikeMap('nnoremap', '~', ':messages<CR>')
" break pane
call s:TmuxLikeMap('nnoremap', '!', ':call <SID>TabSplitAndCloseCurrentBuf()<CR>')
" detach
call s:TmuxLikeMap('nnoremap', 'd', ':suspend<CR>')
" refresh
call s:TmuxLikeMap('nnoremap', 'r', ':redraw<CR>')
" time
call s:TmuxLikeMap('nnoremap', 't', ':echom strftime("%c")<CR>')
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
call s:TmuxLikeMap('nnoremap', 'H', '<c-w>5<')
call s:TmuxLikeMap('nnoremap', 'J', '<c-w>5+')
call s:TmuxLikeMap('nnoremap', 'K', '<c-w>5-')
call s:TmuxLikeMap('nnoremap', 'L', '<c-w>5>')

" /* choose-win */
call s:TmuxLikeMap('nmap', 'q', '<Plug>(choosewin)')
call s:TmuxLikeMap('nmap', 's', '<Plug>(choosewin)')
call s:TmuxLikeMap('nmap', '=', '<Plug>(choosewin)')

" --------------------------------------------
" Initial
" --------------------------------------------

nnoremap <silent> <c-w>=  <c-w>=:let b:current_zoom_mode = '='<CR>

if !hasmapto('<Plug>(tmuxlike-prefix)')
  nmap <silent> <c-a> <Plug>(tmuxlike-prefix)
endif


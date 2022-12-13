


function! s:TabSplitAndCloseCurrentBuf()
  let l:curbuf = expand('%')
  confirm quit
  exec 'tabe ' . l:curbuf
endfunction

" /* zoom utils */
function! s:ResetTabZoomStatus()
  let t:tmuxlike_zoomed_win = v:null
endfunction

function! s:ZoomInCurrent()
  let l:ignored_fts = ['nerdtree', 'qf', 'tagbar']
  if index(l:ignored_fts, tolower(&ft)) >= 0
    echom 'Ignored filetype: ' . &ft | return
  endif
  for _c in ['NERDTreeClose', 'TagbarClose', 'cclose']
    silent! execute _c
  endfor
  silent! execute 'resize | vertical resize'
  let t:tmuxlike_zoomed_win = win_getid()
endfunction

function! tmuxlike#MakeWinEqual()
  execute "normal! \<c-w>="
  call s:ResetTabZoomStatus()
endfunction

" --------------------------------------------
" others
" --------------------------------------------

function! tmuxlike#ShowMessages()
  execute 'messages'
  return

  let m = execute("messages")
  if len(m) == 0
    echo "No history message."
  else
    execute "tabe"
    call append(0, m)
  endif
  return
  " TODO (k): <2022-10-10> 


  if has("nvim")
    execute 'messages'
    return
  endif
  if has("popupwin")
    let history = execute("messages")

    call popup_create(history, #{
      \ line: 1,
      \ col: 10,
      \ minwidth: 20,
      \ time: 30000,
      \ tabpage: -1,
      \ zindex: 300,
      \ drag: 1,
      \ highlight: 'WarningMsg',
      \ border: [],
      \ close: 'click',
      \ padding: [0,1,0,1],
      \ })
  endif
endfunction

" --------------------------------------------
" buffers
" --------------------------------------------

function! s:ChooseBuffer()
endfunction

" --------------------------------------------
" tabs
" --------------------------------------------

function! tmuxlike#CloseCurrentTab()
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

function! tmuxlike#CloseCurrentWin()
   let choice = confirm(printf("Kill window %d?", winnr()), "&Yes\n&No", 2, "Warning")
   if choice == 1
     exec 'q'
   endif
endfunction


" --------------------------------------------
" exposed
" --------------------------------------------


function! tmuxlike#ZoomToggle()
  if tabpagewinnr(tabpagenr(), '$') == 1
    call s:ResetTabZoomStatus() | return
  endif
  if !exists('t:tmuxlike_zoomed_win')
    call s:ResetTabZoomStatus()
  endif
  if t:tmuxlike_zoomed_win ==# win_getid()
    call s:MakeWinEqual()
  else
    call s:ZoomInCurrent()
  endif
endfunction


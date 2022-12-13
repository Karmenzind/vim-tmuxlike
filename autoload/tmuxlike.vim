
let s:messages_container = get(g:, 'tmuxlike_messages_container', 'scratch')


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

function! tmuxlike#ShowMessages() abort
  let history = execute("messages")
  if len(history) == 0
    echo "No history message."
    return
  endif

  if s:messages_container == "scratch"
    execute "new [Messages]"
    " let win = winnr()
    let buf = bufnr()

    call append(0, history)
    execute '%s/\v[\x0]/\r/g'

    call setbufvar(buf, "&buftype", "nofile")
    call setbufvar(buf, "&bufhidden", "hide")
    call setbufvar(buf, "&swapfile", "0")
    call setbufvar(buf, "&wrap", "1")
    call setbufvar(buf, "&ft", "messages")
  elseif s:messages_container == "float"
    if has("nvim")
      execute 'messages'
    endif
    if has("popupwin")
      let history = execute("messages")
      let lines = split(history, '[\x0]', 0)

      let msg_win = popup_create(lines, #{
        \ title: "Messages",
        \ line: 1,
        \ col: 10,
        \ minwidth: 20,
        \ time: 30000,
        \ tabpage: -1,
        \ zindex: 300,
        \ drag: 1,
        \ dragall: 1,
        \ highlight: 'WarningMsg',
        \ border: [1,1,1,1],
        \ padding: [0, 1, 0, 1],
        \ scrollbar: 1,
        \ pos: 'center',
        \ cursorline: 1,
        \ borderchars: ['-', '|', '-', '|', '┌', '┐', '┘', '└'],
        \ close: 'button',
        \ resize: 1,
        \ })
    endif
  else
    execute 'messages'
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


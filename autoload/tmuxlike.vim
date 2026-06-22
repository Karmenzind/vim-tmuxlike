
let s:messages_container = get(g:, 'tmuxlike_messages_container', 'scratch')


function! tmuxlike#TabSplitAndCloseCurrentBuf()
  let l:curbuf = expand('%:p')
  confirm quit
  if empty(l:curbuf)
    tabnew
  else
    execute 'tabe ' . fnameescape(l:curbuf)
  endif
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
  if has('nvim')
    call luaeval("require('tmuxlike.zoom').equalize()")
    return
  endif
  execute "normal! \<c-w>="
  call s:ResetTabZoomStatus()
endfunction

" --------------------------------------------
" layout and pane order
" --------------------------------------------

function! s:TabWinIds()
  return gettabinfo(tabpagenr())[0].windows
endfunction

function! s:LinearizeWindows(winids, command, current) abort
  for winid in a:winids[1:]
    if win_id2win(winid) != 0
      call win_gotoid(winid)
      execute 'wincmd ' . a:command
    endif
  endfor
  call win_gotoid(a:current)
endfunction

function! tmuxlike#CycleLayout() abort
  if has('nvim')
    return luaeval("require('tmuxlike.layout').cycle()")
  endif

  let winids = s:TabWinIds()
  if len(winids) < 2
    return 0
  endif

  let current = win_getid()
  let t:tmuxlike_layout_index = get(t:, 'tmuxlike_layout_index', 0) % 4 + 1
  if t:tmuxlike_layout_index == 1
    call s:LinearizeWindows(winids, 'L', current)
  elseif t:tmuxlike_layout_index == 2
    call s:LinearizeWindows(winids, 'J', current)
  elseif t:tmuxlike_layout_index == 3
    call s:LinearizeWindows(winids, 'L', current)
    wincmd K
  else
    call s:LinearizeWindows(winids, 'J', current)
    wincmd H
  endif
  wincmd =
  call win_gotoid(current)
  return 1
endfunction

function! tmuxlike#SwapPane(direction) abort
  if has('nvim')
    return luaeval("require('tmuxlike.pane').swap(_A)", a:direction)
  endif

  let winids = s:TabWinIds()
  if len(winids) < 2
    return 0
  endif

  let current = win_getid()
  let current_index = index(winids, current)
  if current_index < 0
    return 0
  endif

  let target_index = (current_index + a:direction) % len(winids)
  let target = winids[target_index]
  let current_buf = winbufnr(current)
  let target_buf = winbufnr(target)
  call win_execute(current, 'hide buffer ' . target_buf)
  call win_execute(target, 'hide buffer ' . current_buf)
  call win_gotoid(target)
  return 1
endfunction

" --------------------------------------------
" resize mode
" --------------------------------------------

let s:resizing_win = v:null

function! s:DoResize(key)
  if a:key == 'L'
    call execute('vertical' .. s:resizing_win .. "resize +3")
  elseif a:key == 'H'
    call execute('vertical' .. s:resizing_win.."resize -3")
  elseif a:key == 'J'
    call execute(s:resizing_win .. 'resize +3')
  elseif a:key == 'K'
    call execute(s:resizing_win .. 'resize -3')
  endif
endfunction

function! tmuxlike#ResizeModeFilter(winid, key) abort
  " echom "resizing win ".. s:resizing_win
  if a:key == 'q' || a:key == "\<ESC>" || a:key == "\<CR>"
    call popup_close(a:winid)
  else
    call s:DoResize(a:key)
  endif
  return 1
endfunction

let s:saved_map = v:null

function! tmuxlike#AfterResizing(...)
  if s:saved_map != v:null
			call mapset('n', 0, s:saved_map)
  endif
endfunction

function! tmuxlike#EnterResizeMode(key) abort
  if has('nvim')
    if !has('nvim-0.11')
      echoerr 'vim-tmuxlike resize mode requires Neovim 0.11 or newer'
      return
    endif
    call luaeval("require('tmuxlike.resize').start(_A)", a:key)
    return
  endif

  let s:saved_map = maparg('K', 'n', 0, 1)
  silent nunmap K

  let s:resizing_win = winnr()
  let text = ["Resizing...", "Press H/J/K/L to resize, ESC/ENTER/q to quit"]

  let popup_win = popup_create(text, #{
        \ line: 3,
        \ col: &columns - 1,
        \ pos: 'topright',
        \ zindex: 300,
        \ close: 'none',
        \ cursorline: v:true,
        \ border:[1,1,1,1],
        \ borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ highlight: 'Normal',
        \ borderhighlight: ['MoreMsg'],
        \ filtermode: 'a',
        \ filter: 'tmuxlike#ResizeModeFilter',
        \ callback: 'tmuxlike#AfterResizing',
        \})
  call s:DoResize(a:key)
endfunction

" --------------------------------------------
" others
" --------------------------------------------

function! tmuxlike#ShowMessages() abort
  if has('nvim')
    call luaeval("require('tmuxlike.messages').open()")
    return
  endif

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
" window chooser
" --------------------------------------------

let s:chooser_popups = []
let s:chooser_by_label = {}
let s:chooser_by_tab = {}
let s:chooser_active = v:false

" Generated with: toilet -f smblock <A-Z>
let s:chooser_glyphs = #{
      \ smblock: #{
      \ A: ['▞▀▖', '▙▄▌', '▌ ▌', '▘ ▘'],
      \ B: ['▛▀▖', '▙▄▘', '▌ ▌', '▀▀ '],
      \ C: ['▞▀▖', '▌  ', '▌ ▖', '▝▀ '],
      \ D: ['▛▀▖', '▌ ▌', '▌ ▌', '▀▀ '],
      \ E: ['▛▀▘', '▙▄ ', '▌  ', '▀▀▘'],
      \ F: ['▛▀▘', '▙▄ ', '▌  ', '▘  '],
      \ G: ['▞▀▖', '▌▄▖', '▌ ▌', '▝▀ '],
      \ H: ['▌ ▌', '▙▄▌', '▌ ▌', '▘ ▘'],
      \ I: ['▜▘', '▐ ', '▐ ', '▀▘'],
      \ J: [' ▜▘', ' ▐ ', '▌▐ ', '▝▘ '],
      \ K: ['▌ ▌', '▙▞ ', '▌▝▖', '▘ ▘'],
      \ L: ['▌  ', '▌  ', '▌  ', '▀▀▘'],
      \ M: ['▙▗▌', '▌▘▌', '▌ ▌', '▘ ▘'],
      \ N: ['▙ ▌', '▌▌▌', '▌▝▌', '▘ ▘'],
      \ O: ['▞▀▖', '▌ ▌', '▌ ▌', '▝▀ '],
      \ P: ['▛▀▖', '▙▄▘', '▌  ', '▘  '],
      \ Q: ['▞▀▖', '▌ ▌', '▌▚▘', '▝▘▘'],
      \ R: ['▛▀▖', '▙▄▘', '▌▚ ', '▘ ▘'],
      \ S: ['▞▀▖', '▚▄ ', '▖ ▌', '▝▀ '],
      \ T: ['▀▛▘', ' ▌ ', ' ▌ ', ' ▘ '],
      \ U: ['▌ ▌', '▌ ▌', '▌ ▌', '▝▀ '],
      \ V: ['▌ ▌', '▚▗▘', '▝▞ ', ' ▘ '],
      \ W: ['▌ ▌', '▌▖▌', '▙▚▌', '▘ ▘'],
      \ X: ['▌ ▌', '▝▞ ', '▞▝▖', '▘ ▘'],
      \ Y: ['▌ ▌', '▝▞ ', ' ▌ ', ' ▘ '],
      \ Z: ['▀▀▌', ' ▞ ', '▞  ', '▀▀▘'],
      \},
      \ pagga: #{
      \ A: ['░█▀█', '░█▀█', '░▀░▀'],
      \ B: ['░█▀▄', '░█▀▄', '░▀▀░'],
      \ C: ['░█▀▀', '░█░░', '░▀▀▀'],
      \ D: ['░█▀▄', '░█░█', '░▀▀░'],
      \ E: ['░█▀▀', '░█▀▀', '░▀▀▀'],
      \ F: ['░█▀▀', '░█▀▀', '░▀░░'],
      \ G: ['░█▀▀', '░█░█', '░▀▀▀'],
      \ H: ['░█░█', '░█▀█', '░▀░▀'],
      \ I: ['░▀█▀', '░░█░', '░▀▀▀'],
      \ J: ['░▀▀█', '░░░█', '░▀▀░'],
      \ K: ['░█░█', '░█▀▄', '░▀░▀'],
      \ L: ['░█░░', '░█░░', '░▀▀▀'],
      \ M: ['░█▄█', '░█░█', '░▀░▀'],
      \ N: ['░█▀█', '░█░█', '░▀░▀'],
      \ O: ['░█▀█', '░█░█', '░▀▀▀'],
      \ P: ['░█▀█', '░█▀▀', '░▀░░'],
      \ Q: ['░▄▀▄', '░█\█', '░░▀\'],
      \ R: ['░█▀▄', '░█▀▄', '░▀░▀'],
      \ S: ['░█▀▀', '░▀▀█', '░▀▀▀'],
      \ T: ['░▀█▀', '░░█░', '░░▀░'],
      \ U: ['░█░█', '░█░█', '░▀▀▀'],
      \ V: ['░█░█', '░▀▄▀', '░░▀░'],
      \ W: ['░█░█', '░█▄█', '░▀░▀'],
      \ X: ['░█░█', '░▄▀▄', '░▀░▀'],
      \ Y: ['░█░█', '░░█░', '░░▀░'],
      \ Z: ['░▀▀█', '░▄▀░', '░▀▀▀'],
      \},
      \}

function! s:ChooserGlyphSet() abort
  return get(s:chooser_glyphs, g:tmuxlike_chooser_font,
        \ s:chooser_glyphs.smblock)
endfunction

function! s:ChooserGlyphEntries() abort
  let result = []
  let glyphs = s:ChooserGlyphSet()
  let invalid = matchstr(toupper(g:tmuxlike_chooser_characters), '[CDGQ]')
  if !empty(invalid)
    throw 'vim-tmuxlike: chooser character ' . invalid . ' is reserved and cannot be configured'
  endif
  for character in split(g:tmuxlike_chooser_characters, '\zs')
    if has_key(glyphs, character)
      call add(result, #{
            \ label: tolower(character),
            \ glyph: glyphs[character],
            \})
    endif
  endfor
  return result
endfunction

function! s:ChooserGlyphWidth(glyphs) abort
  let width = g:tmuxlike_chooser_marker_width
  for entry in a:glyphs
    for line in entry.glyph
      let width = max([width, strdisplaywidth(line)])
    endfor
  endfor
  return width
endfunction

function! s:ChooserCenterGlyph(glyph, width) abort
  let lines = []
  for line in a:glyph
    let remaining = a:width - strdisplaywidth(line)
    let left = remaining / 2
    let right = remaining - left
    call add(lines, repeat(' ', left) . line . repeat(' ', right))
  endfor
  return lines
endfunction

function! s:ChooserClose() abort
  let s:chooser_active = v:false
  let popups = copy(s:chooser_popups)
  let s:chooser_popups = []
  let s:chooser_by_label = {}
  let s:chooser_by_tab = {}
  for popup in popups
    if !empty(popup_getpos(popup))
      silent! call popup_close(popup)
    endif
  endfor
endfunction

function! s:ChooserSelectTarget(target) abort
  let target = copy(a:target)
  call s:ChooserClose()
  if win_id2win(target.winid) != 0 || win_gotoid(target.winid)
    call win_gotoid(target.winid)
  endif
endfunction

function! s:ChooserSelectTab(tabnr) abort
  let tabnr = a:tabnr
  call s:ChooserClose()
  if tabnr >= 1 && tabnr <= tabpagenr('$')
    execute 'tabnext ' . tabnr
  endif
endfunction

function! tmuxlike#ChooserFilter(winid, key) abort
  if !s:chooser_active
    return 0
  endif
  let key = a:key ==# "\<Esc>" ? a:key : tolower(a:key)
  if key ==# 'q' || key ==# "\<Esc>"
    call s:ChooserClose()
  elseif has_key(s:chooser_by_tab, key)
    call s:ChooserSelectTab(s:chooser_by_tab[key])
  elseif has_key(s:chooser_by_label, key)
    call s:ChooserSelectTarget(s:chooser_by_label[key])
  endif
  return 1
endfunction

function! s:ChooserPopup(text, options) abort
  let options = extend(#{
        \ zindex: 310,
        \ border: [1, 1, 1, 1],
        \ borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ borderhighlight: ['IncSearch'],
        \ highlight: 'IncSearch',
        \ mapping: 0,
        \ filtermode: 'a',
        \ filter: 'tmuxlike#ChooserFilter',
        \ callback: 'tmuxlike#ChooserPopupClosed',
        \ close: 'none',
        \ wrap: 0,
        \}, a:options)
  let popup = popup_create(a:text, options)
  call add(s:chooser_popups, popup)
  return popup
endfunction

function! tmuxlike#ChooserPopupClosed(winid, result) abort
  if s:chooser_active
    call s:ChooserClose()
  endif
endfunction

function! s:ChooserShowTabs() abort
  if tabpagenr('$') <= 1
    return
  endif
  let parts = []
  for tabnr in range(1, min([tabpagenr('$'), 9]))
    let s:chooser_by_tab[string(tabnr)] = tabnr
    let winid = gettabinfo(tabnr)[0].windows[0]
    let name = bufname(winbufnr(winid))
    let name = empty(name) ? 'Tab ' . tabnr : fnamemodify(name, ':t')
    call add(parts, printf('%d:%s', tabnr, name))
  endfor
  call s:ChooserPopup(join(parts, '  '), #{
        \ title: ' Tabs ',
        \ line: 2,
        \ col: 2,
        \ minheight: 1,
        \ maxheight: 1,
        \ minwidth: min([&columns - 4, max([20, strdisplaywidth(join(parts, '  '))])]),
        \ maxwidth: &columns - 4,
        \ zindex: 320,
        \})
endfunction

function! s:ChooserCurrentTargets() abort
  let targets = []
  for winid in gettabinfo(tabpagenr())[0].windows
    let info = getwininfo(winid)
    if !empty(info)
      call add(targets, info[0])
    endif
  endfor
  return targets
endfunction

function! s:ChooserAllTargets() abort
  let targets = []
  for tab in gettabinfo()
    let index = 0
    for winid in tab.windows
      let index += 1
      call add(targets, #{
            \ tabnr: tab.tabnr,
            \ winnr: index,
            \ winid: winid,
            \ bufnr: winbufnr(winid),
            \})
    endfor
  endfor
  return targets
endfunction

function! s:ChooserShowCurrent(targets, glyphs) abort
  let marker_width = s:ChooserGlyphWidth(a:glyphs)
  for index in range(len(a:targets))
    if index >= len(a:targets)
      break
    endif
    let target = a:targets[index]
    let entry = a:glyphs[index]
    let s:chooser_by_label[entry.label] = #{winid: target.winid, tabnr: target.tabnr}
    let glyph = s:ChooserCenterGlyph(entry.glyph, marker_width)
    let glyph_width = marker_width
    let glyph_height = len(glyph)
    let line = target.winrow + max([0, (target.height - glyph_height) / 2])
    let col = target.wincol + max([0, (target.width - glyph_width) / 2])
    call s:ChooserPopup(glyph, #{
          \ line: line,
          \ col: col,
          \ minwidth: glyph_width,
          \ maxwidth: glyph_width,
          \ minheight: glyph_height,
          \ maxheight: glyph_height,
          \ fixed: 1,
          \})
  endfor
endfunction

function! s:ChooserShowAll(targets, glyphs) abort
  let lines = []
  for index in range(len(a:targets))
    if index >= len(a:targets)
      break
    endif
    let target = a:targets[index]
    let entry = a:glyphs[index]
    let label = entry.label
    let s:chooser_by_label[label] = #{winid: target.winid, tabnr: target.tabnr}
    let name = bufname(target.bufnr)
    let name = empty(name) ? '[No Name]' : fnamemodify(name, ':~:.')
    call add(lines, printf(' %s  tab %d, window %d  %s',
          \ label, target.tabnr, target.winnr, name))
  endfor
  call s:ChooserPopup(lines, #{
        \ title: ' Select Window ',
        \ pos: 'center',
        \ minwidth: min([&columns - 4, 30]),
        \ maxwidth: max([20, float2nr(&columns * 0.8)]),
        \ maxheight: max([3, float2nr(&lines * 0.7)]),
        \})
endfunction

function! tmuxlike#ChooseWindow(...) abort
  if has('nvim')
    return luaeval("require('tmuxlike.chooser').start(_A)", a:0 ? a:1 : {})
  endif
  if !has('popupwin')
    echoerr 'vim-tmuxlike window chooser requires Vim with +popupwin'
    return 0
  endif

  call s:ChooserClose()
  let scope = a:0 ? get(a:1, 'scope', g:tmuxlike_chooser_scope) : g:tmuxlike_chooser_scope
  try
    let glyphs = s:ChooserGlyphEntries()
  catch /^vim-tmuxlike:/
    echoerr v:exception
    return 0
  endtry
  let targets = scope ==# 'all' ? s:ChooserAllTargets() : s:ChooserCurrentTargets()
  if empty(targets)
    return 0
  endif
  if len(targets) > len(glyphs)
    echohl WarningMsg
    echom "You've opened too many windows. Are you here to cause trouble?"
    echohl None
    return 0
  endif

  let s:chooser_active = v:true
  if scope ==# 'all'
    call s:ChooserShowAll(targets, glyphs)
  else
    call s:ChooserShowCurrent(targets, glyphs)
  endif
  call s:ChooserShowTabs()
  return 1
endfunction

function! tmuxlike#ChooserState() abort
  return #{
        \ active: s:chooser_active,
        \ popups: copy(s:chooser_popups),
        \ by_label: copy(s:chooser_by_label),
        \ by_tab: copy(s:chooser_by_tab),
        \}
endfunction

function! tmuxlike#ChooserGlyph(label) abort
  let glyphs = s:ChooserGlyphSet()
  return has_key(glyphs, toupper(a:label))
        \ ? copy(glyphs[toupper(a:label)])
        \ : []
endfunction

function! tmuxlike#ChooserCenteredGlyph(label) abort
  let glyph = tmuxlike#ChooserGlyph(a:label)
  if empty(glyph)
    return []
  endif
  return s:ChooserCenterGlyph(glyph,
        \ s:ChooserGlyphWidth(s:ChooserGlyphEntries()))
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
  if has('nvim')
    call luaeval("require('tmuxlike.zoom').toggle()")
    return
  endif
  if tabpagewinnr(tabpagenr(), '$') == 1
    call s:ResetTabZoomStatus() | return
  endif
  if !exists('t:tmuxlike_zoomed_win')
    call s:ResetTabZoomStatus()
  endif
  if t:tmuxlike_zoomed_win ==# win_getid()
    call tmuxlike#MakeWinEqual()
  else
    call s:ZoomInCurrent()
  endif
endfunction

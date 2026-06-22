set rtp^=.
runtime plugin/vim-tmuxlike.vim

call assert_match('tmuxlike#CycleLayout', maparg('<Plug>(tmuxlike-prefix)<Space>', 'n'))
call assert_match('tmuxlike#SwapPane(-1)', maparg('<Plug>(tmuxlike-prefix){', 'n'))
call assert_match('tmuxlike#SwapPane(1)', maparg('<Plug>(tmuxlike-prefix)}', 'n'))
call assert_match('tmuxlike#ChooseWindow', maparg('<Plug>(tmuxlike-prefix)q', 'n'))
call assert_match('tmuxlike#ChooseWindow', maparg('<Plug>(tmuxlike-prefix)s', 'n'))
call assert_match('tmuxlike#ChooseWindow', maparg('<Plug>(tmuxlike-prefix)=', 'n'))
call assert_notmatch('choosewin', maparg('<Plug>(tmuxlike-prefix)q', 'n'))
for letter in split('abcdefghijklmnopqrstuvwxyz', '\zs')
  let glyph = tmuxlike#ChooserGlyph(letter)
  call assert_equal(4, len(glyph))
  let centered = tmuxlike#ChooserCenteredGlyph(letter)
  call assert_equal(4, len(centered))
  call assert_equal(1, len(uniq(sort(map(copy(centered), {_, line -> strdisplaywidth(line)})))))
endfor
let g:tmuxlike_chooser_font = 'pagga'
for letter in split('abcdefghijklmnopqrstuvwxyz', '\zs')
  let glyph = tmuxlike#ChooserGlyph(letter)
  call assert_equal(3, len(glyph))
  let centered = tmuxlike#ChooserCenteredGlyph(letter)
  call assert_equal(3, len(centered))
  call assert_equal(1, len(uniq(sort(map(copy(centered), {_, line -> strdisplaywidth(line)})))))
endfor
silent! only
vsplit
call assert_true(tmuxlike#ChooseWindow())
call assert_equal(3, popup_getpos(tmuxlike#ChooserState().popups[0]).core_height)
call feedkeys('q', 'xt')
let g:tmuxlike_chooser_font = 'smblock'

silent! only
vsplit
let g:chooser_wins = gettabinfo(tabpagenr())[0].windows
call assert_true(tmuxlike#ChooseWindow())
let g:chooser_state = tmuxlike#ChooserState()
call assert_true(g:chooser_state.active)
call assert_equal(2, len(g:chooser_state.popups))
call assert_false(has_key(g:chooser_state.by_label, 'd'))
call assert_false(has_key(g:chooser_state.by_label, 'g'))
call assert_false(has_key(g:chooser_state.by_label, 'c'))
call assert_false(has_key(g:chooser_state.by_label, 'q'))
call assert_equal(4, popup_getpos(g:chooser_state.popups[0]).core_height)
call assert_equal(4, popup_getpos(g:chooser_state.popups[0]).core_width)
call assert_equal(['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
      \ popup_getoptions(g:chooser_state.popups[0]).borderchars)
call assert_equal('IncSearch', popup_getoptions(g:chooser_state.popups[0]).highlight)
let g:chooser_target = g:chooser_state.by_label.b.winid
call feedkeys('B', 'xt')
call assert_equal(g:chooser_target, win_getid())
call assert_false(tmuxlike#ChooserState().active)
call assert_equal([], tmuxlike#ChooserState().popups)

call assert_true(tmuxlike#ChooseWindow())
let g:chooser_state = tmuxlike#ChooserState()
call assert_false(has_key(g:chooser_state.by_label, 'd'))
call assert_false(has_key(g:chooser_state.by_label, 'g'))
call feedkeys('q', 'xt')
call assert_false(tmuxlike#ChooserState().active)

call assert_true(tmuxlike#ChooseWindow())
let g:chooser_popup = tmuxlike#ChooserState().popups[0]
call popup_close(g:chooser_popup)
call assert_false(tmuxlike#ChooserState().active)
call assert_equal([], tmuxlike#ChooserState().popups)

tabnew
call assert_true(tmuxlike#ChooseWindow(#{scope: 'all'}))
let g:chooser_state = tmuxlike#ChooserState()
call assert_true(has_key(g:chooser_state.by_tab, '1'))
call assert_true(has_key(g:chooser_state.by_tab, '2'))
call assert_equal(2, len(g:chooser_state.popups))
call feedkeys('1', 'xt')
call assert_equal(1, tabpagenr())
call assert_false(tmuxlike#ChooserState().active)

call assert_true(tmuxlike#ChooseWindow(#{scope: 'all'}))
let g:chooser_state = tmuxlike#ChooserState()
let g:all_target = g:chooser_state.by_label.b
call feedkeys('b', 'xt')
call assert_equal(g:all_target.winid, win_getid())
call assert_equal(g:all_target.tabnr, tabpagenr())
call assert_false(tmuxlike#ChooserState().active)

silent! only
vsplit
split
wincmd h
split
let g:layout_current = win_getid()

call assert_true(tmuxlike#CycleLayout())
call assert_equal('row', winlayout()[0])
call assert_equal(4, len(winlayout()[1]))
call assert_equal(g:layout_current, win_getid())

call assert_true(tmuxlike#CycleLayout())
call assert_equal('col', winlayout()[0])
call assert_equal(4, len(winlayout()[1]))

call assert_true(tmuxlike#CycleLayout())
call assert_equal('col', winlayout()[0])

call assert_true(tmuxlike#CycleLayout())
call assert_equal('row', winlayout()[0])

silent! only
vsplit
let g:wins = gettabinfo(tabpagenr())[0].windows
let g:previous_win = g:wins[0]
let g:current_win = g:wins[1]
let g:previous_buf = bufadd('[tmuxlike-previous]')
let g:current_buf = bufadd('[tmuxlike-current]')
call bufload(g:previous_buf)
call bufload(g:current_buf)
call win_execute(g:previous_win, 'buffer ' . g:previous_buf)
call win_execute(g:current_win, 'buffer ' . g:current_buf)
call win_gotoid(g:current_win)

call assert_true(tmuxlike#SwapPane(-1))
call assert_equal(g:previous_win, win_getid())
call assert_equal(g:current_buf, bufnr())
call assert_equal(g:previous_buf, winbufnr(g:current_win))

call assert_true(tmuxlike#SwapPane(1))
call assert_equal(g:current_win, win_getid())

for invalid in ['C', 'd', 'G', 'q']
  let g:tmuxlike_chooser_characters = 'AB' . invalid
  try
    call tmuxlike#ChooseWindow()
    call assert_report('Expected reserved chooser character error for ' . invalid)
  catch /^Vim(echoerr):vim-tmuxlike: chooser character/
    call assert_match('chooser character ' . toupper(invalid) . ' is reserved', v:exception)
  endtry
endfor
let g:tmuxlike_chooser_characters = 'ABEFHIJKLMNOPRSTUVWXYZ'

tabnew
set winminwidth=1
for _ in range(23)
  vsplit
endfor
call assert_equal(24, winnr('$'))
messages clear
call assert_false(tmuxlike#ChooseWindow())
call assert_match("You've opened too many windows. Are you here to cause trouble?", execute('messages'))
call assert_false(tmuxlike#ChooserState().active)

if !empty(v:errors)
  echoerr join(v:errors, "\n")
  cquit
endif

qa!

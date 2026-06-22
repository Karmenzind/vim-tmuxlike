set rtp^=.
runtime plugin/vim-tmuxlike.vim

for key in ['H', 'J', 'K', 'L']
  call assert_match('tmuxlike.resize.*' . key, maparg('<Plug>(tmuxlike-prefix)' . key, 'n'))
endfor
call assert_match('tmuxlike.layout', maparg('<Plug>(tmuxlike-prefix)<Space>', 'n'))
call assert_match('tmuxlike.pane.*-1', maparg('<Plug>(tmuxlike-prefix){', 'n'))
call assert_match('tmuxlike.pane.*1', maparg('<Plug>(tmuxlike-prefix)}', 'n'))
for letter in split('abcdefghijklmnopqrstuvwxyz', '\zs')
  call assert_equal(4, luaeval("#require('tmuxlike.chooser')._marker_glyph(_A)", letter))
  call assert_equal(4, luaeval("#require('tmuxlike.chooser')._centered_marker_glyph(_A)", letter))
endfor
lua require('tmuxlike').setup({ chooser = { font = 'pagga' } })
for letter in split('abcdefghijklmnopqrstuvwxyz', '\zs')
  call assert_equal(3, luaeval("#require('tmuxlike.chooser')._marker_glyph(_A)", letter))
  call assert_equal(3, luaeval("#require('tmuxlike.chooser')._centered_marker_glyph(_A)", letter))
endfor
silent! only
vsplit
call assert_true(luaeval("require('tmuxlike.chooser').start({ scope = 'current' })"))
call assert_equal(3, luaeval("vim.api.nvim_win_get_height(require('tmuxlike.chooser')._state().markers[1].win)"))
lua require('tmuxlike.chooser').stop()
lua require('tmuxlike').setup({ chooser = { font = 'smblock' } })

silent! only
vsplit
split
wincmd h
split
let g:layout_current = win_getid()
call assert_equal('even-horizontal', luaeval("require('tmuxlike.layout').cycle()"))
call assert_equal('row', luaeval("vim.fn.winlayout()[1]"))
call assert_equal(4, luaeval("#vim.fn.winlayout()[2]"))
call assert_equal(g:layout_current, win_getid())
call assert_equal('even-vertical', luaeval("require('tmuxlike.layout').cycle()"))
call assert_equal('col', luaeval("vim.fn.winlayout()[1]"))
call assert_equal(4, luaeval("#vim.fn.winlayout()[2]"))
call assert_equal('main-horizontal', luaeval("require('tmuxlike.layout').cycle()"))
call assert_equal('col', luaeval("vim.fn.winlayout()[1]"))
call assert_equal('main-vertical', luaeval("require('tmuxlike.layout').cycle()"))
call assert_equal('row', luaeval("vim.fn.winlayout()[1]"))

silent! only
vsplit
lua << EOF
local wins = vim.api.nvim_tabpage_list_wins(0)
local previous_buf = vim.api.nvim_create_buf(false, true)
local current_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_win_set_buf(wins[1], previous_buf)
vim.api.nvim_win_set_buf(wins[2], current_buf)
vim.api.nvim_set_current_win(wins[2])
vim.g.swap_previous_win = wins[1]
vim.g.swap_previous_buf = previous_buf
vim.g.swap_current_win = wins[2]
vim.g.swap_current_buf = current_buf
EOF
call assert_true(luaeval("require('tmuxlike.pane').swap(-1)"))
call assert_equal(g:swap_previous_win, win_getid())
call assert_equal(g:swap_current_buf, bufnr())
call assert_equal(g:swap_previous_buf, winbufnr(g:swap_current_win))
call assert_true(luaeval("require('tmuxlike.pane').swap(1)"))
call assert_equal(g:swap_current_win, win_getid())

new
call tmuxlike#ZoomToggle()
call assert_equal(win_getid(), luaeval("require('tmuxlike.zoom')._state().tabs[vim.api.nvim_get_current_tabpage()]"))
call tmuxlike#ZoomToggle()
call assert_equal(v:null, luaeval("require('tmuxlike.zoom')._state().tabs[vim.api.nvim_get_current_tabpage()]"))

silent! only
split
let g:initial_height = winheight(0)
call tmuxlike#EnterResizeMode('J')
call assert_true(winheight(0) > g:initial_height)
let g:height_after_j = winheight(0)
call feedkeys('K', 'xt')
call wait(1000, {-> winheight(0) < g:height_after_j}, 10)
call assert_true(winheight(0) < g:height_after_j)
call feedkeys('q', 'xt')
call wait(1000, {-> !luaeval("require('tmuxlike.resize')._state().active")}, 10)

silent! only
vsplit
let g:target_win = win_getid()
let g:initial_width = winwidth(0)
call feedkeys("\<C-A>H", 'xt')
call wait(1000, {-> luaeval("require('tmuxlike.resize')._state().active")}, 10)
call assert_true(luaeval("require('tmuxlike.resize')._state().active"))
call assert_true(luaeval("vim.api.nvim_win_is_valid(require('tmuxlike.resize')._state().float_win)"))
call assert_true(winwidth(0) > g:initial_width)

let g:width_after_h = winwidth(0)
call feedkeys('L', 'xt')
call wait(1000, {-> winwidth(win_id2win(g:target_win)) < g:width_after_h}, 10)
call assert_true(winwidth(win_id2win(g:target_win)) < g:width_after_h)

let g:unexpected_key_ran = 0
nnoremap x <cmd>let g:unexpected_key_ran = 1<CR>
call feedkeys('x', 'xt')
call wait(50, {-> 0}, 10)
call assert_true(luaeval("require('tmuxlike.resize')._state().active"))
call assert_equal(0, g:unexpected_key_ran)

call feedkeys('q', 'xt')
call wait(1000, {-> !luaeval("require('tmuxlike.resize')._state().active")}, 10)
call assert_false(luaeval("require('tmuxlike.resize')._state().active"))

call tmuxlike#EnterResizeMode('H')
call feedkeys("\<Esc>", 'xt')
call wait(1000, {-> !luaeval("require('tmuxlike.resize')._state().active")}, 10)
call assert_false(luaeval("require('tmuxlike.resize')._state().active"))

call tmuxlike#EnterResizeMode('H')
call feedkeys("\<CR>", 'xt')
call wait(1000, {-> !luaeval("require('tmuxlike.resize')._state().active")}, 10)
call assert_false(luaeval("require('tmuxlike.resize')._state().active"))

call tmuxlike#EnterResizeMode('H')
let g:old_float_win = luaeval("require('tmuxlike.resize')._state().float_win")
call tmuxlike#EnterResizeMode('L')
call assert_false(nvim_win_is_valid(g:old_float_win))
call assert_true(luaeval("require('tmuxlike.resize')._state().active"))

let g:closed_target_win = luaeval("require('tmuxlike.resize')._state().target_win")
call nvim_win_close(g:closed_target_win, v:true)
call wait(1000, {-> !luaeval("require('tmuxlike.resize')._state().active")}, 10)
call assert_false(luaeval("require('tmuxlike.resize')._state().active"))

lua require('tmuxlike').setup({ messages = 'float', resize_step = 5 })
silent! only
vsplit
call tmuxlike#EnterResizeMode('H')
let g:width_before_apply = winwidth(0)
lua require('tmuxlike.resize').apply('H')
call assert_equal(g:width_before_apply + 5, winwidth(0))
lua require('tmuxlike.resize').stop()

echom 'tmuxlike test message'
call assert_true(luaeval("require('tmuxlike.messages').open()"))
call assert_true(luaeval("vim.api.nvim_win_is_valid(require('tmuxlike.messages')._state().win)"))
lua require('tmuxlike.messages').close()
call assert_equal(v:null, luaeval("require('tmuxlike.messages')._state().win"))

new
silent! only
vsplit
call feedkeys("\<C-A>q", 'xt')
call wait(1000, {-> luaeval("require('tmuxlike.chooser')._state().active")}, 10)
call assert_true(luaeval("require('tmuxlike.chooser')._state().active"))
call assert_equal(2, luaeval("#require('tmuxlike.chooser')._state().markers"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().by_label['d']"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().by_label['g']"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().by_label['c']"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().by_label['q']"))
call assert_equal(4, luaeval("vim.api.nvim_win_get_height(require('tmuxlike.chooser')._state().markers[1].win)"))
call assert_equal(4, luaeval("vim.api.nvim_win_get_width(require('tmuxlike.chooser')._state().markers[1].win)"))
call assert_equal(['╭', '─', '╮', '│', '╯', '─', '╰', '│'],
      \ luaeval("vim.api.nvim_win_get_config(require('tmuxlike.chooser')._state().markers[1].win).border"))
call assert_equal('Normal:IncSearch,FloatBorder:IncSearch', luaeval("vim.wo[require('tmuxlike.chooser')._state().markers[1].win].winhighlight"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().tabs_win"))
let g:chosen_win = luaeval("require('tmuxlike.chooser')._state().by_label['b'].win")
call feedkeys('B', 'xt')
call assert_equal(g:chosen_win, win_getid())
call assert_false(luaeval("require('tmuxlike.chooser')._state().active"))

call assert_true(luaeval("require('tmuxlike.chooser').start({ scope = 'current' })"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().by_label['d']"))
call assert_equal(v:null, luaeval("require('tmuxlike.chooser')._state().by_label['g']"))
lua require('tmuxlike.chooser').stop()

silent! only
vsplit
split
wincmd h
split
call assert_true(luaeval("require('tmuxlike.chooser').start({ scope = 'current' })"))
let g:chosen_e_win = luaeval("require('tmuxlike.chooser')._state().by_label['e'].win")
call feedkeys('e', 'xt')
call assert_equal(g:chosen_e_win, win_getid())
call assert_false(luaeval("require('tmuxlike.chooser')._state().active"))

call tmuxlike#EnterResizeMode('H')
call assert_true(luaeval("require('tmuxlike.resize')._state().active"))
call assert_true(luaeval("require('tmuxlike.chooser').start({ scope = 'current' })"))
call assert_false(luaeval("require('tmuxlike.resize')._state().active"))
lua require('tmuxlike.chooser').stop()

tabnew
call assert_true(luaeval("require('tmuxlike.chooser').start({ scope = 'all' })"))
call assert_true(luaeval("vim.api.nvim_win_is_valid(require('tmuxlike.chooser')._state().list_win)"))
call assert_true(luaeval("vim.api.nvim_win_is_valid(require('tmuxlike.chooser')._state().tabs_win)"))
let g:chosen_tab = luaeval("require('tmuxlike.chooser')._state().by_tab_number['1']")
call feedkeys('1', 'xt')
call assert_false(luaeval("require('tmuxlike.chooser')._state().active"))
call assert_equal(g:chosen_tab, nvim_get_current_tabpage())

lua require('tmuxlike').setup({ prefix = '<C-g>', mappings = { messages = 'm', choose_window = 'w', resize_left = false } })
call assert_equal('<Plug>(tmuxlike-prefix)', maparg('<C-g>', 'n'))
call assert_equal('', maparg('<C-a>', 'n'))
call assert_match('tmuxlike.messages', maparg('<Plug>(tmuxlike-prefix)m', 'n'))
call assert_match('tmuxlike.chooser', maparg('<Plug>(tmuxlike-prefix)w', 'n'))
call assert_equal('', maparg('<Plug>(tmuxlike-prefix)H', 'n'))

lua << EOF
for _, character in ipairs({ "C", "d", "G", "q" }) do
  local ok, err = pcall(require("tmuxlike").setup, {
    chooser = { characters = "AB" .. character },
  })
  assert(not ok)
  assert(err:match("chooser character " .. character:upper() .. " is reserved"))
end
EOF

tabnew
set winminwidth=1
for _ in range(23)
  vsplit
endfor
call assert_equal(24, winnr('$'))
lua << EOF
local notify = vim.notify
vim.notify = function(message)
  vim.g.tmuxlike_chooser_easter_egg = message
end
vim.g.tmuxlike_chooser_overflow_result = require("tmuxlike.chooser").start()
vim.notify = notify
EOF
call assert_false(g:tmuxlike_chooser_overflow_result)
call assert_equal("You've opened too many windows. Are you here to cause trouble?", g:tmuxlike_chooser_easter_egg)
call assert_false(luaeval("require('tmuxlike.chooser')._state().active"))

if !empty(v:errors)
  echoerr join(v:errors, "\n")
  cquit
endif

qa!

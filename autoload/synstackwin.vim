let s:bnr = bufadd('+<synstack>')
let s:paused = v:false
hi def link synstackDelimiter Delimiter
hi def link synstackIdentifier Identifier
call setbufvar(s:bnr, '&modifiable', 0)
call setbufvar(s:bnr, '&hidden', 1)
call setbufvar(s:bnr, '&buflisted', 0)
call setbufvar(s:bnr, '&swapfile', 0)
call setbufvar(s:bnr, '&buftype', 'nowrite')
call setbufvar(s:bnr, '&bufhidden', 'delete')
call setbufvar(s:bnr, '&spell', 0)
call setbufvar(s:bnr, '&number', 0)
call setbufvar(s:bnr, '&relativenumber', 0)

function! s:update_synstack()
	if bufnr('%') == s:bnr || s:paused
		return
	endif
	let s:stack = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
	call setbufvar(s:bnr, '&modifiable', 1)
	call setbufline(s:bnr, 1, join(s:stack, ' > '))
	call setbufvar(s:bnr, '&modifiable', 0)
endfunction

function! s:set_buf_settings()
	syn clear
	syn match synstackDelimiter /\V>/
	syn match synstackIdentifier /[^> ]\+/
endfunction

function! synstackwin#focus()
	let l:paused = s:paused
	let s:paused = v:true
	if bufwinnr(s:bnr) == -1
		new
		wincmd L
		exe s:bnr . 'buffer'
	else
		exe bufwinnr(s:bnr) . 'wincmd w'
	endif
	let s:paused = l:paused
endfunction

function! synstackwin#pause()
	let s:paused = v:true
endfunction

function! synstackwin#unpause()
	let s:paused = v:false
endfunction

aug synstack
	au!
	au CursorMoved * call s:update_synstack()
	au CursorMovedI * call s:update_synstack()
	au BufEnter +<synstack> ++once call s:set_buf_settings()
aug END

" 
" Keep versions of files in EECS 482 github repos
"

" return relative time
function version482#RelTime()
    return(reltimestr(reltime())->substitute('\.\(...\).*', '\1', '') / 1000)
endfunction

let s:startTimeAbs = localtime()
let s:startTimeRel = version482#RelTime()

" return absolute time
function version482#Time()
    return(s:startTimeAbs + (version482#RelTime() - s:startTimeRel))
endfunction

let s:version = 'vim-20250808'
let s:minTimeInterval = 1	" minimum time between versions
let s:username = substitute($USER, "[^a-zA-Z0-9]", "", "g")

let s:hash = {}			" last hash value for each version file
let s:size = {}			" last size for each version file
let s:prior = {}		" prior contents for each file
let s:priorTime = {}		" last time each file was written

let s:sessionStart = version482#Time()
let s:hashInitial = sha256(s:username . ' ' . s:sessionStart)
let s:timerStarted = 0

let s:versionDir = {}	" .version482 directory name for each source file directory

autocmd BufReadPost * call version482#NewBuffer()
autocmd BufWritePre * call version482#WriteBuffer()
autocmd TextChanged,TextChangedI * call version482#TextChanged()

" see if directory is in an EECS 482 git repo
" store .version482 directory name in s:versionDir, and make sure the
" .version482 directory exists
function version482#initVersionDir(dirname)
    if ! has_key(s:versionDir, a:dirname)
	let l:out = system('cd "' . a:dirname . '" ; git remote -v')
	if v:shell_error || stridx(l:out, 'eecs482') < 0
	    let s:versionDir[a:dirname] = ''
	else
	    let s:versionDir[a:dirname] = fnamemodify(systemlist('cd "' . a:dirname . '" ; git rev-parse --show-toplevel')[0], ':p') . '.version482'

	    if ! isdirectory(s:versionDir[a:dirname])
		" try to make the .version482 directory
		call mkdir(s:versionDir[a:dirname])
		if ! isdirectory(s:versionDir[a:dirname])
		    let s:versionDir[a:dirname] = ''
		endif
	    endif
	endif
    endif
endfunction

function version482#NewBuffer()
    if ! has('nvim')
	" helps remove display glitches on startup
	sleep 100m
    endif
    call version482#initVersionDir(fnamemodify(expand('%'), ':p:h'))
endfunction

" add the version directory for the current file to git
function version482#WriteBuffer()
    let l:dirname = fnamemodify(expand('%'), ':p:h')

    call version482#initVersionDir(l:dirname)

    " make sure file is in an EECS 482 git repo
    if s:versionDir[l:dirname] == ''
        return
    endif

    call system('cd "' . l:dirname . '"; git add "' . s:versionDir[l:dirname] . '"')

endfunction

function version482#TextChanged()
    let l:now = version482#Time()
    let l:filename = fnamemodify(expand('%'), ':p')

    " Limit the rate of versioning events.  First event is not saved because
    " it happens at startup and causes display glitches.  Also log events where
    " time has gone backward by more than minTimeInterval.
    if ! has_key(s:priorTime, l:filename) || abs(l:now - s:priorTime[l:filename]) < s:minTimeInterval

	if ! has_key(s:priorTime, l:filename)
	    let s:priorTime[l:filename] = l:now
	endif

	" make sure this version is eventually saved
	" replace any pending timer event, so these don't pile up
	if s:timerStarted
	    call timer_stop(s:timer)
	endif
	let s:timerStarted = 1
	let s:timer = timer_start(s:minTimeInterval * 1000, 'version482#TimerHandler')
        return
    endif

    let l:dirname = fnamemodify(l:filename, ':h')

    call version482#initVersionDir(l:dirname)

    " make sure file is in an EECS 482 git repo
    if s:versionDir[l:dirname] == ''
        return
    endif

    " make sure file is a program source file, i.e., has extension {cpp,cc,h,hpp,py}
    let l:ext = fnamemodify(l:filename, ':e')
    if l:ext != 'cpp' && l:ext != 'cc' && l:ext != 'h' && l:ext != 'hpp' && l:ext != 'py'
        return
    endif

    " make sure file isn't too big
    if (wordcount().bytes > 10 * 1024 * 1024)
	return
    endif

    let l:versionDirname = s:versionDir[l:dirname]

    " check if version file has grown too old or too big
    if l:now - s:sessionStart > 60*60 || (has_key(s:size, l:versionDirname) && s:size[l:versionDirname] > 50 * 1024 * 1024)
	" start new version file by mimicking restarting vim
	let s:hash = {}
	let s:size = {}
	let s:prior = {}
	let s:priorTime = {}
	let s:sessionStart = l:now
	let s:hashInitial = sha256(s:username . ' ' . s:sessionStart)
    endif

    if ! has_key(s:hash, l:versionDirname)
        let s:hash[l:versionDirname] = s:hashInitial
    endif

    if ! has_key(s:size, l:versionDirname)
        let s:size[l:versionDirname] = 0
    endif

    let l:priorname = fnamemodify(l:versionDirname, ':p') . s:sessionStart . '.' . s:username . '.prior'
    let l:currentname = fnamemodify(l:versionDirname, ':p') . s:sessionStart . '.' . s:username . '.current'

    if ! has_key(s:prior, l:filename)
	let s:prior[l:filename] = []
    endif

    call writefile(s:prior[l:filename], l:priorname)

    let l:current = getline(1, '$')
    call writefile(l:current, l:currentname)

    let l:versionfile = fnamemodify(l:versionDirname, ':p') . s:sessionStart . '.' . s:username

    let l:line = system('diff "' . l:priorname . '" "' . l:currentname . '"; rm "' . l:priorname . '" "' . l:currentname . '"')
    if l:line != ""
	let l:line = s:version .  ' ' . l:now . ' ' . s:size[l:versionDirname] . ' ' . s:hash[l:versionDirname] . ' ' . l:filename . ' ' .  json_encode(l:line)

	call writefile([l:line], l:versionfile, 'a')

	let s:prior[l:filename] = l:current
	let s:priorTime[l:filename] = l:now

	let s:hash[l:versionDirname] = sha256(l:line)
	let s:size[l:versionDirname] += strlen(l:line) + 1

	if ! has('nvim')
	    " Redraw screen to fix glitches.  Unfortunately, this has the
	    " side effect of blanking the entire screen when changing a range
	    " of text (e.g., change word).  nvim doesn't have these problems.
	    mode
	endif
    endif

endfunction

function version482#TimerHandler(...)
    call version482#TextChanged()
endfunction

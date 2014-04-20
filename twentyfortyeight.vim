"2048 in pure, beautiful Vimscript. Because why the fuck not.

function! TwentyFortyEight()
  execute "tabnew 2048 |
    \nnoremap <buffer> <silent> i :call <SID>ProcessMove(-4)\<cr> |
    \nnoremap <buffer> <silent> k :call <SID>ProcessMove(4)\<cr> |
    \nnoremap <buffer> <silent> j :call <SID>ProcessMove(-1)\<cr> |
    \nnoremap <buffer> <silent> l :call <SID>ProcessMove(1)\<cr> |
    \nnoremap <buffer> <silent> r :call <SID>ResetTiles()\<cr>:call <SID>Draw()\<cr> |
    \nnoremap <buffer> <silent> q :bd!\<cr>"
  call s:SetupTiles()
endfunction

function! s:SetupTiles()
  let s:tiles = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
  call s:GenerateNew()
  call s:GenerateNew()
  call s:Draw()
endfunction

function! s:Draw()
  let l:board = "
    \~~~~~~~~~~~ 2048! ~~~~~~~~~~~\n
    \\n
    \+------+------+------+------+\n
    \|      |      |      |      |\n
    \| {0 } | {1 } | {2 } | {3 } |\n
    \|      |      |      |      |\n
    \+------+------+------+------+\n
    \|      |      |      |      |\n
    \| {4 } | {5 } | {6 } | {7 } |\n
    \|      |      |      |      |\n
    \+------+------+------+------+\n
    \|      |      |      |      |\n
    \| {8 } | {9 } | {10} | {11} |\n
    \|      |      |      |      |\n
    \+------+------+------+------+\n
    \|      |      |      |      |\n
    \| {12} | {13} | {14} | {15} |\n
    \|      |      |      |      |\n
    \+------+------+------+------+\n
    \\n
    \  Controls:   i\n
    \            j k l"

  for i in range(0, len(s:tiles) - 1)
    let l:board = substitute(l:board, '{' . i . '\s*}', printf('%4s', s:tiles[i]), '')
  endfor

  let @d = l:board
  execute 'normal! ggdG"dPG0'
endfunction

"dir: -4 = up, 4 = down, -1 = left, 1 = right (obviously)
function! s:ProcessMove(dir)
  let l:oldState = deepcopy(s:tiles)
  let l:doubled = []

  let l:indeces = range(0, len(s:tiles) - 1)
  if a:dir > 0
    call reverse(l:indeces)
  endif

  for i in l:indeces
    let l:keepGoing = 1
    let l:current = i

    while l:keepGoing
      let l:target = l:current + a:dir

      "If it isn't going to fall off the board
      if (abs(a:dir) == 1 && s:IsInSameRow(l:target, l:current)) || (abs(a:dir) == 4 && l:target >= 0 && l:target < len(s:tiles))
        "Blank tile, move in
        if s:tiles[l:target] == ''
          let s:tiles[l:target] = s:tiles[l:current]
          let s:tiles[l:current] = ''
        "Matching tile, double into it if we haven't done so this move
        elseif s:tiles[l:target] == s:tiles[l:current] && s:IsNotDoubled(l:doubled, l:target)
          let s:tiles[l:target] = string(s:tiles[l:current] * 2)
          call add(l:doubled, l:target)
          let s:tiles[l:current] = ''
          let l:keepGoing = 0
          if s:tiles[l:target] == '2048'
            call s:YouWin()
            return
          endif
        "Blocked
        else
          let l:keepGoing = 0
        endif
      else
        let l:keepGoing = 0
      endif

      let l:current += a:dir
    endwhile
  endfor

  if l:oldState != s:tiles
    call s:Draw()
    redraw!
    execute 'sleep 200 m'
    call s:GenerateNew()
  endif
  call s:Draw()
endfunction

function! s:IsNotDoubled(doubledList, i)
  return len(filter(deepcopy(a:doubledList), "v:val == " . a:i)) == 0
endfunction

function! s:IsInSameRow(target, index)
  if a:target < 0
    return 0
  endif

  return a:target / 4 == a:index / 4
endfunction

function! s:GenerateNew()
  let l:tiles = deepcopy(s:tiles)
  let l:tileMap = {}
  for i in range(0, len(l:tiles) - 1)
    let l:tileMap[i] = l:tiles[i]
  endfor
  call filter(l:tileMap, "v:val ==# ''")

  if len(l:tileMap) == 0
    return
  endif

  let l:index = s:Rand(len(l:tileMap))
  let l:value = s:TwoOrFour()

  let s:tiles[keys(l:tileMap)[l:index]] = l:value
endfunction

function! s:Rand(max)
  return system("echo $((RANDOM % " . a:max . "))")
endfunction

function! s:TwoOrFour()
  return (s:Rand(2) + 1) * 2
endfunction

function! s:YouWin()
  let s:tiles = ['', '', '', '', 'Y', 'O', 'U', '', 'W', 'I', 'N', '!', '', '', '', '']
  call s:Draw()
endfunction


" Description:  C Preprocessor Highlighting
" Language:     Preprocessor on top of c, cpp, idl syntax
" Previous Maintainer List:
"               Michael Geddes <vimmer@frog.wheelycreek.net>
" Maintainer:   Prachya Saechua <blackb1rd@blackb1rd.me>
" Modified:     December 2015
"
" Copyright 2002-2015 Michael Geddes, Prachya Saechua
" Please feel free to use, modify & distribute all or part of this script,
" providing this copyright message remains.
" I would appreciate being acknowledged in any derived scripts, and would
" appreciate and welcome any updates, modifications or suggestions.

if exists('b:current_syntax') && b:current_syntax =~ 'ifdef'
  finish
endif

if !exists('b:current_syntax')
  let b:current_syntax = "ifdef"
else
  let b:current_syntax = b:current_syntax.'+ifdef'
endif


" Settings for the c.vim highlighting .. disable the default preprocessor handling.
let c_no_if0=1
if hlexists('cPreCondit')
  syn clear cPreCondit
endif
if hlexists('cCppOut')
  syn clear cCppOut
endif

if hlexists('cCppOut2')
  syn clear cCppOut2
endif
if hlexists('cCppSkip')
  syn clear cCppSkip
endif

" Reload protection
if !exists('ifdef_loaded') || exists('ifdef_debug')
  let ifdef_loaded=1
else
  call s:CIfDef(1)
  call IfdefLoad()
  finish
endif

if !exists('ifdeftags')
  let ifdeftags='.defines'
endif

" Reload CIfDef - backwards compatible
function! CIfDef()
  call s:CIfDef(0)
endfun

" Load the C ifdef highlighting.
function! s:CIfDef(force)
  if ! a:force &&  exists('b:ifdef_syntax')
      return
  endif
  let b:ifdef_syntax=1

  " Some useful groups.
  syn cluster ifdefClusterCommon contains=TOP,cPreCondit
  syn cluster ifdefClusterNeutral contains=@ifdefClusterCommon,ifdefDefined,ifdefUndefined,ifdefNeutral.*,ifdefInNeutralIf
  syn cluster ifdefClusterDefined contains=@ifdefClusterCommon,ifdefDefined,ifdefUndefined,ifdefNeutral.*,ifdefInNeutralIf
  syn cluster ifdefClusterUndefined contains=ifdefInUndefinedComment,ifdefInUndefinedIf

  syn region ifdefCommentAtEnd contained start=+//+ end='$' skip='\\$' contains=cSpaceError
  syn region ifdefCommentAtEnd contained extend start=+/\*+ end='\*/' contains=cSpaceError nextgroup=ifdefCommentAtEnd


  " #if .. #endif  nesting
  syn region ifdefOutsideNeutral matchgroup=ifdefPreCondit1 start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\)\(/[/*]\@!\|[^/]\)*" matchgroup=ifdefPreCondit1 end="^\s*#\s*endif\>.*$" contains=@ifdefClusterNeutral,ifdefElseInDefinedNeutral,cComment,cCommentL
  " #if .. #endif  nesting
  syn region ifdefInNeutralIf matchgroup=ifdefPreCondit1 start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\).*$" matchgroup=ifdefPreCondit1 end="^\s*#\s*endif\>.*$" contained contains=@ifdefClusterNeutral,ifdefElseInDefinedNeutral,cComment,cCommentL
  syn region ifdefInUndefinedIf matchgroup=ifdefPreConditBad start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\).*$" matchgroup=ifdefPreConditBad end="^\s*#\s*endif\>" contained contains=@ifdefClusterUndefined,ifdefElseInUndefinedNeutral,cCommentL,cComment skipwhite nextgroup=ifdefCommentAtEnd

  " #else highlighting for nesting
  syn match ifdefElseInDefinedNeutral "^\s*#\s*\(elif\>\|else\>\)" contained skipwhite
  syn match ifdefElseInUndefinedNeutral "^\s*#\s*\(elif\>\|else\>\)" contained skipwhite nextgroup=ifdefCommentAtEnd

  " #if 0 matching
  syn region ifdefUndefined  matchgroup=ifdefPreCondit4 start="^\s*#\s*if\s\+0\>" matchgroup=ifdefPreCondit4 end="^\s*#\s*endif" contains=@ifdefClusterUndefined,ifdefElseInUndefinedToDefined

  " #else handling .. switching to out group
  syn region ifdefElseInDefinedToUndefined matchgroup=ifdefPreCondit3 start="^\s*#\s*else\>" end="^\s*#\s*endif\>"me=s-1 contained contains=@ifdefClusterUndefined
  " #else handling .. switching to in group
  syn region ifdefElseInUndefinedToDefined matchgroup=ifdefPreCondit6 start="^\s*#\s*else\>" end="^\s*#\s*endif\>"me=s-1 contained contains=@ifdefClusterDefined

  " Handle #else, #endif inside a bracket. Not really an error, but impossible
  " to work out.
  syn match ifdefElseEndifInBracketError "^\s*#\s*\(elif\>\|else\>\|endif\>\)" contained containedin=cParen

  " comment highlighting
  syntax region ifdefInUndefinedComment start="/\*" end="\*/" contained contains=cCharacter,cNumber,cFloat,cSpaceError
  syntax match  ifdefInUndefinedComment "//.*" contained contains=cCharacter,cNumber,cSpaceError

  " Now add to all the c/rc/idl clusters
  syn cluster cParenGroup add=ifdefInUndefined.*,ifdefElse.*,ifdefInNeutralIf
  syn cluster cPreProcGroup add=ifdefInUndefined.*,ifdefElse.*,ifdefInNeutralIf
  syn cluster cMultiGroup add=ifdefInUndefined.*,ifdefElse.*,ifdefInNeutralIf
  syn cluster rcParenGroup add=ifdefInUndefined.*,ifdefElse.*,ifdefInNeutralIf
  syn cluster rcGroup add=ifdefInUndefined.*,ifdefElse.*,ifdefInNeutralIf

  " Include group - so reverse
  syn cluster idlCommentable add=ifdefUndefined,ifdefDefined

  " Start sync from scratch
  syn sync fromstart

endfunction

" Mark a (regexp) definition as defined.
" Note that the regular expression is use with \< \> arround it.
fun! Define(define)
  call CIfDef()
  exe 'syn region ifdefUndefined  matchgroup=ifdefPreCondit4 start="^\s*#\s*ifndef\s\+'.a:define.'\>" matchgroup=ifdefPreCondit4 end="^\s*#\s*endif" contains=@ifdefClusterUndefined,ifdefElseInUndefinedToDefined'
  exe 'syn region ifdefDefined matchgroup=ifdefPreCondit5 start="^\s*#\s*ifdef\s\+'.a:define.'\>" matchgroup=ifdefPreCondit5 end="^\s*#\s*endif" contains=@ifdefClusterDefined,ifdefElseInDefinedToUndefined'
endfun

" Mark a (regexp) definition as not defined.
" Note that the regular expression is use with \< \> arround it.
fun! Undefine(define)
  call CIfDef()
  exe 'syn region ifdefUndefined  matchgroup=ifdefPreCondit4 start="^\s*#\s*ifdef\s\+'.a:define.'\>" matchgroup=ifdefPreCondit4 end="^\s*#\s*endif" contains=@ifdefClusterUndefined,ifdefElseInUndefinedToDefined'
  exe 'syn region ifdefDefined matchgroup=ifdefPreCondit5 start="^\s*#\s*ifndef\s\+'.a:define.'\>" matchgroup=ifdefPreCondit5 end="^\s*#\s*endif" contains=@ifdefClusterDefined,ifdefElseInDefinedToUndefined'

endfun

" Check a directory for the specified file
function! s:CheckDirForFile(directory,file)
  let aborted=0
  let cur=a:directory
  let slsh= ((cur=~'[/\\]$') ? '' : '/')
  while !filereadable(cur.slsh.a:file)
    let nxt=fnamemodify(cur,':h')
    let aborted=(nxt==cur)
    if aborted!=0 | break |endif
    let cur=nxt
    let slsh=((cur=~'[/\\]$') ? '' : '/')
  endwhile
  " Check the two cases we haven't tried
  if aborted | let aborted=!filereadable(cur.slsh.a:file) | endif

  return ((aborted==0) ? cur.slsh : '')
endfun

" Read a .defines file in the specified (or higher) directory
fun! s:ReadFile( dir, filename)
  let realdir= s:CheckDirForFile( a:dir, a:filename )
  if realdir=='' | return '' | endif
  if !has('unix') && !&shellslash && &shell !~ 'sh[a-z.]*$'
    return system('type "'.fnamemodify(realdir,':gs?/?\\?.').a:filename.'"')
  else
    return system( 'cat "'.escape(realdir.a:filename,'\$*').'"' )
  endif
endfun

" Define/undefine a ';' or ',' separated list
fun! s:DoDefines( define, defines)
  let reBreak='[^;,]*'
  let here=0
  let back=strlen(a:defines)
  while here<back
    let idx=matchend(a:defines,reBreak,here)+1
    if idx<0 | let idx=back|endif
    let part=strpart(a:defines,here,(idx-here)-1)
    let part=substitute(substitute(part,'^\s*','',''),'\s*$','','')
    if part != ''
      if part=='*' | let part='\k\+' | endif
      if a:define
        call Define(part)
      else
        call Undefine(part)
      endif
    endif
    let here=idx
  endwhile
endfun

" Load ifdefs for a file
fun! IfdefLoad()
  let txt=s:ReadFile(expand('%:p:h'),g:ifdeftags)
  if txt!='' && txt !~"[\r\n]$" | let txt=txt."\n" | endif
  let txt=txt
  let reCr="[^\n\r]*[\r\n]*"
  let reDef='^\s*\(un\)\=defined\=\s*=\s*'
  let back=strlen(txt)
  let here=0
  while here < back
    let idx=matchend(txt,reCr,here)
    if idx < 0 | let idx=back|endif
    let part=strpart(txt,here,(idx-here))
    if part=~reDef
      let un=(part[0]=='u')
      let rest=substitute(strpart(part,matchend(part,reDef)),"[\r\n]*$",'','')
      call s:DoDefines(!un , rest)
    endif
    let here=idx
  endwhile
endfun

"  hi default ifdefIfZero term=bold ctermfg=1 gui=italic guifg=DarkSeaGreen
hi default link ifdefIfZero Comment
hi default link ifdefCommentAtEnd Comment
hi default link ifdefUndefined Debug
hi default link ifdefInUndefinedIf ifdefUndefined
hi default link ifdefElseInDefinedToUndefined ifdefUndefined
hi default link ifdefNeutralDefine PreCondit
hi default link ifdefNeutralPreProc PreProc
hi default link ifdefElseInDefinedNeutral PreCondit
hi default link ifdefElseInUndefinedNeutral PreCondit
hi default link ifdefInBadPreCondit PreCondit
hi default link ifdefInUndefinedComment ifdefUndefined
hi default link ifdefOutPreCondit ifdefInBadPreCondit
hi default link ifdefPreCondit1 PreCondit
hi default link ifdefPreConditBad ifdefInBadPreCondit
hi default link ifdefPreCondit3 ifdefPreCondit1
hi default link ifdefPreCondit4 ifdefPreCondit1
hi default link ifdefPreCondit5 ifdefPreCondit1
hi default link ifdefPreCondit6 ifdefPreCondit1
hi default link ifdefElseEndifInBracketError Special

call s:CIfDef(1)
call IfdefLoad()

fun! Find_defines(A, L, P)
  " Use dictionary to fix uniqueness
  let l:ret={}
  let cur=1
  while cur <= line('$')
    let line=getline(cur)
    if line =~ '^\s*#\s*ifn\=def\>\s\+'.a:A
      let l:find=matchstr(line,'^\s*#\s*ifn\=def\s*\zs\k\+')
      let ret[l:find]=1
    endif
    let cur+=1
  endwhile
  " Return the sorted keys of the dictionary
  return sort(keys(ret))
endfun

com! -complete=customlist,Find_defines -nargs=1 Define call Define(<q-args>)
com! -complete=customlist,Find_defines -nargs=1 Undefine call Undefine(<q-args>)

" vim:ts=2 sw=2 et

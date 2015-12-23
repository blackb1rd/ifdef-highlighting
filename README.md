Intro
=====
Provides highlighting for  #ifdef  #ifndef  #else  #endif  blocks, with
the ability to mark a symbol as defined or undefined.
Handles nesting of #ifdefs (and #if) as well, but does not handle  #if defined().

Supports vim_ifdef:  .defines files to specify defined/undefined symbols.

use :Define <keyword> or :Undefine <keyword> to dynamically specify defined or undefined sections.

Usage
=====
#ifdef defintions are considered to be in 1 of 3 states, defined, not-defined
or don't know (the default).

To specify which defines are valid/invalid, the scripts searches two places.
  * Firstly, the current directory, and all higher directories are search for
    the file specified in g:ifdeftags - which defaults to '.defines'
    (first one found gets used)

The defines/undefines are addeded in order.  Lines must be prefixed with
'defined=' or 'undefined=' and contain a ';' or ',' separated list of keywords.
Keywords may be regular expressions, though use of '\k' rather than '.' is
highly recommended.

Specifying '*' by itself equates to '\k\+' and allows
setting of the default to be defined/undefined.

Caveat
======
Don't expect an #else/#endif inside an open bracket '(' to match the #ifdef
correctly.  This is almost impossible to do without messing up the error-in
bracket code.

Currently #else/#endif that are inside brackets where the #ifdef is outside
will be highlighted as 'Special', you may wish to hilight it as an error. >
  hi link ifdefElseEndifInBracketError Error

Examples
========
The examples data that contain in .defines

defined=WIN32;__MT

undefined=*

undefined=DEBUG,DBG

Hilighting
==========
ifdefIfZero (default Comment)                     - Inside #if 0 highlighting
ifdefUndefined (default Debug)                    - The #ifdef/#else/#endif/#elseif
ifdefNeutralDefine (default PreCondit)            - Other defines where the defines are valid
ifdefInBadPreCondit (default PreCondit)           - The #ifdef/#else/#endif/#elseif in an invalid section.
ifdefInUndefinedComment (default ifdefUndefined)  - A C/C++ comment inside a an invalid section
ifdefPreCondit1 (defualt PreCondit)               - The #ifdef/#else/#endif/#elseif in a valid section
ifdefElseEndifInBracketError (default Special)    - Usupported #else/#endif inside a bracket '('.

Alternate (old) usage
=====================
Call CIfDef() after sourcing the c/cpp syntax file.
Use  :Define <keyword> or function Define(keyword) to mark a preprocessor symbol as being defined.
Use  :Undefine <keyword> or function Undefine(keyword) to mark a preprocessor symbol as not being defined.
call Undefine('\k\+') will mark all words that aren't explicitly 'defined' as undefined.

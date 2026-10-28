" Supply semantic argument groups missing from VimTeX's math command rules.
if !exists('b:vimtex_syntax')
  finish
endif

syntax match texCmdOpname "\%#=1\\operatorname\>\*\?"
      \ nextgroup=texOpnameArg skipwhite skipnl
call vimtex#syntax#core#new_arg('texOpnameArg', {'contains': 'TOP,@NoSpell'})
" These commands keep their argument semantics when used inside a formula.
syntax cluster texClusterMath add=texCmdOpname,texCmdHyperref,texCmdInput,texCmdBib,texCmdBibitem

syntax match texCmdInput "\%#=1\v\\%(input|include%(only|graphics)?|bibliography|bibliographystyle)>\*?"
      \ nextgroup=texFileOpt,texFileArg skipwhite skipnl

syntax match texMathCmdText "\%#=1\v\\%(text%(normal|rm|up|tt|sf|sc|bf|it|md|sl)?|%(short)?intertext|[mhf]box)>"
      \ contained nextgroup=texMathTextArg skipwhite skipnl

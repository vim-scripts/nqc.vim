" Vim filetype plugin file
"
" Language   :  NQC - Not Quite C
" Plugin     :  nqc.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  27.12.2003
"
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_NQC_ftplugin")
  finish
endif
let b:did_NQC_ftplugin = 1
"
" ---------- Key mappings  -------------------------------------
"
"       F9   save and compile 
"
   noremap  <F9>    :call NQC_SaveCompile()<CR>
  inoremap  <F9>    <Esc>:call NQC_SaveCompile()<CR>


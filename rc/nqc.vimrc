"
"-------------------------------------------------------------------------------
" nqc.vim
"-------------------------------------------------------------------------------
let g:NQC_AuthorName      = ""
let g:NQC_AuthorRef       = ""
let g:NQC_Email           = ""
let g:NQC_Project         = ""
let g:NQC_CopyrightHolder = ""
"
" ----------  Insert header into new Tex-files  ----------
if has("autocmd")
	autocmd BufNewFile  *.nqc  call NQC_CommentTemplates('cheader')
endif " has("autocmd")
"

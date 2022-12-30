if has("syntax")
	syntax on
endif

set hlsearch
set nu
set autoindent
set ts=4
set sts=4
set cindent
set laststatus=2
set shiftwidth=4
set showmatch
set smartcase
set smarttab
set smartindent
set ruler
set fileencodings=utf8,euc-kr

set softtabstop=4
set tabstop=4
set expandtab

" 검색시 파일 끝에서 처음으로 되돌리기 안함
set nows
" 검색시 대소문자를 구별하지 않음
set ic
" 똑똑한 대소문자 구별 기능 사용
set scs

" 마지막으로 수정된 곳에 커서를 위치함
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif

set laststatus=2 " 상태바 표시를 항상한다
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\

" colorscheme jellybeans

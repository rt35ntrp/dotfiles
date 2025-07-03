# =============================
# 🚀 PATH 설정 (정리된 순서)
# =============================
export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
export PATH="$HOME/bin:$BUN_INSTALL/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export CLICOLOR=1

# =============================
# ⚙️ oh-my-zsh 설정
# =============================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

# 플러그인: 설치 여부 꼭 확인
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  fzf
  zsh-completions
  zsh-history-substring-search
  kube-ps1
)

# ----------------------------
# 🔧 compinit 최적화 및 경로 설정
# ----------------------------
ZSH_DISABLE_COMPFIX="true"          # oh-my-zsh 보안 검사 비활성화(개인 머신)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
# zsh-completions 를 fpath 앞쪽에 추가
fpath=("$ZSH_CUSTOM/plugins/zsh-completions/src" $fpath)
autoload -Uz compinit
compinit -u -C                        # -u: 보안검사 생략, -C: 캐시 존재 시 빠른 로드
# zcompdump 파일을 바이트코드로 컴파일
if [[ -f ~/.zcompdump && ! -f ~/.zcompdump.zwc ]]; then
  zcompile ~/.zcompdump
fi

# oh-my-zsh 로드
source $ZSH/oh-my-zsh.sh

# fzf key-bindings / completion (Homebrew 설치 경로 기준)
if [ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh" ]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
fi

# kube-ps1 프롬프트 (현재 K8s context/namespace 표시)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ -f "$ZSH_CUSTOM/plugins/kube-ps1/kube-ps1.sh" ]; then
  source "$ZSH_CUSTOM/plugins/kube-ps1/kube-ps1.sh"
  PROMPT='$(kube_ps1)'$PROMPT
fi

# =============================
# 🛠️ 사용자 정의
# =============================

# 기본 사용자 이름 (agnoster prompt용)
DEFAULT_USER="$(whoami)"

# SSH일 때만 사용자 표시
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# ls 색상 강제 적용 (gls가 설치되어 있어야 함)
alias ls='ls --color=auto'

# =============================
# 🧪 Conda (conda init 내용)
# =============================
if [ -f "$HOME/conda/etc/profile.d/conda.sh" ]; then
  . "$HOME/conda/etc/profile.d/conda.sh"
  # conda activate base  # 필요시 활성화
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# =============================
# 🦀 Rust
# =============================
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# =============================
# 🔒 비공개 환경변수 (예: API 키)
# =============================
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# =============================
# ✨ 기타 권장 설정 (선택)
# =============================

# zsh 오토코렉션
# ENABLE_CORRECTION="true"

# 커맨드 자동완성 대기 표시
# COMPLETION_WAITING_DOTS="true"

# 히스토리 타임스탬프
# HIST_STAMPS="yyyy-mm-dd"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PATH="$HOME/.local/bin:$PATH"

# --------------------------
# 🌈 유용한 CLI alias 및 설정
# --------------------------

# eza: modern ls
alias ls='eza'
alias ll='eza -al'
alias lt='eza --tree --level=2'
alias li='eza --icons'
alias lli='eza -al --icons'

# bat: better cat
alias cat='bat --style=plain'
alias bathelp='bat --paging=always --language=help'

# fzf: fuzzy finder 설정 (history 검색 포함)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'


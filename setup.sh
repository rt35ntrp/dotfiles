#!/bin/bash
set -e

# dotfiles 루트 경로 (스크립트 위치 기준)
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔧 Dotfiles Setup 시작..."

# --------------------------
# Homebrew 설치 (macOS 기준)
# --------------------------
if ! command -v brew &>/dev/null; then
  echo "📦 Homebrew 설치 중..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew 이미 설치됨"
fi

# --------------------------
# 필수 패키지 설치
# --------------------------
echo "📦 기본 패키지 설치 중..."
brew install stow git coreutils zsh fzf exa bat jq gh pyenv pyenv-virtualenv kubernetes-cli helm stern kustomize k9s pipx

# fzf 키 바인딩/컴플리션 스크립트 설치 (rc 자동 수정 안 함)
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

# --------------------------
# oh-my-zsh 설치
# --------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "⚙️ oh-my-zsh 설치 중..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ oh-my-zsh 이미 설치됨"
fi

# --------------------------
# 플러그인 설치
# --------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "🔌 zsh-syntax-highlighting 설치..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "🔌 zsh-autosuggestions 설치..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# --------------------------
# 추가 플러그인 설치
# --------------------------
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  echo "🔌 zsh-completions 설치..."
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
  echo "🔌 zsh-history-substring-search 설치..."
  git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/kube-ps1" ]; then
  echo "🔌 kube-ps1 설치..."
  git clone https://github.com/jonmosco/kube-ps1 "$ZSH_CUSTOM/plugins/kube-ps1"
fi

# --------------------------
# dotfiles stow 적용
# --------------------------
echo "🔗 dotfiles 심볼릭 링크 생성 중..."
for dir in zsh git vim jupyter bin; do
  if [ -d "$dir" ]; then
    echo "➡️  stow $dir"
    stow "$dir"
  fi
done

# --------------------------
# GUI 애플리케이션(cask) 설치 (macOS)
# --------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "📦 GUI 애플리케이션(cask) 설치 중..."
  brew tap homebrew/cask-fonts
  brew install --cask docker visual-studio-code iterm2 rectangle lens \
      google-chrome slack notion kakaotalk \
      font-jetbrains-mono-nerd-font font-d2coding
  # Docker Desktop 첫 실행 → 권한/리소스 설정을 위해 자동 실행
  if [ -d "/Applications/Docker.app" ]; then
    echo "🐳 Docker Desktop 첫 실행 중... (잠시 기다려 주세요)"
    open -g -a Docker
  fi

  # matplotlib 한글 깨짐 방지 (macOS: AppleGothic)
  mkdir -p "$HOME/.matplotlib"
  cat > "$HOME/.matplotlib/matplotlibrc" <<'EOF'
font.family: AppleGothic
axes.unicode_minus: False
EOF

  # --------------------------
  # VSCode 확장 및 설정 적용
  # --------------------------
  if command -v code &>/dev/null; then
    echo "🔌 VSCode 확장 설치 중..."
    VSCODE_EXTENSIONS=(
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      eamodio.gitlens
      ms-kubernetes-tools.vscode-kubernetes-tools
      GitHub.vscode-pull-request-github
    )
    for ext in "${VSCODE_EXTENSIONS[@]}"; do
      code --install-extension "$ext" --force >/dev/null 2>&1 || true
    done

    # 사용자 설정 복사 (존재 시)
    if [[ -d "$DOTFILES_DIR/vscode" ]]; then
      echo "📝 VSCode 사용자 설정 복사..."
      if [[ "$(uname)" == "Darwin" ]]; then
        VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
      else
        VSCODE_USER_DIR="$HOME/.config/Code/User"
      fi
      mkdir -p "$VSCODE_USER_DIR"
      for file in settings.json keybindings.json snippets; do
        [ -e "$DOTFILES_DIR/vscode/$file" ] && cp -nR "$DOTFILES_DIR/vscode/$file" "$VSCODE_USER_DIR/"
      done
    fi
  else
    echo "⚠️  'code' 명령어를 찾을 수 없습니다. VSCode를 먼저 실행 후 'Shell Command: Install 'code' command' 를 활성화해 주세요."
  fi
fi

# --------------------------
# Poetry 설치 (공식 스크립트)
# --------------------------
if ! command -v poetry &>/dev/null; then
  echo "📦 Poetry 설치 중..."
  curl -sSL https://install.python-poetry.org | python3 -
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
else
  echo "✅ Poetry 이미 설치됨: $(poetry --version)"
fi

# --------------------------
# Conda 설치 (Miniforge 방식)
# --------------------------
if ! command -v conda &>/dev/null; then
  echo "📦 Miniforge (conda) 설치 중..."
  curl -L -o ~/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh
  bash ~/miniforge.sh -b -p $HOME/miniforge3
  rm ~/miniforge.sh
  echo 'export PATH="$HOME/miniforge3/bin:$PATH"' >> ~/.zshrc
  echo "✅ Miniforge 설치 완료 (터미널 재시작 후 conda 사용 가능)"
else
  echo "✅ Conda 이미 설치됨: $(conda --version)"
fi

# --------------------------
# krew 설치 및 K8s 플러그인
# --------------------------
if ! command -v kubectl-krew &>/dev/null; then
  echo "🔌 krew 설치 중..."
  (
    set -e
    cd "$(mktemp -d)"
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed 's/x86_64/amd64/;s/arm64/arm64/')"
    KREW="krew-${OS}_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz"
    ./${KREW} install krew
  )
  echo 'export PATH="$HOME/.krew/bin:$PATH"' >> ~/.zshrc
fi

# krew 플러그인 기본 세트 설치
export PATH="$HOME/.krew/bin:$PATH"
for plugin in kubectx ns neat tail view-allocations; do
  kubectl krew list | grep -q "${plugin}" || kubectl krew install "${plugin}"
done

# stern, helm 등 brew로 이미 설치됨

# --------------------------
# matplotlib 설정 (Linux)
# --------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  mkdir -p "$HOME/.matplotlib"
  cat > "$HOME/.matplotlib/matplotlibrc" <<'EOF'
font.family: NanumGothic
axes.unicode_minus: False
EOF

  # Nerd Font 설치 (JetBrainsMono Nerd Font)
  if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "📦 Nerd Font( JetBrainsMono ) 설치 중..."
    TMP_DIR=$(mktemp -d)
    curl -fsSL -o "$TMP_DIR/JetBrainsMono.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    mkdir -p "$HOME/.local/share/fonts"
    unzip -q "$TMP_DIR/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/JetBrainsMono/"
    fc-cache -fv
    rm -rf "$TMP_DIR"

    # D2Coding 폰트 설치
    if ! fc-list | grep -qi "D2Coding"; then
      echo "📦 D2Coding Font 설치 중..."
      TMP_DIR=$(mktemp -d)
      curl -fsSL -o "$TMP_DIR/D2Coding.zip" \
        https://github.com/naver/d2codingfont/releases/latest/download/D2Coding.zip
      unzip -q "$TMP_DIR/D2Coding.zip" -d "$HOME/.local/share/fonts/D2Coding/"
      fc-cache -fv
      rm -rf "$TMP_DIR"
    fi
  else
    echo "✅ JetBrainsMono Nerd Font 이미 설치됨"
  fi
fi

# pyenv 초기화 스니펫이 없으면 추가
grep -q "pyenv init" ~/.zshrc 2>/dev/null || {
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
}

# pipx PATH 보장
pipx ensurepath

# Python 글로벌 툴 설치 (존재 여부 검사 최소화)
for tool in black isort flake8 mypy pre-commit nbstripout;
do
  pipx list | grep -q " $tool " || pipx install "$tool"
done

echo ""
echo "🎉 dotfiles 세팅 완료! 새 터미널을 열거나 'source ~/.zshrc' 하세요."

# 📦 owen-dotfiles

개발·데이터사이언스·K8s 작업을 macOS & Linux 환경에서 **원-커맨드** 로 세팅할 수 있도록 만든 개인용 dotfiles 입니다.

> 새 노트북을 바꿨다면?
>
> ```bash
> git clone https://github.com/you/dotfiles ~/.dotfiles
> cd ~/.dotfiles && ./setup.sh
> ```
>
> 15-20분 뒤면 CLI, GUI, Zsh, Python, VSCode, Docker Desktop, Nerd Font 까지 모두 갖춰집니다.

---

## 🗂️ 디렉터리 구조

| 경로       | 설명                                                                   |
| ---------- | ---------------------------------------------------------------------- |
| `setup.sh` | 전체 환경 자동 설치 스크립트 (Homebrew, Zsh, pyenv, Docker, VSCode 등) |
| `zsh/`     | `.zshrc` 및 관련 플러그인 설정                                         |
| `vim/`     | `.vimrc`, 플러그인 목록                                                |
| `jupyter/` | Jupyter Notebook 설정 파일(                                            |
| `bin/`     | 자주 쓰는 유틸 스크립트 (`klog`, `git-undo`, `peek`, `tb` 등)          |
| `misc/`    | 터미널 색상·폰트 프로파일 등 기타 자산                                 |

---

## 🚀 주요 기능

### 1. Setup Script (`setup.sh`)

- **Homebrew**: CLI(`git`, `fzf`, `exa`, `bat`, `k9s` …) + GUI(`Docker`, `VSCode`, `Slack`, `KakaoTalk`, `Notion`, `Lens`) 자동 설치
- **Fonts**: JetBrainsMono Nerd Font, D2Coding Font 자동 설치
- **Python**: `pyenv`, `pyenv-virtualenv`, `poetry`, `pipx` & 글로벌 툴(black, isort, flake8, mypy, pre-commit, nbstripout)
- **Kubernetes**: `kubectl`, `helm`, `stern`, `kustomize`, `krew` + 플러그인(kubectx, ns, neat…) 설치
- **VSCode**: 확장( Python, Pylance, Jupyter, Docker, GitLens, K8s, Copilot …) & 사용자 설정 자동 복사
- **Fonts & 한글**: matplotlib 한글 깨짐 방지(`AppleGothic` / `NanumGothic`), Nerd Font 적용

### 2. Zsh 환경 (`zsh/.zshrc`)

- 플러그인: `zsh-syntax-highlighting`, `zsh-autosuggestions`, `fzf`, `zsh-completions`, `history-substring-search`, `kube-ps1`
- `fzf` 키 바인딩·컴플리션 로드
- `compinit -u -C` 최적화 → 빠른 탭 완성
- 프롬프트에 현재 K8s context/namespace 표시

### 3. Bin 스크립트 하이라이트

| 스크립트   | 설명                                                             |
| ---------- | ---------------------------------------------------------------- |
| `klog`     | `stern` 래퍼. 현재 namespace 의 모든 Pod 로그를 컬러로 tail      |
| `git-undo` | 최근 N개 커밋 soft-reset (`git-undo 2`)                          |
| `peek`     | 파일 유형 자동 감지(CSV, JSON, Parquet…) 미리보기 & 요약         |
| `tb`       | TensorBoard 실행: logdir 자동 탐색 + 포트 충돌 해결 + `--reload` |

---

## ⚙️ 설치 방법 상세

### macOS

```bash
# 1) Xcode Command Line Tools (없으면 자동 프롬프트)
# 2) dotfiles 클론
git clone https://github.com/you/dotfiles ~/.dotfiles
cd ~/.dotfiles

# 3) 실행 (모든 단계 자동 스킵/재시도 로직 포함)
./setup.sh

# 4) 완료 후
source ~/.zshrc
```

### Linux (Ubuntu 등)

```bash
sudo apt update && sudo apt install -y git curl build-essential

git clone https://github.com/you/dotfiles ~/.dotfiles
cd ~/.dotfiles && ./setup.sh
source ~/.zshrc
```

> Linux 에서는 Homebrew 대신 APT로 패키지를 설치하며, macOS 전용 GUI 앱 단계는 자동 스킵됩니다.

---

## 📝 커스터마이징 가이드

1. **설치 패키지 변경**: `setup.sh` 의 Brew/apt 블록에서 항목 추가·삭제
2. **VSCode 확장 추가**: `setup.sh` 의 `VSCODE_EXTENSIONS` 배열에 ID 추가
3. **Zsh 플러그인**: `zsh/.zshrc` 의 `plugins=( … )` 배열 수정
4. **Bin 스크립트**: `bin/` 에 새 스크립트 추가 후 `chmod +x` → `stow bin`
5. **Markdown 스타일**: `markdown/style.css` 작성 후 VSCode 설정 `markdown-preview-enhanced.customStyles` 경로 지정

---

## 🛠️ 유지·업데이트

```bash
# dotfiles 업데이트 (새 패키지·스크립트 반영)
cd ~/.dotfiles && git pull && ./setup.sh

# Homebrew / Pipx / Poetry 패키지 전체 업그레이드
brew update && brew upgrade && pipx upgrade-all && poetry self update
```

---

## 🖋️ 라이선스

MIT

## ⚠️ 주의사항 & Troubleshooting

| 증상                                         | 원인/해결                                                                                                                                |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **Homebrew 가 Permission 오류**              | 새 macOS 에서 처음 실행 시 `/opt/homebrew` 쓰기 권한을 요청합니다. 비밀번호 입력 후 다시 `./setup.sh` 실행하세요.                        |
| **`xcode-select: note: no developer tools`** | Xcode Command Line Tools 가 필요합니다. 프롬프트에서 `Install` 선택 후 완료되면 스크립트를 재실행하세요.                                 |
| **VSCode 확장이 설치되지 않음**              | `code` CLI 가 아직 PATH 에 없을 때 발생. VSCode 열어 `⌘⇧P → Shell Command: Install 'code' command` 실행 후 `./setup.sh` 재실행.          |
| **Docker Desktop 첫 실행 팝업**              | 시스템 확장(네트워크 권한) 허용 및 Rosetta 설치(Apple Silicon)가 필요할 수 있습니다. 최초 한 번만 수동 승인하면 됩니다.                  |
| **`kubectl krew` 명령이 안 보임**            | 새 셸에서 PATH 가 갱신돼야 합니다. `source ~/.zshrc` 또는 터미널을 다시 열어주세요.                                                      |
| **폰트가 터미널에 보이지 않음**              | Nerd Font / D2Coding 설치 후 iTerm2·VSCode 를 완전히 종료 후 재실행해야 목록에 나타납니다.                                               |
| **matplotlib 한글이 □ 로 표시**              | macOS: `AppleGothic`, Linux: `NanumGothic` 가 설치되지 않은 경우. 스크립트가 설치를 시도하니 실패 로그가 없는지 확인 후 수동 설치하세요. |

---

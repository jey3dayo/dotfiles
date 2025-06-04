# Setup

ディレクトリ周りのセットアップ

```bash
sh ./setup.sh
```

```bash
# go get github.com/peco/peco/cmd/peco
brew tap peco/peco
brew install peco
```

## brew

```bash
brew install coreutils curl git
```

## mise

```bash
brew install jdxcode/tap/mise
mise install direnv
mise install node@18
mise install node@20
mise install python
mise install yarn
mise install deno
mise install bun
```

## npm

```bash
# バックアップ
npm list -g --json > global-package.json

# リストア
jq -r '.dependencies | to_entries | .[] | "\(.key)@\(.value.version)"' global-package.json | xargs npm install -g
```

## Zsh 設定

詳細な設定については [zsh/README.md](zsh/README.md) を参照してください。

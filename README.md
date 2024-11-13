# Setup

ディレクトリ周りのセットアップ

```
sh ./setup.sh
```


```
# go get github.com/peco/peco/cmd/peco
brew tap peco/peco
brew install peco
```

# brew

```
brew install coreutils curl git
```

# mise

```
brew install jdxcode/tap/mise
mise install direnv
mise install node@18
mise install node@20
mise install python
mise install yarn
mise install deno
mise install bun
```

# npm

```
# バックアップ
npm list -g --json > global-package.json

# リストア
jq -r '.dependencies | to_entries | .[] | "\(.key)@\(.value.version)"' global-package.json | xargs npm install -g
```

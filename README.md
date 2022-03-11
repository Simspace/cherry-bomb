### Basic Usage 

`nix run github:Simspace/cherry-bomb -- -r <repo-to-clone> -c <commit-hash>`

IE

```
nix run github:Simspace/cherry-bomb -- \
  -r "git@github.com:Simspace/cherry-bomb.git" \
  -c f6903d1df40df07552fdb114a35bb4b808e906e0
```

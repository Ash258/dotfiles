# Personal dotfiles

## Initial setup

1. `xcode-select --install`
1. `sh -c $"(curl -fsSL dotsetup.ash258.com)"`
   1. script below
1. Login to 1password
   1. Get identity file using op
1. `bin/chezmoi apply`

```bash
#!/bin/sh

# TODO: Try to implement the xcode select

sh -c "$(curl -fsLS get.chezmoi.io)"
~/bin/chezmoi init ash258
cat <<EOT > "${HOME}/.config/chezmoi/chezmoi.toml"
encryption = "age"

[age]
identity = '~/identity.txt'
recipients = "age1l0e9ted62t864dcf0f5x58rcawwq2prmvs89l9wsyqqz5zxpmelsqh289t"

[hooks.read-source-state.pre]
    command = ".local/share/chezmoi/.install-password-manager.sh"
EOT
```

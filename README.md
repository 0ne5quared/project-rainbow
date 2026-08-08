# Project Rainbow

If you want to help develop the project and have `nix` and `git`, running these in your terminal should set you up:

```
git clone https://github.com/Mouthless-Stoat/project-rainbow.git
cd project-rainbow
nix develop
```

To test sigil and the game you also need the server component, open another terminal and run these:

```
git clone https://github.com/Mouthless-Stoat/project-rainbow-server.git
cd project-rainbow-server
nix develop
```

If the game still complain about a server try opening port `42069` on your device.

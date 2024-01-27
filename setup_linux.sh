# Install WezTerm and its config
ubuntu='Ubuntu20.04'
wezterm_ver="$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep tag_name)"
wezterm_ver="$(echo "$wezterm_ver" | cut -d '"' -f 4)"
curl -L -o wezterm_installer.deb \
  "https://github.com/wez/wezterm/releases/download/$wezterm_ver/wezterm-$wezterm_ver.$ubuntu.deb"
sudo apt install -y ./wezterm_installer.deb
rm wezterm_installer.deb
ln -sf "$PWD/wezterm" ~/.config/wezterm

# Install Neovim (nightly) and its config
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt install neovim
ln -sf "$PWD/nvim" ~/.config/nvim

# Install all dotfiles
ln -sf "$PWD/dotfiles/.gitconfig" ~/.gitconfig

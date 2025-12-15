#!/usr/bin/env bash
command -v gum >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Gum is NOT in PATH. You can visit https://github.com/charmbracelet/gum to install it"
    exit 1
fi

gum confirm "configure doom ?" && git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs && ~/.config/emacs/bin/doom install

echo "I order to continue with setting up your dotfiles"
echo "you need to have a github public repo containing"
echo "your dotfiles."
echo "If you don't, you can continue installing your dotfiles"
echo "with chez moi by following the documentation on"
echo "the website: https://www.chezmoi.io/quick-start/"

gum confirm "continue with dotfiles?" || exit 1

command -v chezmoi >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Chezmoi is NOT in PATH. You can visit https://www.chezmoi.io/install/ to install it"
    read -n 1 -s -r -p "Press any key to exit..."
fi

GITHUB_USERNAME=$(gum input --placeholder "your github username")

DOTFILES_REPO_NAME=$(gum input --placeholder "your dotfiles repo")

chezmoi init --apply --verbose https://github.com/$GITHUB_USERNAME/$DOTFILES_REPO_NAME.git

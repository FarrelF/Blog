#!/usr/bin/env bash
script_folder="$(pwd)"
workspaces_folder="$(cd "${script_folder}/.." && pwd)"

clone-repo()
{
    cd "${workspaces_folder}"
    if [ ! -d "${1#*/}" ]; then
        git clone "https://github.com/$1"
    else 
        echo "Already cloned $1"
    fi
}

if [ "${CODESPACES}" = "true" ]; then
    # Remove the default credential helper
    sudo sed -i -E 's/helper =.*//' /etc/gitconfig

    # Add one that just uses secrets available in the Codespace
    git config --global credential.helper '!gh auth git-credential'
fi

if [ -f "${script_folder}/.devcontainer/repos-to-clone.list" ]; then
    while IFS= read -r repository; do
        clone-repo "$repository"
    done < "${script_folder}/.devcontainer/repos-to-clone.list"
fi

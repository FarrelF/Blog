# Update the NODE_VERSION arg in docker-compose.yml to pick a Node version: 18, 16, 14
#ARG NODE_VERSION=16
FROM mcr.microsoft.com/devcontainers/javascript-node:${NODE_VERSION}

## VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
#ARG VARIANT=hugo_extended
## VERSION can be either 'latest' or a specific version number
#ARG VERSION=latest

# Download and Install Hugo
RUN apt update && apt install -y ca-certificates openssl git curl && \
    rm -rf /var/lib/apt/lists/*
#    rm -rf /var/lib/apt/lists/* && \
#    case ${VERSION} in \
#    latest) \
#    export VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}') ;;\
#    esac && \
#    echo ${VERSION} && \
#    wget -O ${VERSION}.tar.gz https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${VARIANT}_${VERSION}_Linux-64bit.tar.gz && \
#    tar xf ${VERSION}.tar.gz && \
#    install -Dm755 hugo /usr/local/bin/ && \
#    install -Dm644 LICENSE /usr/share/licenses/hugo/LICENSE

# Install Hugo Manpages and Shell Completions
# RUN hugo gen man --dir '/tmp/hugo_manpages' && \
#     cd /tmp/hugo_manpages && gzip -9 * && \
#     install -Dm644 * -t /usr/local/man/man1 && \
#     cd - && rm -rf /tmp/hugo_manpages && \
#     hugo completion bash | install -Dm644 /dev/stdin "/usr/share/bash-completion/completions/hugo" && \
#     hugo completion zsh | install -Dm644 /dev/stdin "/usr/share/zsh/site-functions/_hugo" && \
#     hugo completion fish | install -Dm644 /dev/stdin "/usr/share/fish/vendor_completions.d/hugo.fish"

# Hugo dev server port
EXPOSE 1313

# [Optional] Uncomment this section to install additional OS packages you may want.
#
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install more global node packages
# RUN sudo -u node npm install -g <your-package-list-here>
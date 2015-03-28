# Install command-line tools using Homebrew

# Brew cleanup 
brew doctor

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install wget with IRI support --enable-iri deprecated using --with-iri
brew install wget --with-iri

# Install tmux
brew install tmux

# Install more recent versions of some OS X tools
brew install vim --override-system-vi
brew install homebrew/dupes/grep
brew install homebrew/dupes/screen


# Install other useful binaries
brew install ack
brew install mc
#install exiv2
#brew install git
brew install imagemagick --with-webp
brew install node # This installs `npm` too using the recommended installation method
brew install pv
brew install rename
brew install tree
brew install ffmpeg --with-libvpx
brew install android-platform-tools

# Remove outdated versions from the cellar
brew cleanup

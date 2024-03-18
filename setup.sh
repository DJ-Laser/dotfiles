# Work in isolated folder to make cleanup easier
output=$(mkdir __crostini-setup-temp/)
if [ $? -ne 0 ]; then
    echo "Failed to create temp directory. mkdir failed with: "$output
    exit;
else
   cd __crostini-setup-temp/
fi


code=false;
read -r -p "Install VSCode (Code Editor) and programming languages? [y/N]" response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	code=true;
fi

# Install packages

# Base packages
sudo apt install -y wget gpg curl git

# Nautilus (GNU file manager)
sudo apt install -y nautilus

# Zoxide (better cd)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# fzf (fuzzy funder for zoxide)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# programming languages
if [$code = true] then
	# Install Rust
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sha
	
	# Install Node.js
	curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
	sudo apt-get install -y nodejs
fi

# Apps

# Firefox setup
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

#Vscode setup
if [$code = true] then
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	sudo apt install -y apt-transport-https
fi

# Freetube setup
wget https://github.com/FreeTubeApp/FreeTube/releases/download/v0.19.2-beta/freetube_0.19.2_amd64.deb

# Install apps
sudo apt update
if [$code = true]
then
	sudo apt install -y code;
fi
sudo apt install -y firefox ./freetube_0.19.2_amd64.deb

sudo apt upgrade

echo "You may now safely remove temporary setup files by running rm -r __crostini-setup-temp"

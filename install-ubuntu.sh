#!/bin/bash
cd "$(dirname "$0")"
set -e
printf "\033c"

# TODO: Add to search on /lib/plymouth/themes. On other systems it is /usr/share/plymouth
#       More info on other OSes: http://brej.org/blog/?p=158

# Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
# Tux as ASCII found here: http://www.chris.com/ascii/index.php?art=logos%20and%20insignias/linux

#!/bin/bash
OSVER="16.04"
if [[ `lsb_release -rs` != $OSVER ]] # replace 8.04 by the number of release you want
then
	echo "Sorry, need 16.04 to run this installer. Find your version at"
    echo "http://github.com/tuxedojoe/tux4ubuntu/"	
    echo ""
    echo "(Or fork/edit our project/install_xxx.sh for your system, and then make a"
    echo "pull request/send it to us so that more people can use it)"
    exit
fi

while :
do
    clear
    cat<<EOF    
╔══════════════════════════════════════════════════════════════════════════════╗
║ TUX 4 UBUNTU                                    © 2016 Tux4Ubuntu Initiative ║
║ Let's bring Tux to Ubuntu                     http://tux4ubuntu.blogspot.com ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   Where do you want Tux?                                                     ║
║                                                                              ║
║   1) Everywhere                                - Install all of the below    ║
║   ------------------------------------------------------------------------   ║
║   2) Boot Loader                               - Install rEFInd theme        ║
║   3) Boot Logo                                 - Install Plymouth theme      ║
║   4) Login Screen                              - Update icons and colors     ║
║   5) Desktop Theme & Icons                     - Specialized Arch-theme      ║
║   6) Wallpapers                                - Adds Tux favourite images   ║
║   7) Games                                     - Install games feat. Tux     ║
║   8) On my belly!                              - Buy the t-shirt             ║
║   ------------------------------------------------------------------------   ║
║   9) Uninstall Tux                             - Uninstall the above         ║
║   ------------------------------------------------------------------------   ║
║   Q) I'm done                                  - Quits installer             ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    read -n1 -s
    case "$REPLY" in
    "1")    echo "you chose choice 1" ;;
    "2")    # Boot Loader
            printf "\033c"
            echo "Do you understand that changing boot loader theme (and potentially the boot"
            echo "loader as well) is not without risk? And we can't be hold responsible if"  
            echo "you proceed. Our website and internet can help but nothing is 100% safe."
            if sudo -n true 2>/dev/null; then 
                :
            else
                echo ""
                echo "Oh, and Tux need sudo rights to copy and install everything, so we'll ask about that soon."
            fi
            echo ""
            echo "(Type 1 or 2, then press ENTER)"
            select yn in "Yes" "No"; do
            case $yn in
                Yes ) printf "\033c"
                    echo "Ok, here we go!"
                    if [ -d /sys/firmware/efi ]
                    then 
                        echo "EFI bootloader detected";
                        if ! grep -q rodsmith/refind /etc/apt/sources.list /etc/apt/sources.list.d/*; then
                            # The rEFInd ppa is not registered. Ask if user wants it installed.
                            echo "Your system is new enough to boot using EFI, but you're not running the more graphical"
                            echo "bootloader rEFInd. Would you like to install it? (If're not dual-booting, skip this step)"
                            echo ""
                            echo "(Type 1 or 2, then press ENTER)"
                            select yn in "Yes" "No"; do
                            case $yn in
                                Yes ) printf "\033c"
                                    # Commands to add the ppa
                                    sudo apt-add-repository ppa:rodsmith/refind
                                    sudo apt-get update
                                    # Check if refind is installed
                                    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
                                    MISC="refind"
                                    for pkg in $MISC; do
                                        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
                                            echo -e "$pkg is already installed"
                                        else
                                            if sudo apt-get -qq install $pkg; then
                                                echo "Successfully installed $pkg"
                                            else
                                                echo "Error installing $pkg"
                                            fi        
                                        fi
                                    done
                                    echo "Done";
                                    break;;
                                No ) printf "\033c"
                                    echo "It's not that dangerous though! Feel free to try when you're ready. Tux will be waiting."
                                    exit;;
                                esac
                            done

                        else
                            printf "\033c"
                            echo "Seems like you have rEFInd installed."
                        fi
                        printf "\033c"
                        echo "Initiating to copy folder tux-refind-theme."
                        sudo mkdir -p /boot/efi/EFI/refind/themes
                        sudo cp -r tux-refind-theme /boot/efi/EFI/refind/themes/tux-refind-theme
                        echo 'include themes/tux-refind-theme/theme.conf' | sudo tee -a /boot/efi/EFI/refind/refind.conf                        
                    else 
                        echo "BIOS boot noticed. ";
                    fi
                    printf "\033c"
                    echo "Boot Loader theme installed successfully!"
                    echo ""
                    read -n1 -r -p "Press any key to continue..." key
                    break;;
                No ) printf "\033c"
                    echo "It's not that dangerous though! Feel free to try when you're ready. Tux will be waiting..."
                    echo ""
                    read -n1 -r -p "Press any key to continue..." key
                    break;;
                esac
            done ;;
    "3")    # Boot Logo
            printf "\033c"
            echo "Are you running Ubuntu 16.04?"
            echo ""
            echo "(Type 1 or 2, then press ENTER)"            
            select yn in "Yes" "No"; do
                case $yn in
                    Yes ) printf "\033c"
                        echo "Do you understand that changing boot loader theme (and potentially the boot"
                        echo "loader as well) is not without risk? And we can't be hold responsible if"  
                        echo "you proceed. Our website and internet can help but nothing is 100% safe."
                        echo ""
                        echo "(Type 1 or 2, then press ENTER)"
                        select yn in "Yes" "No"; do
                            case $yn in
                                Yes ) printf "\033c"
                                    if sudo -n true 2>/dev/null; then 
                                        :
                                    else
                                        echo "Tux will need sudo rights to copy and install everything, so he'll ask about that below."
                                        echo ""
                                        read -n1 -r -p "Press any key to continue..." key
                                    fi


                                    # Workaround what we think is an Ubuntu Plymouth bug that doesn't seem to allow foreign plymouth themes
                                    # so instead of simply sudo cp -r tux-plymouth-theme/ /usr/share/plymouth/themes/tux-plymouth-theme we 
                                    # have to (6 steps):
                                        
                                    # 1) Add other themes through the apt-get package 'plymouth-themes' that seem to work as well as 'xclip'
                                    # -package to successfully copy the internals of tux.script, tux.plymouth to a copy of the plymouth-themes's
                                    # 'script'-theme. To do this, we first check if xclip and plymouth-themes is installed, and if not, we ask the user if they
                                    # are okey with installing them. As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
                                    MISC="plymouth-themes xclip"
                                    for pkg in $MISC; do
                                        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
                                            echo -e "$pkg is already installed"
                                        else
                                            echo "Oops... Tux needs to use apt-get package $pkg to proceed."
                                            echo ""
                                            if sudo apt-get -qq install $pkg; then
                                                echo "Successfully installed $pkg"
                                            else
                                                echo "Error installing $pkg"
                                            fi        
                                        fi
                                    done

                                    # 2) Copy one of these themes, the theme called script.
                                    sudo cp -r /usr/share/plymouth/themes/script /usr/share/plymouth/themes/tux-plymouth-theme;  
                                    
                                    # 3) Add tux-plymouth-theme files
                                    sudo cp -r tux-plymouth-theme/* /usr/share/plymouth/themes/tux-plymouth-theme;
                                    
                                    # 4) Copy the internals of our files to existing using xclip
                                    xclip /usr/share/plymouth/themes/tux-plymouth-theme/tux.script;
                                    sudo bash -c '> /usr/share/plymouth/themes/tux-plymouth-theme/script.script';
                                    xclip -out | sudo tee -a /usr/share/plymouth/themes/tux-plymouth-theme/script.script;
                                    xclip /usr/share/plymouth/themes/tux-plymouth-theme/tux.plymouth;
                                    sudo bash -c '> /usr/share/plymouth/themes/tux-plymouth-theme/script.plymouth';
                                    xclip -out | sudo tee -a /usr/share/plymouth/themes/tux-plymouth-theme/script.plymouth;                          
                                    
                                    # 5) Remove our own files
                                    sudo rm /usr/share/plymouth/themes/tux-plymouth-theme/tux.plymouth;
                                    sudo rm /usr/share/plymouth/themes/tux-plymouth-theme/tux.script;
                                    
                                    # 6) And rename the newly created copies
                                    sudo mv /usr/share/plymouth/themes/tux-plymouth-theme/script.script /usr/share/plymouth/themes/tux-plymouth-theme/tux.script
                                    sudo mv /usr/share/plymouth/themes/tux-plymouth-theme/script.plymouth /usr/share/plymouth/themes/tux-plymouth-theme/tux.plymouth

                                    # Then we can add it to default.plymouth and update update-initramfs accordingly
                                    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/tux-plymouth-theme/tux.plymouth 100;
                                    printf "\033c"
                                    echo "Below you will see a list with all themes available to choose tux in the Plymouth menu next (if you want Tux that is ;)";
                                    echo ""
                                    read -n1 -r -p "Press any key to continue..." key
                                    sudo update-alternatives --config default.plymouth;
                                    printf "\033c"
                                    echo "Updating initramfs. This could take a while."
                                    sudo update-initramfs -u;
                                    printf "\033c"
                                    echo "Tux successfully moved in as your new Boot Logo."
                                    echo ""
                                    read -n1 -r -p "Press any key to continue..." key
                                    break;;
                                No ) printf "\033c"
                                    echo "It's not that dangerous though! Feel free to try when you're ready. Tux will be waiting."
                                    echo ""
                                    read -n1 -r -p "Press any key to continue..." key
                                    break;;
                                esac
                            done
                        break;;
                    No )  printf "\033c"
                        echo "We're working on adding support for other Linux distributions and Ubuntu"
                        echo "versions. So hang tight. Or edit this .sh file and give it a try. "
                        echo "Let us know if it works or doesn't! Tux will be happy for your contributions."
                        echo ""
                        read -n1 -r -p "Press any key to continue..." key
                        break;;
                esac
            done
            ;;
    "4")    
            printf "\033c"
            echo "Starting to copy files and changing dconf settings..."
            if sudo -n true 2>/dev/null; then 
                :
            else
                echo "Oops, Tux will need your sudo rights to copy and install everything."
            fi
            # Copying Tux icon before adding it
            sudo cp tux-login-theme/cof_tux.png /usr/share/unity-greeter/
            # Copying that needs to be run as su, and then lightdm. Put it in tmp for easier access
            sudo cp tux-login-theme/tux-login-gsettings.sh /tmp
            # Make it executable by all so that lightdm can run it
            sudo chmod 0755 /tmp/tux-login-gsettings.sh
            # Need to do it as su, otherwise changes don't take effect
            sudo bash tux-login-theme/tux-login-script.sh 
            # Now we can remove the script from tmp
            sudo rm /tmp/tux-login-gsettings.sh
            printf "\033c"
            echo "Successfully tuxedoed up your Login Screen."
            echo ""
            read -n1 -r -p "Press any key to continue..." key
            ;;
    "5")    
            printf "\033c"
            echo "Starting to copy files and changing dconf settings..."
            if sudo -n true 2>/dev/null; then 
                :
            else
                echo "Oops, Tux will need your sudo rights to copy and install everything."
            fi

            sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list"
            sudo apt-get update && sudo apt-get install arc-theme
            wget http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key
            sudo apt-key add - < Release.key
            sudo apt-get install unity-tweak-tool
            #wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install-papirus-home-gtk.sh | sh

            # Install paper-icon-theme
            sudo add-apt-repository ppa:snwh/pulp
            sudo apt-get update
            sudo apt-get install paper-icon-theme
            sudo apt-get install paper-gtk-theme
            sudo apt-get install paper-cursor-theme


            printf "\033c"
            echo "Successfully tuxedoed up your Unity Theme."
            echo ""
            read -n1 -r -p "Press any key to continue..." key
            ;;
    "Q")    exit                      ;;
    "q")    exit                      ;;
     * )    echo "invalid option"     ;;
    esac
    sleep 1
done
x-www-browser http://tux4ubuntu.blogspot.se/2016/11/done.html;
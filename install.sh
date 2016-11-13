#!/bin/bash
cd "$(dirname "$0")"
set -e
printf "\033c"
echo "#######################################################################################"
echo "# TUX 4 UBUNTU POLYMOUTH THEME                                                        #" 
echo "#######################################################################################"
echo "Hi and thanks for bringing Tux to Ubuntu!"
echo ""
echo "Are you running Ubuntu 16.04 LTS?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Do you understand that changing bootlogo is not without risk? Internet can help, but nothing is 100% safe.";
              select yn in "Yes" "No"; do
                  case $yn in
                    Yes ) echo "Ok, here we go! Remember to choose tux4ubuntu in the Plymouth menu next (if you want Tux that is ;)";
                          read -n1 -r -p "Press any key to continue..." key
                          echo ""
                          echo "But first, Tux need your sudo allowance to add your theme to system folders:"
                          sudo cp -r tux4ubuntu-plymouth-theme/ /usr/share/plymouth/themes/;
                          sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/tux4ubuntu-plymouth-theme/tux4ubuntu.plymouth 100;
                          sudo update-alternatives --config default.plymouth;
                          sudo update-initramfs -u;
                          break;;
                    No ) exit;;
                    esac
                done
              break;;
        No )  echo "Can't guarantee anything but just typing these commands and following instructions should do it:"
              echo ""
              echo "      Copy the theme (earlier Ubuntu versions had the themes in /lib/plymouth/themes/)"
              echo "          1) sudo cp -r tux4ubuntu/ /usr/share/plymouth/themes/"
              echo "      Add the theme to Plymouth (remember to change the folder adresses if needed)"
              echo "          2) sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/tux4ubuntu/tux4ubuntu.plymouth 100"
              echo "      Change the default theme, follow the instructions"
              echo "          3) sudo update-alternatives --config default.plymouth"
              echo "      Update initramfs"
              echo "          4) sudo update-initramfs -u"
              echo ""
              echo "Good luck!"
              exit;;
    esac
done
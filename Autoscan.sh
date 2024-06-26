#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root :)"
   exit 1
fi

# Function to read user input, and return boolean whether they confirm "[Y/n]"
# NOTE: Capital "Y" typically denotes default, so no resp (just enter key) will be "yes" (true)
confirmYes() {
   echo ""
   msg="${1:-Are you sure?}"
   read -r -p "${msg} [Y/n] " response
   case "$response" in
      [nN][oO]|[nN])
         return 1
         ;;
      *)
         return 0
         ;;
   esac
}

read -p "Enter the directory location: " DIR

# If provided $DIR is not a directory, ask user to create or quit
if [ ! -d "$DIR" ]; then
   echo "Dir not found: $DIR"
   if confirmYes "Create dir now?"; then
      mkdir -p "$DIR"
   else
      echo "Aborting, DIR not set"
      exit 1
   fi
fi

echo "Dir location you entered to save progress: $DIR"
read -p "Enter the IP: " IP
echo "The IP you are using: $IP"
read -p "Add Dir name if Ctf: " Ctf
cd "$DIR"
mkdir Results
cd Results

# If you want Ctf box name Directory otherwise Make Ip name Directory
if [[ "$Ctf" != "" ]]; then
   mkdir "$Ctf"
   cd "$Ctf"
else
   mkdir "$IP"
   cd "$IP"
fi

# Tools list you can add in the one you use mostly or use same
echo -e "Select multiple tools for scan

   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
   #  1. Nmap                          #
   #  2. Dirsearch                     #
   #  3. Nikto                         #
   #  4. Amass                         #
   #  5. subfinder                     #
   #  6. Gobuster                      #
   #  7. Nuclei                        #
   #  8. Wpscan                        #
   #  9. Hamster                       #
   #  10. Sqlmap                       #
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
"

IFS=, read -p "Selected tools (comma separated): " -a tools

for tool in "${tools[@]}"; do
   case $tool in
      1) sudo nmap -A -sC -sV -p- -v "$IP" -oN nmap ;;
      2) sudo dirsearch -u "$IP" -q -r -e php,js,db,xml,html -i 200-299,300-399,500-599 -format simple -o dirsearch;;
      3) nikto -url "$IP" -no404 -C all -Format txt -o nikto;;
      4) amass enum -d "$IP".com > amass;;
      5) subfinder -d "$IP" -o subfinder;;
      6) gobuster dir -u "$IP" -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -q -t 3 -r -x php,js,db,xml,html -o "$IP"_gobuster;;
      7) nuclei -u "$IP";;
      8) wpscan --url "$IP";;
      9) hamster -u "$IP";; # Assuming you meant Hamster tool
      10) sqlmap -u "$IP";;
      *)
      echo "Invalid option, script restarting"
      clear
      sleep 3
      exec "$0" # Restart the script
      ;;
   esac
done

# remove history
rm -rf /home/clown/.zsh_history
rm -rf /home/clown/.bash_history

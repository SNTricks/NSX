#!/bin/bash
clear

# NSX color scheme
r='\033[1;91m'
p='\033[1;95m'
y='\033[1;93m'
g='\033[1;92m'
n='\033[1;0m'
b='\033[1;94m'
c='\033[1;96m'

# NSX Symbols
X='\033[1;92m[\033[1;00m-\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m!\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
lm='\033[96m==========\033[0m!\033[96m==========\033[1;00m'
dm='\033[93m==========\033[0m!\033[93m==========\033[1;00m'

# NSX icons
OS="[OS]"
HOST="[HOST]"
KER="[KERNEL]"
UPT="[UPTIME]"
PKGS="[PACKAGES]"
SH="[SHELL]"
TERMINAL="[TERMINAL]"
CHIP="[CHIP]"
CPUI="[CPU]"
HOMES="[HOME]"

MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
VENDOR=$(getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")
devicename="${VENDOR} ${MODEL}"
THRESHOLD=100
random_number=$(( RANDOM % 2 ))

exit_script() {
    clear
    echo
    echo
    echo -e ""
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             c(___)o  .˚‧º‧˚"              
    echo -e "\n ${g}[${n}${KER}${g}] ${c}Exiting ${g}NSX Banner \033[1;36m"
    echo
    cd "$HOME"
    rm -rf NSX 2>/dev/null
    exit 0
}

trap exit_script SIGINT SIGTSTP

check_disk_usage() {
    local threshold=${1:-$THRESHOLD}
    local total_size
    local used_size
    local disk_usage

    total_size=$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $2}' || echo "0")
    used_size=$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $3}' || echo "0")
    disk_usage=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//g' || echo "0")

    if [ "$disk_usage" -ge "$threshold" ] 2>/dev/null; then
        echo -e "${g}[${n}!${g}] ${r}WARN: ${y}Disk Full ${g}${disk_usage}% ${c}| ${c}U${g}${used_size} ${c}of ${c}T${g}${total_size}"
    else
        echo -e "${y}Disk usage: ${g}${disk_usage}% ${c}| ${g}${used_size}"
    fi
}

data=$(check_disk_usage)

sp() {
    IFS=''
    sentence=$1
    second=${2:-0.05}
    for (( i=0; i<${#sentence}; i++ )); do
        char=${sentence:$i:1}
        echo -n "$char"
        sleep $second
    done
    echo
}

mkdir -p .NSX-simu 2>/dev/null

tr() {
    if ! command -v curl &>/dev/null; then
        pkg install curl -y >/dev/null 2>&1
    fi
    
    if ! command -v ncurses-utils &>/dev/null; then
        pkg install ncurses-utils -y >/dev/null 2>&1
    fi
}

help() {
    clear
    echo
    echo -e " ${p}■ ${g}Use Button${p}▪︎${n}"
    echo
    echo -e " ${y}Use Termux Extra key Button${n}"
    echo
    echo -e " UP          ↑"
    echo -e " DOWN        ↓"
    echo
    echo -e " ${g}Select option Click Enter button"
    echo
    echo -e " ${b}■ ${c}If you understand, click the Enter Button${b}▪︎${n}"
    read -p ""
}

help

spin() {
    echo
    local delay=0.40
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

    show_spinner() {
        local pid=$!
        while ps -p $pid > /dev/null 2>&1; do
            for i in "${spinner[@]}"; do
                echo -ne "\033[1;96m\r [+] Installing $1 please wait \e[33m[\033[1;92m$i\033[1;93m]\033[1;0m   "
                sleep $delay
                printf "\b\b\b\b\b\b\b\b"
            done
        done
        printf "   \b\b\b\b\b"
        printf "\e[1;93m [Done $1]\e[0m\n"
        echo
        sleep 1
    }

    apt update >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1
    
    packages=("git" "python" "ncurses-utils" "jq" "figlet" "termux-api" "lsd" "zsh" "ruby" "exa")

    for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            pkg install "$package" -y >/dev/null 2>&1 &
            show_spinner "$package"
        fi
    done

    pip install lolcat >/dev/null 2>&1
    rm -rf data/data/com.termux/files/usr/bin/chat >/dev/null 2>&1
    
    if [ -d "$HOME/NSX" ]; then
        mkdir -p $HOME/.NSX-simu 2>/dev/null
        cp $HOME/NSX/files/report $HOME/.NSX-simu/ 2>/dev/null
        cp $HOME/NSX/files/chat.sh /data/data/com.termux/files/usr/bin/chat 2>/dev/null
        chmod +x /data/data/com.termux/files/usr/bin/chat 2>/dev/null
    fi
    
    if [ ! -d ~/.oh-my-zsh ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh >/dev/null 2>&1
    fi
    
    rm -rf /data/data/com.termux/files/usr/etc/motd 2>/dev/null
    chsh -s zsh 2>/dev/null
    rm -rf ~/.zshrc >/dev/null 2>&1
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc 2>/dev/null
    
    if [ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions >/dev/null 2>&1
    fi
    
    if [ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting >/dev/null 2>&1
    fi
    
    if ! command -v lolcat &>/dev/null; then
        echo "y" | gem install lolcat > /dev/null 2>&1
    fi
}

setup() {
    ds="$HOME/.termux"
    dx="$ds/font.ttf"
    simu="$ds/colors.properties"
    
    mkdir -p "$ds" 2>/dev/null
    
    if [ ! -f "$dx" ] && [ -d "$HOME/NSX" ]; then
        cp $HOME/NSX/files/font.ttf "$ds" 2>/dev/null
    fi

    if [ ! -f "$simu" ] && [ -d "$HOME/NSX" ]; then
        cp $HOME/NSX/files/colors.properties "$ds" 2>/dev/null
    fi
    
    if [ -d "$HOME/NSX" ]; then
        mkdir -p $PREFIX/share/figlet/ 2>/dev/null
        cp $HOME/NSX/files/ASCII-Shadow.flf $PREFIX/share/figlet/ 2>/dev/null
        cp $HOME/NSX/files/remove /data/data/com.termux/files/usr/bin/ 2>/dev/null
        chmod +x /data/data/com.termux/files/usr/bin/remove 2>/dev/null
    fi
    
    termux-reload-settings 2>/dev/null
}

dxnetcheck() {
    clear
    echo
    echo -e "               ${g}╔═══════════════╗"
    echo -e "               ${g}║ ${n}</>  ${c}NSX${g}      ║"
    echo -e "               ${g}╚═══════════════╝"
    echo -e "  ${g}╔════════════════════════════════════════════╗"
    echo -e "  ${g}║  ${C} ${y}Checking Your Internet Connection!${g}  ║"
    echo -e "  ${g}╚════════════════════════════════════════════╝${n}"
    
    while true; do
        if curl --silent --head --fail https://github.com > /dev/null; then
            break
        else
            echo -e "              ${g}╔══════════════════╗"
            echo -e "              ${g}║${C} ${r}No Internet ${g}║"
            echo -e "              ${g}╚══════════════════╝"
            sleep 2.5
        fi
    done
    clear
}

donotchange() {
    clear
    echo
    echo
    echo -e ""
    echo -e "${c}              (\_/)"
    echo -e "              (${y}^_^${c})     ${A} ${g}Hey dear${c}"
    echo -e "             c(___)o  .˚‧º‧˚"
    echo
    echo -e " ${A} ${c}Please Enter Your ${g}Banner Name${c}"
    echo
    
    read -p "[+]──[Enter Your Name]────► " name
    echo
    
    INPUT_FILE="$HOME/NSX/files/.zshrc"
    USERNAME_FILE="$HOME/.termux/usernames.txt"
    
    if [ -f "$INPUT_FILE" ]; then
        sed "s/SIMU/$name/g" "$INPUT_FILE" > "$HOME/.zshrc" 2>/dev/null
        sed "s/SIMU/$name/g" "$HOME/NSX/files/.nsx.zsh-theme" > "$HOME/.oh-my-zsh/themes/nsx.zsh-theme" 2>/dev/null
        echo "$name" > "$USERNAME_FILE" 2>/dev/null
        
        clear
        echo
        echo
        echo -e "		        ${g}Hey ${y}$name"
        echo -e "${c}              (\_/)"
        echo -e "              (${y}^ω^${c})     ${g}I'm NSX-Simu${c}"
        echo -e "             c(___)o  .˚‧º‧˚"
        echo
        echo -e " ${A} ${c}Your Banner created ${g}Successfully!${c}"
        echo
        sleep 3
    else
        echo
        echo -e " ${E} ${r}Error: NSX files not found!"
        sleep 1
    fi
    
    VERSION="$HOME/.termux/nsx.txt"
    echo "version 1 1.5" > "$VERSION" 2>/dev/null
    echo
    clear
}

banner() {
    echo
    echo
    echo -e "   ${y}░███╗░░██╗░██████╗██╗░░██╗"
    echo -e "   ${y}████╗░██║██╔════╝╚██╗██╔╝"
    echo -e "   ${y}██╔██╗██║╚█████╗░░╚███╔╝░"
    echo -e "   ${c}██║╚████║░╚═══██╗░██╔██╗░"
    echo -e "   ${c}██║░╚███║██████╔╝██╔╝╚██╗"
    echo -e "   ${c}╚═╝░░╚══╝╚═════╝░╚═╝░░╚═╝${n}"
    echo -e "${y}               +-+-+-+-+-+"
    echo -e "${c}               |N|S|X|"
    echo -e "${y}               +-+-+-+-+-+${n}"
    echo
    
    if [ $random_number -eq 0 ]; then
        echo -e "${b}╭════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ツ${g}] GitHub: ${y}github.com/SNTricks"
        echo -e "${b}╰════════════════════════⊷"
    else
        echo -e "${b}╭══════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ツ${g}] Repo: ${y}github.com/SNTricks/NSX"
        echo -e "${b}╰══════════════════════════⊷"
    fi
    
    echo
    echo -e "${b}╭══ ${g}〄 ${y}NSX ${g}〄"
    echo -e "${b}┃❁ ${g}Creator: ${y}SNTricks"
    echo -e "${b}┃❁ ${g}Device: ${y}${VENDOR} ${MODEL}"
    echo -e "${b}╰┈➤ ${g}Hey ${y}Dear"
    echo
}

termux() {
    spin
}

setupx() {
    if [ -d "/data/data/com.termux/files/usr/" ]; then
        tr
        dxnetcheck
        
        banner
        echo -e " ${C} ${y}Detected Termux on Android!"
        echo -e " ${lm}"
        echo -e " ${A} ${g}Updating Package..!"
        echo -e " ${dm}"
        echo -e " ${A} ${g}Wait a few minutes.${n}"
        echo -e " ${lm}"
        termux
        
        if [ -d "$HOME/NSX" ]; then
            sleep 2
            clear
            banner
            echo -e " ${A} ${p}Updating Completed...!!"
            echo -e " ${dm}"
            clear
            banner
            echo -e " ${C} ${c}Package Setup Your Termux..${n}"
            echo
            echo -e " ${A} ${g}Wait a few minutes.${n}"
            setup
            donotchange
            clear
            banner
            echo -e " ${C} ${c}Type ${g}exit ${c} then ${g}enter ${c}Now Open Your Termux!! ${g}[${n}${HOMES}${g}]${n}"
            echo
            sleep 3
            cd "$HOME"
            rm -rf NSX 2>/dev/null
            exit 0
        else
            clear
            banner
            echo -e " ${E} ${r}NSX Tools Not Found!"
            echo
            echo
            sleep 3
            exit 1
        fi
    else
        echo -e " ${E} ${r}Sorry, this operating system is not supported ${p}| ${g}[${n}${HOST}${g}] ${SHELL}${n}"
        echo 
        echo -e " ${A} ${g} Wait for the next update using Linux...!!"
        echo
        sleep 3
        exit 1
    fi
}

banner2() {
    echo
    echo
    echo -e "   ${y}░███╗░░██╗░██████╗██╗░░██╗"
    echo -e "   ${y}████╗░██║██╔════╝╚██╗██╔╝"
    echo -e "   ${y}██╔██╗██║╚█████╗░░╚███╔╝░"
    echo -e "   ${c}██║╚████║░╚═══██╗░██╔██╗░"
    echo -e "   ${c}██║░╚███║██████╔╝██╔╝╚██╗"
    echo -e "   ${c}╚═╝░░╚══╝╚═════╝░╚═╝░░╚═╝${n}"
    echo -e "${y}               +-+-+-+-+-+"
    echo -e "${c}               |N|S|X|"
    echo -e "${y}               +-+-+-+-+-+${n}"
    echo
    
    if [ $random_number -eq 0 ]; then
        echo -e "${b}╭════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ツ${g}] GitHub: ${y}github.com/SNTricks"
        echo -e "${b}╰════════════════════════⊷"
    else
        echo -e "${b}╭══════════════════════════⊷"
        echo -e "${b}┃ ${g}[${n}ツ${g}] Repo: ${y}github.com/SNTricks/NSX"
        echo -e "${b}╰══════════════════════════⊷"
    fi
    
    echo
    echo -e "${b}╭══ ${g}〄 ${y}NSX ${g}〄"
    echo -e "${b}┃❁ ${g}Creator: ${y}SNTricks"
    echo -e "${b}╰┈➤ ${g}Hey ${y}Dear"
    echo
    echo -e "${c}╭════════════════════════════════════════════════⊷"
    echo -e "${c}┃ ${p}❏ ${g}Choose what you want to use. then Click Enter${n}"
    echo -e "${c}╰════════════════════════════════════════════════⊷"
}

options=("Free Usage" "Premium")
selected=0

display_menu() {
    clear
    banner2
    echo
    echo -e " ${g}■ ${p}Select An Option${g}▪︎${n}"
    echo
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e " ${g}〄> ${c}${options[$i]} ${g}<〄${n}"
        else
            echo -e "     ${options[$i]}"
        fi
    done
}

while true; do
    display_menu

    read -rsn1 input

    if [[ "$input" == $'\e' ]]; then
        read -rsn2 -t 0.1 input
        case "$input" in
            '[A')
                ((selected--))
                if [ $selected -lt 0 ]; then
                    selected=$((${#options[@]} - 1))
                fi
                ;;
            '[B')
                ((selected++))
                if [ $selected -ge ${#options[@]} ]; then
                    selected=0
                fi
                ;;
            *)
                display_menu
                ;;
        esac
    elif [[ "$input" == "" ]]; then
        case ${options[$selected]} in
            "Free Usage")
                echo -e "\n ${g}[${n}${HOMES}${g}] ${c}Continue Free..!${n}"
                sleep 1
                setupx
                ;;
            "Premium")
                echo -e "\n ${g}[${n}${HOST}${g}] ${c}Redirecting to GitHub..!${n}"
                sleep 1
                xdg-open "https://github.com/SNTricks/NSX"
                cd "$HOME"
                rm -rf NSX 2>/dev/null
                exit 0
                ;;
        esac
    fi
done

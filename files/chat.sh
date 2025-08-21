#!/bin/bash
clear

if ! command -v curl &> /dev/null; then
    pkg install curl -y &> /dev/null
fi

clear

r='\033[1;91m'
p='\033[1;95m'
y='\033[1;93m'
g='\033[1;92m'
n='\033[1;0m'
b='\033[1;94m'
c='\033[1;96m'

# NSX Symbol
X='\033[1;92m[\033[1;00m-\033[1;92m]\033[1;96m'
D='\033[1;92m[\033[1;00m!\033[1;92m]\033[1;93m'
E='\033[1;92m[\033[1;00m×\033[1;92m]\033[1;91m'
A='\033[1;92m[\033[1;00m+\033[1;92m]\033[1;92m'
C='\033[1;92m[\033[1;00m</>\033[1;92m]\033[92m'
lm='\033[1;96m==========\033[1;0m!\033[1;96m==========\033[1;00m'
dm='\033[1;93m==========\033[1;0m!\033[1;93m==========\033[1;00m'

# Use your Render.com URL or localhost for testing
URL="https://nsx-chat.onrender.com"
USERNAME_DIR="$HOME/.NSX"
USERNAME_FILE="$USERNAME_DIR/usernames.txt"
random_number=$(( RANDOM % 2 ))

inter() {
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

load() {
    clear
    echo -e " ${r}●${n}"
    sleep 0.2
    clear
    echo -e " ${r}●${y}●${n}"
    sleep 0.2
    clear
    echo -e " ${r}●${y}●${b}●${n}"
    sleep 0.2
}

check_warnings() {
    warning=$(curl -s "$URL/warnings" 2>/dev/null | jq -r --arg user "$username" '.[] | select(.username == $user) | "Warning — |\(.username)|  \(.warning)"' 2>/dev/null || echo "")
    if [ -n "$warning" ]; then
        echo -e "         ${r}$warning${n}"
    fi
}

broken() {
    clear
    echo
    echo -e "${c}       (\\_/)"
    echo -e "      ( ${g}o${p}.${g}o${c} )   .·°'¨ðŸ¤—ðŸ˜”"
    echo -e "      / >ðŸ“» )"
    echo -e "     ( /_\\ )"
    echo
    sleep 0.5
    echo -e " ${C} ${g}Goodbye! ${y}(${c}-${r}.${c}-${y})${c}Zzz···ðŸ¤”"
    echo
    exit 0
}

goodbye() {
    clear
    echo
    echo -e "${c}     ···ðŸŽ‰ ···"
    echo -e "      (${b}_${p}_ ${b}.${c}7"
    echo -e "       |~^"
    echo -e "       (_))#"
    echo
    sleep 0.5
    echo -e " ${C} ${g}Goodbye! ${y}(${c}-${r}.${c}-${y})${c}Zzz···|"
    echo
    exit 0
}

dx() {
    clear
    echo
    echo -e " ${p}■ ${g}Use Tools${p}▪︎${n}"
    echo
    echo -e " ${y}Enter ${g}q ${y}Exit Tool${n}"
    echo
    echo -e "             q"
    echo
    echo -e " ${b}■ ${c}If you understand, click the Enter Button${b}▪︎${n}"
    read -p ""
}

display_messages() {
    clear
    banned=$(curl -s "$URL/ban" 2>/dev/null | jq -r --arg user "$username" '.[] | select(.username == $user) | "Banned — |\(.username)|  \(.bn_mesg)"' 2>/dev/null || echo "")
    if [ -n "$banned" ]; then
        load
        echo -e "     ${c}____    __    ____  _  _     _  _ "
        echo -e "    ${c}(  _ \  /__\  (  _ \( )/ )___( \/ )"
        echo -e "    ${y} )(_) )/(__)\  )   / )  ((___))  ("
        echo -e "   ${y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n"
        echo -e "         ${r}$banned${n}"
        echo
        exit 0
    fi
    
    clear
    load
    while true; do
        clear
        echo -e " ${r}●${y}●${b}●${n}"
        check_warnings
        
        D=$(date +"${c}%Y-%b-%d${n}")
        T=$(date +"${c}%I:%M %p${n}")
        echo -e "${lm}"
        echo -e " $D"
        echo -e "  ${c}┌──┐┌┐"
        echo -e "  ${c}│  │││               ${C} ${g}github.com/SNTricks"
        echo -e "  ${c}└──┘└┘"
        echo -e "  $T"
        echo -e "${lm}"

        msg=$(curl -s "$URL/messages" 2>/dev/null | jq -r '.[] | "\(.username): \(.message)"' 2>/dev/null || echo "No messages")
        echo -e "${g}$msg"
        
        ads=$(curl -s "$URL/ads" 2>/dev/null | jq -r '.[]' 2>/dev/null || echo "")
        echo -e "${c}$ads${c}\n"

        read -p "[+]-[Enter Message | $username]-> " message
        if [[ "$message" == "q" ]]; then
            echo
            echo -e "\n ${E} ${r}Exiting Tool..!\n"
            sleep 1
            if [ $random_number -eq 0 ]; then
                goodbye
            else
                broken
            fi
            break
        else
            curl -s -X POST -H "Content-Type: application/json" -d "{\"username\":\" $username\", \"message\":\"$message\"}" "$URL/send" &> /dev/null
        fi
    done
}

mkdir -p "$USERNAME_DIR"

save_username() {
    clear
    load
    echo -e "        ${c}____    __    ____  _  _     _  _ "
    echo -e "       ${c}(  _ \  /__\  (  _ \( )/ )___( \/ )"
    echo -e "       ${y} )(_) )/(__)\  )   / )  ((___))  ("
    echo -e "      ${y} (____/(__)(__)(_)\_)(_)\_)   (_/\_)\n\n"
    echo -e " ${A} ${c}Enter Your Anonymous ${g}Username${c}"
    echo
    read -p "[+]-[Enter Your Username]----> " username

    if [[ -z "$username" ]]; then
        echo -e "${r}Username cannot be empty!${n}"
        save_username
        return
    fi

    sleep 1
    clear
    echo
    echo -e "		        ${g}Hey ${y}$username"
    echo -e "${c}              (\\_/)"
    echo -e "              (${y}^ω^${c})     ${g}I'm NSX-Simu${c}"
    echo -e "             c(___)o  .·°'¨"
    echo
    echo -e " ${A} ${c}Your account created ${g}Successfully!${c}"
    
    echo "$username" > "$USERNAME_FILE"
    echo
    sleep 1
    echo -e " ${D} ${c}Enjoy Our Chat Tool!"
    echo
    read -p "[+]-[Enter to back]----> "
    dx
    display_messages
}

if [ -f "$USERNAME_FILE" ]; then
    username=$(cat "$USERNAME_FILE")
else
    save_username
    username=$(cat "$USERNAME_FILE")
fi

inter
display_messages

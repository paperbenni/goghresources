#!/bin/bash

# this script fetches and converts gogh color schemes to xresources colorschemes

checkcommand() {
    if ! command -v "$1" &>/dev/null; then
        if command -v instantinstall &>/dev/null; then
            instantinstall "$1"
        else
            echo "please install $1, it is required to run goghresources"
            exit 1
        fi
    fi
}

checkcommand fzf
checkcommand git

if ! [ -e ~/.cache/goghresources/gogh ]; then
    echo 'getting gogh cache'
    mkdir -p ~/.cache/goghresources/
    cd ~/.cache/goghresources/ || exit 1
    git clone --depth=1 https://github.com/Mayccoll/Gogh.git ./gogh
fi

cd ~/.cache/goghresources/gogh/themes || exit 1

CHOICE="$(
    find . | grep -o '[^./]*' | sed '/^sh$/d' | fzf
)"

[ -z "$CHOICE" ] && exit

XRESOURCES=""
THEMECONTENT="$(cat "./$CHOICE.sh")"
[ -z "$THEMECONTENT" ] && exit

app() {
    XRESOURCES="$XRESOURCES
$1"
}

readcolor() {
    CURCOLOR="$(grep 'export COLOR_'"$1" <<<"$THEMECONTENT" | grep -Eo '"#[0-9a-fA-F]{6}"' | grep -o '[^"]*')"
    [ -z "$CURCOLOR" ] && return

    XRESOURCES="$XRESOURCES
!$3
*color$2: $CURCOLOR
"

}

readspecial() {
    CURCOLOR="$(grep "export ${1}_COLOR" <<<"$THEMECONTENT" | grep -Eo '"#[0-9a-fA-F]{6}"' | grep -o '[^"]*')"
    [ -z "$CURCOLOR" ] && return
    XRESOURCES="$XRESOURCES
*$2: $CURCOLOR"
}

readcolor 01 0 black
readcolor 02 1 red
readcolor 03 2 green
readcolor 04 3 yellow
readcolor 05 4 blue
readcolor 06 5 magenta
readcolor 07 6 cyan
readcolor 08 7 white
readcolor 09 8 gray
readcolor 10 9 light-red
readcolor 11 10 light-green
readcolor 12 11 light-yellow
readcolor 13 12 light-blue
readcolor 14 13 light-magenta
readcolor 15 14 light-cyan
readcolor 16 15 light-white

readspecial BACKGROUND background
readspecial FOREGROUND foreground
readspecial CURSOR cursorColor

echo "$XRESOURCES"

[ -e ~/.Xresources.d/grogh/ ] || mkdir -p ~/.Xresources.d/grogh
cd ~/.Xresources.d/grogh || exit 1
echo "$XRESOURCES" >./"$CHOICE"

INCLUDESTRING="#include \".Xresources.d/grogh/$CHOICE\""

if ! [ -e ~/.Xresources ]; then
    echo "$INCLUDESTRING" >~/.Xresources
else
    if grep -q '.Xresources.d/grogh' ~/.Xresources; then
        sed -i '/Xresources.d\/grogh/c\'"$INCLUDESTRING" ~/.Xresources
    else
        echo "$INCLUDESTRING" >>~/.Xresources
    fi
fi

xrdb ~/.Xresources
echo "finished applying $CHOICE, please restart your terminal to see the changes"

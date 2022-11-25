if [[ -s ~/tmp/.z ]] then
export _Z_DATA=~/tmp/.z
. /usr/local/etc/profile.d/z.sh
alias j='z'
fi

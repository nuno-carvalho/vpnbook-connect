#!/usr/bin/env bash

echo "Available OpenVPN Servers:"
ls -1 vpnbook-*53.ovpn | grep -P -o -e '(?<=vpnbook-)(.*?)(?=-ud)'
read -p "Choose server: " serv


printf '%s\n' "Available Protocols for Server: ${serv}"
ls -1 vpnbook-${serv}*.ovpn | grep -P -o -e '(?<=vpnbook-...-)(.*?)(?=.ovpn)'
read -p "Choose Protocol: " proto

server="vpnbook-${serv}-${proto}.ovpn"
echo $server

if test -f "$server"; then
    echo "File $server exist"
else
    echo "File $server does not exist. Exiting....."
    exit 1
fi


url='https://mobile.twitter.com/vpnbook'
html=$( curl -# -L "${url}" 2> '/dev/null' )

username=$(
  <<< "${html}" \
  grep -P -o -e '(?<=Username: )(.*?)(?=Password)' |
  head -n 1
)

password=$(
  <<< "${html}" \
  grep -P -o -e '(?<=Password: )(.{7})' |
  head -n 1
)


echo "Auth data fetch from twitter"
printf '%s\n' "Username: ${username}" "Password: ${password}"

echo ${username} > auth.cfg
echo ${password} >> auth.cfg


openvpn --config ${server} --auth-user-pass auth.cfg

#rm auth.cfg

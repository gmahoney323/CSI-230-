#!/bin/bash

filename='emails.txt'

if [ $EUID -ne 0 ]; then
	echo "Must Run as Root"
	exit 2
fi

getUsername()
{
  while read j
  do
    echo ${j} | cut -d "@" -f 1
  done < $filename
}

createRandomPassword()
{
  openssl rand -base64 12 | tr -d =+/
}

echo $(getUsername)
echo $(createRandomPassword)

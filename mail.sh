#!/bin/bash

filename='emails.txt'
groupname=CSI230
shellpath=/bin/bash

if [ $EUID -ne 0 ]; then
	echo "Must Run as Root"
	exit 2
fi

listUsername()
{
  while read j
  do
    echo ${j} | cut -d "@" -f 1
  done < $filename
}

getEmailAddress()
{
  line=$1
  sed "${line}q;d" $filename
}

getUsername()
{
  line=$1
  sed "${line}q;d" $filename | cut -d "@" -f 1
}

createRandomPassword()
{
  openssl rand -base64 12 | tr -d =+/
}

createUser()
{
  usern=$1
  pass=$2
  email=$3
  #command on $usern
  #echo "username is ${usern}"
  #echo "password is ${pass}"

  exists=`grep -c ${usern}: /etc/passwd`
  echo "existence status: ${exists}"
  #checks if user does not exist
  if [ $exists = 0 ]; then
    useradd -m -p $pass -s $shellpath -g $groupname $usern
    chage -d 0 $usern
  else
    echo "reset password"
    passwd $usern
  fi
  #echo "new user ${usern} created with id" gid $usern
}

echo $(listUsername)
echo $(createRandomPassword)
echo $(createUser $(getUsername 1) $(createRandomPassword) $(getEmailAddress 1))
echo $(getUsername 2)

#!/bin/bash

# constants for the group the new users will be put in and their default shell
groupname=CSI230
shellpath=/bin/bash

# checks whether or not the user is running this script as root
# if not, exits with code 2
if [ $EUID -ne 0 ]; then
	echo "Must Run as Root"
	exit 2
fi

# demonstrates proper usage of this script
usage()
{
  echo "$0 usage: [-f input file]"
  exit 1
}

# lists all the usernames in the file
listUsername()
{
  while read j
  do
    echo ${j} | cut -d "@" -f 1
  done < $f
}

# gets the email at a given line
getEmailAddress()
{
  line=$1
  sed "${line}q;d" $f
}

# gets the username at a given line by cutting it from that email
getUsername()
{
  line=$1
  sed "${line}q;d" $f | cut -d "@" -f 1
}

# generates a string of characters of length 12
# tr -d =+/ removes those special characters
createRandomPassword()
{
  openssl rand -base64 12 | tr -d =+/
}

# creates a user based on the following:
# username, password, and email address
# new users will be in group CSI230 and have default shell bash
# emails all newly created users their temporary passwords
# requires that the new users' reset their passwords upon next login
createUser()
{
  usern=$1
  pass=$2
  email=$3
  # grep -c returns the number of times the parameter appeared
  # thus if grep -c returns 0, what you are looking for does not exist
  exists=`grep -c ${usern}: /etc/passwd`

  # checks if user does not exist
  if [ $exists = 0 ]; then
    useradd -m -s $shellpath -g $groupname $usern
    echo "Created user ${usern}."
  else
    echo "Password for ${usern} has been updated."
  fi
  echo ${usern}:${pass} | chpasswd
  chage -d 0 $usern
  mail -s "Temporary Password - Reset Required" $email <<< "Dear ${usern}, your temporary password is ${pass}. You will be instructed to change your password upon next login."
  echo "Sent temporary password to ${usern}'s email address."
}

# handles the -f flag of ./mail.sh
while getopts ":f:" options;
do
  case "${options}" in
  f)
    f=${OPTARG}
    #do nothing, working as intended
    if [ -e ${f} ]; then
      echo "${f} exists"
    else
      echo "${f} does not exist"
      usage
    fi
  ;;
  *)
    usage
  ;;
  esac
done

count=0
# executes createUser() for each line in the input file
while read p; do
  count=$(($count+1))
  echo $(createUser $(getUsername $count) $(createRandomPassword) $(getEmailAddress $count))
done < $f

#!/bin/bash


#Description
##Script that creates new  users to the same local system.
## It will prompt to enter username (login), person's full name, and passwod
## The username, password and host for the account will be displayed

##Update:
#Automatically generate a password for each new account
#Just specify the account name and account comments on command line
#instead of being prompted for them

###########



#Make sure script is being executed with superuser privileges.

if [[ "${UID}" -ne 0 ]]
then
  echo "This user does not have root privileges to create an account"
  echo "Please run with sudo or as root."
  exit 1
fi


#Make sure more than 0 arguments is provided into command line
if [[ "${#}" -lt 1 ]]
then
  echo "Usage: ${0} USER_NAME [COMMENT]..."
  echo "Create an account on the local system with the name of USER_NAME and a comments field of COMMENT."
  exit 1
fi


#Loop through arguments and create new user using While and Switch
#Simultaneously generate random password for each user

while [[ "${#}" -gt 0 ]]
do
  USER_NAME="${1}"
  COMMENT="${2}"
  SPECIAL_CHAR=$( echo "!@#$%^&*()_-+=" | fold -w1 | shuf | head -c 1)
  BASE_PASSWORD=$( date +%s%N | sha256sum | head -c42)
  PASSWORD=${BASE_PASSWORD}${SPECIAL_CHAR}
  useradd -c "${COMMENT}" -m ${USER_NAME}
  if [[ "${?}" -ne 0 ]]
  then 
    echo 'The account could not be created.' 
    exit 1
  fi
  echo ${PASSWORD} | passwd --stdin ${USER_NAME}
  if [[ "${?}" -ne 0 ]]
  then 
    echo 'The password for the account could not be set.' 
    exit 1
  fi
  passwd -e ${USER_NAME}
  echo
  echo "username: ${USER_NAME}"
  echo
  echo "password ${PASSWORD}"
  echo
  echo "host: $HOSTNAME"
  shift 2
done



exit 0

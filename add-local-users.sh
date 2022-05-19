#!/bin/bash


#Description
##Script that creates new  users to the same local system.
## It will prompt to enter username (login), person's full name, and passwod
## The username, password and host for the account will be displayed

#Make sure script is being executed with superuser privileges.

if [[ "${UID}" -ne 0 ]]
then
  echo "This user does not have root privileges to create an account"
  echo "Please run with sudo or as root."
  exit 1
fi


#Prompt for Username
read -p 'Enter a Username for the account: ' USER_NAME


#Prompt for Name 
read -p 'Enter the account owners full name: ' COMMENT

#Prompt for Password
read -p 'Enter the password for the new account: ' PASSWORD


#Create new user on the local system
#The -m flag ensures home-directory is created
useradd -c "${COMMENT}" -m ${USER_NAME}

# Check to see if the useradd command succeeded.

if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.'
  exit 1
fi

# Set the password for the account

echo ${PASSWORD} | passwd --stdin ${USER_NAME}

if [[ "${?}" -ne 0 ]]
then 
  echo 'The password for the account could not be set.'
  exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME}

echo
echo "Username: ${USER_NAME} with password ${PASSWORD} has been successfully created on $HOSTNAME"

exit 0




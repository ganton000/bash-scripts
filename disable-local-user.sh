#!/bin/bash


#Description
## This script will allow for a local Linux account to be disabled,
## deleted, and optionally archived.

readonly ARCHIVE_DIR='/archive'

# Function which outputs description/usage for this script and exit.
usage() {
  echo "Usage: ${0} [-dra]  USER_NAME [USER_NAME]... " >&2
  echo "Disables local Linux account(s)." >&2
  echo "-d Deletes accounts instead of disabling them." >&2
  echo "-r Removes the home directory associated with the account(s)." >&2
  echo "-a Creates archive of home directory associated with the account(s) and stores the archive in the /archives directory." >&2
  exit 1
}

# Check to see if user has root privileges
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run with sudo or as root account.' >&2
  exit 1
fi


# Parse the command line options
while getopts dra OPTION
do
  case ${OPTION} in
    d)
      DELETE='true' ;;
    r)
      REMOVE_DIRECTORY='-r' ;;
    a)
      ARCHIVE='true' ;;
    ?)
      usage
  esac
done

# Remove the options while leaving remaining arguments
shift "$(( OPTIND -1 ))"

#If the user doesn't supply any more arguments, provide help.
if [[ "${#}" -lt 1 ]] 
then
  usage
fi


# Loop through all usernames supplied as arguments.
for USER in "${@}"
do
  echo "Processing user: ${USER}"

  # Make sure the UID of the account is at least 1000.
  USERID=$(id -u ${USER})
  if [[ "${USERID}" -lt 1000 ]]
  then
    echo "The username ${USER} is a system account and has therefore not been deleted." >&2
    echo "Please reach out to your system adminstrator for changes to this account." >&2
    exit 1
  fi
 
  # Create an archive if requested
  if [[ "${ARCHIVE}" = 'true' ]] 
  then
    # Check if ARCHIVE_DIR exists.
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "Creating ${ARCHIVE_DIR} directory."
      mkdir -p ${ARCHIVE_DIR}
      
      # Check to see mkdir command worked
      if [[ "${?}" -ne 0 ]]
      then
        echo "The archive directory ${ARCHIVE_DIR} could not be created" >&2
        exit 1
      fi
    fi

    # Archive the user's home directory and move into ARCHIVE_DIR
    HOME_DIR="/home/${USER}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USER}.tgz"
    # Check HOME_DIR exists
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
    
      # Check to see tar executes successfully.
      if [[ "${?}" -ne 0 ]]
      then
        echo "Could not create ${ARCHIVE_FILE}." >&2
        exit 1
      fi
    else
      echo "${HOME_DIR} does not exist or is not a directory." >&2
      exit 1
    fi
  fi

  if [[ "${DELETE}" = 'true' ]]
  then
    # Delete the user
    userdel ${REMOVE_DIRECTORY} ${USER}

    # Check to see userdel executes successfully
    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USER} was NOT deleted." >&2
      exit 1
    fi
    echo "The account ${USER} was deleted."
  else
    #Delete is not set to true, so expire it instead (default)
    chage -E 0 ${USER}
 
    # Check to see chage executes successfully
    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USER} was NOT disabled." >&2
      exit 1
    fi
    echo "The account ${USER} was disabled."
  fi
done

exit 0



 

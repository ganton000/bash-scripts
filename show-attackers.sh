#!/bin/bash


# Description
## Count failed login attempts within local system log files
## If any IPs are over LIMIT failures, display the count, IP and location

LIMIT='10'
LOG_FILE="${1}"

#Check Log file exists
if [[ ! -e "${LOG_FILE}" ]] 
then 
  echo "Cannot access file: ${LOG_FILE}." >&2
  exit 1
fi

#Display the CSV header.
echo 'Count, IP, Location'

# Loop through the list of failed attempts and corresponding IP addresses.

grep Failed ${LOG_FILE} | awk '{print $(NF - 3)}' | sort | uniq -c | sort -nr | while read COUNT IP
do
  # If number of failed attempts is greater than limit, then
  # display count, IP and location.
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${COUNT}, ${IP}, ${LOCATION}"
  fi
done

exit 0



 

#!/bin/bash

echo "Running the entrypoint.sh script..."

# Start Supervisor
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error while starting the supervisor daemon"
    exit $retVal
fi

echo "...done with entrypoint.sh"
exit 0

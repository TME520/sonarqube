#!/bin/bash

echo "Running the entrypoint.sh script..."

# Caching configuration and routes
su - www -c "php /var/www/artisan config:cache" &> /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error while caching configuration"
    exit $retVal
fi

su - www -c "php /var/www/artisan route:cache" &> /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error while caching route"
    exit $retVal
fi

# Run database migration
su - www -c "php /var/www/artisan migrate" &> /dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error during database migration"
    exit $retVal
fi

# Start Supervisor
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error while starting the supervisor daemon"
    exit $retVal
fi

echo "...done with entrypoint.sh"
exit 0

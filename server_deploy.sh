#!/bin/sh
set -e

APP_NAME=$(grep DOCKER_APP_NAME .env | cut -d '=' -f2)-app

echo "Deploying application ..."

# Enter maintenance mode
(docker exec ${APP_NAME} php artisan down) || true
    # Update codebase
    git fetch origin production
    git reset --hard origin/production

    # Install dependencies based on lock file
    docker exec ${APP_NAME} /usr/local/bin/composer install

    # Clear cache
    docker exec ${APP_NAME} php artisan cache:clear

    # Clear config cache
    docker exec ${APP_NAME} php artisan config:cache

    # Clear route cache
    docker exec ${APP_NAME} php artisan route:cache

    # Clear view cache
    docker exec ${APP_NAME} php artisan view:clear

    # Migrate database
    docker exec ${APP_NAME} php artisan migrate --force
# Exit maintenance mode
docker exec ${APP_NAME} php artisan up

echo "Application deployed!"

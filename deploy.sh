#!/bin/bash

# GitHub Token for accessing the repository
GITHUB_TOKEN="your_token_here"

# Script Variables
REPO_URL="https://$GITHUB_TOKEN@github.com/frbarbre/ez-deploy-test-project"
APP_DIR=~/ezdeploy/myapp
SWAP_SIZE="1G"
DOMAIN_NAME="ezdeploy.frederikbarbre.dk"
EMAIL="fr.barbre@gmail.com"
NGINX_CONFIG_NAME="ezdeploy"

# Environment Variables
POSTGRES_USER="very_secret_value"
POSTGRES_PASSWORD="very_secret_value"
POSTGRES_DB="very_secret_value"


# Update and install dependencies
sudo apt update && sudo apt upgrade -y

# Add Swap Space
echo "Adding swap space..."
sudo fallocate -l $SWAP_SIZE /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Install Docker and Docker Compose
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt update
sudo apt install docker-ce -y

sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo systemctl enable docker
sudo systemctl start docker
# Clone the Git repository
if [ -d "$APP_DIR" ]; then
  echo "Directory $APP_DIR already exists. Pulling latest changes..."
  cd $APP_DIR && git pull
else
  echo "Cloning repository from $REPO_URL..."
  git clone $REPO_URL $APP_DIR
  cd $APP_DIR
fi


# Set up next environment variables
cat > "$APP_DIR/./frontend/.env" << EOL
API_URL=very_secret_value
EOL

# Set up laravel environment variables
cat > "$APP_DIR/./backend/.env" << EOL
DB_CONNECTION=very_secret_value
DB_HOST=very_secret_value
DB_PORT=very_secret_value
DB_DATABASE=very_secret_value
DB_USERNAME=very_secret_value
DB_PASSWORD=very_secret_value
EOL


# Install and configure Nginx
sudo apt install nginx -y

sudo rm -f /etc/nginx/sites-available/$NGINX_CONFIG_NAME
sudo rm -f /etc/nginx/sites-enabled/$NGINX_CONFIG_NAME

sudo systemctl stop nginx

sudo apt install certbot -y
sudo certbot certonly --standalone -d $DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL

sudo wget -q https://raw.githubusercontent.com/certbot/certbot/main/certbot_nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -P /etc/letsencrypt/
sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048

cat > /etc/nginx/sites-available/$NGINX_CONFIG_NAME << EOL
server {
    listen 80;
    server_name ${DOMAIN_NAME};
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;


    location / {
        proxy_pass http://localhost:3004;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        
        proxy_buffering off;
        proxy_set_header X-Accel-Buffering no;
    }

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/$NGINX_CONFIG_NAME /etc/nginx/sites-enabled/$NGINX_CONFIG_NAME
sudo systemctl restart nginx

# Build and run Docker Compose services
cd $APP_DIR
sudo docker-compose up --build -d

echo "Deployment complete. Your application is available at https://$DOMAIN_NAME"

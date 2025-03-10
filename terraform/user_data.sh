#!/bin/bash

# Update and install packages
sudo dnf update -y && sudo dnf install -y --allowerasing curl git gcc-c++ make nginx certbot python3-certbot-nginx

# Set up environment
HOME="/home/ec2-user"
USER="ec2-user"

# Create directories and set permissions
sudo mkdir -p $HOME /etc/nginx/conf.d /var/log/nginx /var/cache/nginx
sudo chown $USER:$USER $HOME
sudo chmod 755 $HOME

# Set up NVM and Node.js
sudo -iu $USER bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
echo 'export NVM_DIR="$HOME/.nvm"' | sudo tee -a $HOME/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' | sudo tee -a $HOME/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' | sudo tee -a $HOME/.bashrc
echo 'export PATH=/usr/bin:$PATH' | sudo tee -a $HOME/.bashrc

# Install Node.js and PM2
sudo -iu $USER bash -c 'source $HOME/.bashrc && nvm install 22 && nvm use 22 && npm install -g pm2'
sudo ln -sf $HOME/.nvm/versions/node/v22/bin/pm2 /usr/local/bin/pm2

# Set up app directories and PM2
sudo -iu $USER bash -c 'mkdir -p $HOME/app/source $HOME/app/current $HOME/.pm2 $HOME/.n8n'
sudo -iu $USER bash -c 'source $HOME/.bashrc && pm2 setup'

# Set up SSH for GitHub
sudo -iu $USER bash -c 'mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh'
sudo -iu $USER bash -c 'aws ssm get-parameter --name "/n8n/slos/github-deploy-key" --with-decryption --query "Parameter.Value" --output text > $HOME/.ssh/github_deploy_key'
sudo -iu $USER bash -c 'chmod 600 $HOME/.ssh/github_deploy_key && chown $USER:$USER $HOME/.ssh/github_deploy_key'

# Create SSH config
sudo -iu $USER bash -c 'echo "Host github.com" > $HOME/.ssh/config'
sudo -iu $USER bash -c 'echo "    IdentityFile $HOME/.ssh/github_deploy_key" >> $HOME/.ssh/config'
sudo -iu $USER bash -c 'echo "    User git" >> $HOME/.ssh/config'
sudo -iu $USER bash -c 'chmod 600 $HOME/.ssh/config && chown $USER:$USER $HOME/.ssh/config'
sudo -iu $USER bash -c 'ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> $HOME/.ssh/known_hosts'

# Clone repository
sudo -iu $USER bash -c 'cd $HOME/app/source && git clone git@github.com:Slos/slos-n8n.git .'

# Install dependencies
sudo -iu $USER bash -c 'cd $HOME/app/source && npm install'

# Configure Nginx
sudo tee /etc/nginx/nginx.conf << 'NGINX_MAIN'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    log_format main '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    sendfile on; tcp_nopush on; tcp_nodelay on;
    keepalive_timeout 65; types_hash_max_size 4096; types_hash_bucket_size 128;
    include /etc/nginx/conf.d/*.conf;
}
NGINX_MAIN

# Initial HTTP-only configuration
sudo tee /etc/nginx/conf.d/n8n.conf << 'NGINX_HTTP'
server {
    listen 80;
    server_name n8n.slos.io;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
NGINX_HTTP

# Set Nginx permissions and start service
sudo chown -R nginx:nginx /var/log/nginx /var/cache/nginx /etc/nginx
sudo systemctl enable nginx && sudo systemctl start nginx

# Get SSL certificate
sudo certbot --nginx -d n8n.slos.io --non-interactive --agree-tos --email mark@slos.io

# Update configuration with SSL
sudo tee /etc/nginx/conf.d/n8n.conf << 'NGINX_SSL'
server {
    listen 80;
    server_name n8n.slos.io;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name n8n.slos.io;
    ssl_certificate /etc/letsencrypt/live/n8n.slos.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/n8n.slos.io/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
NGINX_SSL

# Restart Nginx to apply SSL configuration
sudo systemctl restart nginx

# Set up automatic certificate renewal
sudo tee /etc/cron.daily/certbot-renew << 'SCRIPT'
#!/bin/bash
/usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx"
SCRIPT

# Set proper permissions and make the script executable
sudo chmod 755 /etc/cron.daily/certbot-renew

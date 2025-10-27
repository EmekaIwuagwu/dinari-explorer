#!/bin/bash
# Setup script for rpc.dinaritiger.xyz reverse proxy
# This script installs nginx, configures SSL, and sets up the reverse proxy

set -e  # Exit on any error

echo "================================================"
echo "RPC Reverse Proxy Setup Script"
echo "Domain: rpc.dinaritiger.xyz"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Step 1: Install nginx
echo "📦 Step 1: Installing nginx..."
apt-get update
apt-get install -y nginx

# Step 2: Install certbot for SSL certificates
echo "🔒 Step 2: Installing certbot (Let's Encrypt)..."
apt-get install -y certbot python3-certbot-nginx

# Step 3: Backup existing nginx config if it exists
if [ -f /etc/nginx/sites-available/rpc.dinaritiger.xyz ]; then
    echo "💾 Backing up existing config..."
    cp /etc/nginx/sites-available/rpc.dinaritiger.xyz /etc/nginx/sites-available/rpc.dinaritiger.xyz.backup.$(date +%s)
fi

# Step 4: Copy nginx configuration
echo "⚙️  Step 3: Configuring nginx..."
cp nginx-rpc-proxy.conf /etc/nginx/sites-available/rpc.dinaritiger.xyz

# Step 5: Enable the site
echo "🔗 Step 4: Enabling site..."
ln -sf /etc/nginx/sites-available/rpc.dinaritiger.xyz /etc/nginx/sites-enabled/

# Step 6: Test nginx configuration
echo "✅ Step 5: Testing nginx configuration..."
nginx -t

# Step 7: Obtain SSL certificate
echo "🔐 Step 6: Obtaining SSL certificate..."
echo ""
echo "IMPORTANT: Make sure:"
echo "  1. DNS A record for rpc.dinaritiger.xyz points to this server's IP"
echo "  2. Port 80 and 443 are open in your firewall"
echo ""
read -p "Press Enter to continue with SSL certificate setup..."

# Stop nginx temporarily for standalone certbot
systemctl stop nginx

# Get SSL certificate
certbot certonly --standalone -d rpc.dinaritiger.xyz --non-interactive --agree-tos --email admin@dinaritiger.xyz || {
    echo "❌ SSL certificate failed. Please check:"
    echo "   - DNS is pointing to this server"
    echo "   - Ports 80/443 are accessible"
    echo "   - Domain is valid"
    systemctl start nginx
    exit 1
}

# Step 8: Start nginx
echo "🚀 Step 7: Starting nginx..."
systemctl start nginx
systemctl enable nginx

# Step 9: Set up auto-renewal
echo "🔄 Step 8: Setting up SSL auto-renewal..."
systemctl enable certbot.timer
systemctl start certbot.timer

echo ""
echo "================================================"
echo "✅ Setup Complete!"
echo "================================================"
echo ""
echo "Your RPC endpoint is now available at:"
echo "  https://rpc.dinaritiger.xyz"
echo ""
echo "Testing the endpoint..."
sleep 2

# Test the endpoint
curl -X POST https://rpc.dinaritiger.xyz \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"chain_getHeight","params":{},"id":1}' \
    && echo "" && echo "✅ RPC endpoint is working!" \
    || echo "" && echo "⚠️  RPC test failed. Check if your blockchain node is running on port 8545"

echo ""
echo "Next steps:"
echo "  1. Verify RPC node is running: netstat -tlnp | grep 8545"
echo "  2. Check nginx logs: tail -f /var/log/nginx/rpc.dinaritiger.xyz.error.log"
echo "  3. Test from your explorer at https://dinariscan.xyz"
echo ""
echo "SSL certificate will auto-renew. To test renewal:"
echo "  certbot renew --dry-run"
echo ""

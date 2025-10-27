# Dinari Explorer Deployment Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     User's Browser                          │
└─────────────────┬───────────────────────┬───────────────────┘
                  │                       │
                  │ HTTPS                 │ HTTPS
                  │                       │
         ┌────────▼────────┐     ┌────────▼──────────┐
         │   Frontend      │     │   RPC Endpoint    │
         │  dinariscan.xyz │     │ rpc.dinaritiger.xyz│
         │   (Vercel)      │     │   (Your Server)   │
         └─────────────────┘     └────────┬──────────┘
                                           │
                                    Nginx Reverse Proxy
                                      (Port 443 → 8545)
                                           │
                                  ┌────────▼──────────┐
                                  │ Blockchain Node   │
                                  │  localhost:8545   │
                                  └───────────────────┘
```

## Deployment Steps

### Part 1: Deploy Frontend to Vercel ✅ (Already Done)

Your frontend at `dinariscan.xyz` is already on Vercel. Great!

### Part 2: Set Up RPC Reverse Proxy (You Need To Do This)

The RPC endpoint setup must be done on **your blockchain server** (IP: `52.241.1.239`).

#### Prerequisites

1. **Server access**: SSH access to the server at `52.241.1.239`
2. **DNS configured**: Point `rpc.dinaritiger.xyz` to `52.241.1.239`
   ```
   A Record: rpc.dinaritiger.xyz → 52.241.1.239
   ```
3. **Blockchain node running**: Your node should be running on `localhost:8545`
4. **Ports open**: Ensure firewall allows ports 80 and 443

#### Installation Steps

1. **SSH into your RPC server:**
   ```bash
   ssh user@52.241.1.239
   ```

2. **Clone this repository on the server:**
   ```bash
   cd /opt
   git clone https://github.com/EmekaIwuagwu/dinari-explorer.git
   cd dinari-explorer
   ```

3. **Run the setup script:**
   ```bash
   sudo bash setup-rpc-proxy.sh
   ```

   This script will:
   - Install nginx
   - Install certbot (Let's Encrypt)
   - Configure the reverse proxy
   - Obtain SSL certificate for `rpc.dinaritiger.xyz`
   - Start nginx
   - Set up automatic SSL renewal

4. **Verify the RPC endpoint is working:**
   ```bash
   curl -X POST https://rpc.dinaritiger.xyz \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"chain_getHeight","params":{},"id":1}'
   ```

   You should see a valid blockchain response (not "Access denied").

### Part 3: Update Vercel Deployment

Make sure Vercel is deploying the latest `index.html` with:
```javascript
const RPC_ENDPOINT = 'https://rpc.dinaritiger.xyz';
```

**If using git integration:**
1. Vercel should auto-deploy when you push to your main branch
2. Merge the changes from `claude/debug-chrome-explorer-011CUXCLmGf1PPw7L3o2g8kL` to main
3. Vercel will automatically redeploy

**If manually deploying:**
1. Upload the latest `index.html` to Vercel
2. Ensure you're using the version without `:8545` in the endpoint

## Vercel Configuration

### Environment Settings

No environment variables needed for this static site.

### Build Settings

- **Framework Preset**: Other
- **Build Command**: (leave empty)
- **Output Directory**: `.` (root directory)
- **Install Command**: (leave empty)

### Domain Setup

Ensure your Vercel project is configured with:
- Primary domain: `dinariscan.xyz`
- Alias: `www.dinariscan.xyz` (optional)

## Testing

### Test Frontend (Vercel)
1. Visit `https://dinariscan.xyz`
2. You should see the blockchain explorer
3. Blocks should load without errors

### Test RPC Endpoint
```bash
# From anywhere
curl -X POST https://rpc.dinaritiger.xyz \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"chain_getHeight","params":{},"id":1}'
```

### Test CORS
```bash
# Test CORS headers
curl -X OPTIONS https://rpc.dinaritiger.xyz \
  -H "Origin: https://dinariscan.xyz" \
  -H "Access-Control-Request-Method: POST" \
  -v
```

Should return CORS headers allowing dinariscan.xyz.

## Troubleshooting

### Frontend shows connection error

**Possible causes:**
1. RPC endpoint not accessible
2. SSL certificate not configured
3. CORS headers not set
4. Blockchain node not running

**Check:**
```bash
# On RPC server
sudo systemctl status nginx
sudo netstat -tlnp | grep 8545  # Check if blockchain node is running
sudo tail -f /var/log/nginx/rpc.dinaritiger.xyz.error.log
```

### "Access denied" error

**Cause:** Nginx is not forwarding to the blockchain node

**Fix:**
```bash
# Check nginx config
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

### SSL certificate failed

**Cause:** DNS not pointing to server or ports closed

**Fix:**
1. Verify DNS: `dig rpc.dinaritiger.xyz` should show `52.241.1.239`
2. Check firewall: `sudo ufw status` (allow ports 80, 443)
3. Try manual certificate: `sudo certbot certonly --standalone -d rpc.dinaritiger.xyz`

### CORS errors in browser console

**Fix:** Update CORS origin in `/etc/nginx/sites-available/rpc.dinaritiger.xyz`:
```nginx
add_header 'Access-Control-Allow-Origin' 'https://dinariscan.xyz' always;
```

Then reload nginx:
```bash
sudo systemctl reload nginx
```

## Maintenance

### SSL Certificate Renewal

Certificates auto-renew via systemd timer. To check:
```bash
sudo systemctl status certbot.timer
sudo certbot renew --dry-run  # Test renewal
```

### Update Frontend

Push changes to your git repository, Vercel will auto-deploy.

### Update Nginx Config

1. Edit: `/etc/nginx/sites-available/rpc.dinaritiger.xyz`
2. Test: `sudo nginx -t`
3. Reload: `sudo systemctl reload nginx`

## Security Notes

- Nginx config includes security headers
- SSL uses TLS 1.2+ only
- CORS restricted to dinariscan.xyz only
- Consider adding rate limiting for production

## Support

- **Frontend issues**: Check Vercel deployment logs
- **RPC issues**: Check nginx error logs at `/var/log/nginx/rpc.dinaritiger.xyz.error.log`
- **Blockchain issues**: Check your blockchain node logs

---

## Quick Reference

| Component | URL | Location |
|-----------|-----|----------|
| Frontend | https://dinariscan.xyz | Vercel |
| RPC API | https://rpc.dinaritiger.xyz | Server: 52.241.1.239 |
| Blockchain Node | http://localhost:8545 | Server: 52.241.1.239 |

| File | Purpose | Location |
|------|---------|----------|
| `index.html` | Frontend code | Deploy to Vercel |
| `nginx-rpc-proxy.conf` | Nginx config | Copy to RPC server |
| `setup-rpc-proxy.sh` | Setup script | Run on RPC server |

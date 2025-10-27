# Dinari Blockchain Explorer

A modern, responsive blockchain explorer for the Dinari blockchain network.

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🌐 Live Demo

- **Explorer**: [https://dinariscan.xyz](https://dinariscan.xyz)
- **RPC Endpoint**: `https://rpc.dinaritiger.xyz`

## ✨ Features

- 📊 Real-time blockchain statistics
- 🔍 Search blocks, transactions, and addresses
- 📱 Responsive design for all devices
- 🔄 Auto-refresh every 10 seconds
- 🌙 Dark theme optimized interface
- ⚡ Fast and lightweight (single HTML file)

## 🚀 Quick Start

### Frontend Deployment (Vercel)

The frontend is a single-file application that can be deployed to Vercel:

1. Fork or clone this repository
2. Connect to Vercel
3. Deploy - no build configuration needed!

### RPC Server Setup

The RPC endpoint needs to be set up on your blockchain server. See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

**Quick setup on your RPC server:**
```bash
cd /opt
git clone https://github.com/EmekaIwuagwu/dinari-explorer.git
cd dinari-explorer
sudo bash setup-rpc-proxy.sh
```

## 📁 Project Structure

```
dinari-explorer/
├── index.html              # Main application (frontend)
├── dinari_logo.svg         # Logo asset
├── nginx-rpc-proxy.conf    # Nginx configuration for RPC server
├── setup-rpc-proxy.sh      # Automated setup script
├── DEPLOYMENT.md           # Detailed deployment guide
└── README.md               # This file
```

## 🔧 Configuration

The RPC endpoint is configured in `index.html`:

```javascript
const RPC_ENDPOINT = 'https://rpc.dinaritiger.xyz';
```

## 🛠️ RPC Methods Used

The explorer uses these JSON-RPC methods:

- `chain_getHeight` - Get current blockchain height
- `chain_getBlock` - Get block details by height
- `tx_get` - Get transaction details
- `wallet_balance` - Get wallet balance (DNT & AFC tokens)
- `tx_listByWallet` - Get transaction history

## 🌐 Browser Support

- ✅ Chrome 60+
- ✅ Firefox 54+
- ✅ Safari 12+
- ✅ Edge 79+

## 📖 Documentation

- [Deployment Guide](DEPLOYMENT.md) - Comprehensive deployment instructions
- [RPC Setup](nginx-rpc-proxy.conf) - Nginx configuration details

## 🔒 Security Features

- HTTPS only
- CORS restricted to dinariscan.xyz
- SSL/TLS 1.2+ required
- Security headers enabled
- Automatic certificate renewal

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 🙋 Support

For issues and questions:
- Check [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section
- Open an issue on GitHub

---

**Built with ❤️ for the Dinari blockchain community**

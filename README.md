# MikroTik Split Tunneling with Auto-Update Iranian IPs

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MikroTik](https://img.shields.io/badge/MikroTik-RouterOS%207.x-blue)](https://mikrotik.com)
[![WireGuard](https://img.shields.io/badge/WireGuard-Supported-green)](https://www.wireguard.com/)

A complete MikroTik RouterOS configuration for intelligent traffic routing that sends Iranian IPs directly through your ISP while routing foreign traffic through WireGuard VPN, with automatic IP list updates from GitHub.

## 🌟 Features

- ✅ **Smart Split Tunneling** - Iranian IPs go direct (fast), foreign IPs through WireGuard (secure)
- ✅ **Auto-Update Script** - Automatically updates Iranian IP list from this GitHub repository
- ✅ **Secure Firewall** - Pre-configured firewall rules that work with WireGuard
- ✅ **Easy Installation** - Step-by-step guide for all skill levels
- ✅ **Scheduler Support** - Daily, weekly, or on-startup automatic updates
- ✅ **Complete Documentation** - Detailed guides and troubleshooting

## 📊 How It Works

```
┌─────────────────┐
│   Your Device   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│   MikroTik Router           │
│   ┌──────────────────────┐  │
│   │  Mangle Rules        │  │
│   │  (Check Destination) │  │
│   └──────────┬───────────┘  │
│              │               │
│      ┌───────┴────────┐     │
│      ▼                ▼     │
│  Iranian IP?    Foreign IP? │
│      │                │     │
└──────┼────────────────┼─────┘
       │                │
       ▼                ▼
┌─────────────┐  ┌─────────────┐
│   Direct    │  │  WireGuard  │
│   to ISP    │  │     VPN     │
└─────────────┘  └─────────────┘
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- ✅ MikroTik router with RouterOS 7.x or higher
- ✅ Working WireGuard VPN configuration
- ✅ At least 10MB free storage space
- ✅ Internet access from the router

### Installation

1. **Download the files from this repository**
2. **Follow the [Installation Guide](docs/installation-guide.md)**
3. **Run the update script to load Iranian IPs**
4. **Set up automatic updates with scheduler**

**Quick command to run the update script:**
```routeros
/system script run update-iranian-ips
```

## 📁 Repository Structure

```
├── README.md                          # This file
├── LICENSE                            # MIT License
├── mikrotik_address_list.rsc         # Iranian IP addresses list
├── scripts/
│   └── update-iranian-ips.rsc        # Auto-update script
└── docs/
    ├── installation-guide.md         # Complete installation guide
    ├── configuration-examples.md     # Configuration examples
    └── troubleshooting.md            # Troubleshooting guide
```

## 📖 Documentation

- **[Installation Guide](docs/installation-guide.md)** - Complete step-by-step setup instructions
- **[Configuration Examples](docs/configuration-examples.md)** - Various configuration scenarios
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common issues and solutions

## 🔧 Quick Configuration

### 1. Upload the Script

```routeros
# Copy the script from scripts/update-iranian-ips.rsc
# Then paste it into your MikroTik terminal
```

### 2. Run the Script

```routeros
/system script run update-iranian-ips
```

### 3. Set Up Daily Updates

```routeros
/system scheduler add name=update-iranian-ips-daily \
    on-event="/system script run update-iranian-ips" \
    start-time=03:00:00 interval=1d
```

## 📊 Statistics

- **Total Iranian IP Ranges:** 5,000+ entries
- **Update Frequency:** Daily (recommended)
- **Last Updated:** Check commit history

## 🤝 Contributing

Contributions are welcome! If you have additional Iranian IP ranges or improvements:

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 IP List Format

The IP list follows MikroTik's standard format:

```routeros
/ip firewall address-list
add address=31.2.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.7.0.0/16 list=Iranian-IPs comment="ITC"
add address=2.144.0.0/13 list=Iranian-IPs comment="Irancell"
```

## ⚠️ Disclaimer

This configuration is provided for educational purposes. Users are responsible for:
- Ensuring compliance with local laws and regulations
- Properly securing their network
- Understanding the implications of traffic routing

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- MikroTik community for RouterOS
- WireGuard team for the amazing VPN protocol
- Contributors who help maintain the Iranian IP list

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/amirsalahshur/update-iranian-ips/issues)
- **Discussions:** [GitHub Discussions](https://github.com/amirsalahshur/update-iranian-ips/discussions)

## 🔗 Useful Links

- [MikroTik Wiki](https://wiki.mikrotik.com)
- [WireGuard Documentation](https://www.wireguard.com/quickstart/)
- [RouterOS Manual](https://help.mikrotik.com/docs/)

---

**Made with ❤️ for the community**

**Star ⭐ this repository if you find it helpful!**

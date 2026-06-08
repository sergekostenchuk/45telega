# 🚀 45telega - Production-Ready Telegram MCP Server

[![Release](https://img.shields.io/github/v/release/sergekostenchuk/45telega?include_prereleases)](https://github.com/sergekostenchuk/45telega/releases)
[![PyPI](https://img.shields.io/pypi/v/45telega)](https://pypi.org/project/45telega/)
[![License](https://img.shields.io/github/license/sergekostenchuk/45telega)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.9%2B-blue)](setup.py)

A powerful Model Context Protocol (MCP) server for Telegram with 45+ methods, production-ready deployment, and enterprise features.

## ✨ Features

- **45+ Telegram Methods**: Complete API coverage for messages, chats, users, media
- **Production Ready**: Docker support, health checks, monitoring, logging
- **Secure**: Non-root container, environment-based config, session encryption
- **Scalable**: Async architecture, Redis caching, connection pooling
- **Easy Install**: One-line installation, auto-updates, multiple deployment options

## 🚀 Quick Start

### Platform-Specific Setup

#### 🪟 Windows + WSL + Kiro IDE
**[📖 Complete Windows Setup Guide →](WINDOWS_WSL_SETUP.md)**

Comprehensive step-by-step guide for Windows users with WSL and Kiro IDE integration.

#### 🐧 Linux/macOS

### One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/sergekostenchuk/45telega/main/install.sh | bash
```

### PyPI Install

```bash
pip install 45telega
```

### Docker Install

```bash
docker run -d \
  --name 45telega \
  -p 8765:8765 \
  -e TELEGRAM_API_ID=your_api_id \
  -e TELEGRAM_API_HASH=your_api_hash \
  -v $(pwd)/data:/data \
  ghcr.io/sergekostenchuk/45telega:latest
```

## 📋 Prerequisites

- Python 3.9+ or Docker
- Telegram API credentials from [my.telegram.org](https://my.telegram.org/apps)
- 512MB RAM minimum
- Linux/macOS/Windows (with WSL)

## 🔧 Configuration

### 1. Get Telegram API Credentials

1. Go to [my.telegram.org](https://my.telegram.org/apps)
2. Login with your phone number
3. Create new application
4. Copy `api_id` and `api_hash`

### 2. Configure Environment

Copy `.env.example` to `.env`:

```bash
cp ~/.config/45telega/.env.example ~/.config/45telega/.env
```

Edit with your credentials:

```env
TELEGRAM_API_ID=your_api_id_here
TELEGRAM_API_HASH=your_api_hash_here
TELEGRAM_PHONE=+1234567890  # Optional
```

### 3. First Authentication

```bash
45telega sign-in --phone +1234567890
```

Enter the code you receive on Telegram.

## 🎯 Usage

### Start MCP Server

```bash
# Native
45telega run

# Docker
docker-compose up -d

# With custom port
45telega run --port 9000
```

### Add to Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "45telega": {
      "type": "stdio",
      "command": "/Users/you/.local/bin/45telega",
      "args": ["run"],
      "env": {
        "TELEGRAM_API_ID": "your_api_id",
        "TELEGRAM_API_HASH": "your_api_hash"
      }
    }
  }
}
```

### Add to Kiro IDE (Windows + WSL)

See the [Windows Setup Guide](WINDOWS_WSL_SETUP.md) for detailed Kiro IDE integration instructions.

## 📚 Available Methods

### Messages
- `SendMessage` - Send text messages
- `EditMessage` - Edit existing messages
- `DeleteMessage` - Delete messages
- `ForwardMessage` - Forward messages
- `ReplyToMessage` - Reply to specific messages
- `SendFile` - Send files/media

### Chats
- `GetChats` - List all chats
- `GetChatInfo` - Get chat details
- `GetChatMembers` - List chat members
- `CreateGroup` - Create new group
- `CreateChannel` - Create new channel
- `JoinChatByInvite` - Join via invite link

### Users
- `GetMe` - Get current user info
- `GetUserInfo` - Get user details
- `GetContacts` - List contacts
- `AddContact` - Add new contact
- `BlockUser` - Block user
- `UnblockUser` - Unblock user

[Full API Documentation →](https://github.com/sergekostenchuk/45telega/wiki/API)

## 🐳 Docker Deployment

### docker-compose.yml

```yaml
version: '3.8'
services:
  45telega:
    image: ghcr.io/sergekostenchuk/45telega:latest
    restart: unless-stopped
    ports:
      - "8765:8765"
    volumes:
      - ./data:/data
      - ./logs:/logs
    env_file:
      - .env
```

### Run with Docker Compose

```bash
docker-compose up -d
docker-compose logs -f  # View logs
docker-compose down     # Stop
```

## 🔒 Security

- **Non-root container**: Runs as unprivileged user
- **Environment variables**: No hardcoded credentials
- **Session encryption**: Secure session storage
- **Rate limiting**: Built-in protection
- **Health checks**: Automatic recovery

## 📊 Monitoring

### Health Check

```bash
curl http://localhost:8765/health
```

### Prometheus Metrics

Enable in `.env`:

```env
PROMETHEUS_ENABLED=true
PROMETHEUS_PORT=9090
```

### Logging

Logs are stored in `./logs/` with rotation:

```bash
tail -f logs/45telega.log
```

## 🔄 Updates

### Auto-update

```bash
45telega update
```

### Manual Update

```bash
cd ~/.local/share/45telega
git pull
pip install -e . --upgrade
```

## 🧪 Development

### Setup Development Environment

```bash
git clone https://github.com/sergekostenchuk/45telega
cd 45telega
pip install -e .[dev]
```

### Run Tests

```bash
pytest tests/
pytest --cov=telega45  # With coverage
```

### Code Quality

```bash
black .          # Format code
ruff check .     # Lint
mypy telega45    # Type check
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📝 License

MIT License - see [LICENSE](LICENSE) file.

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/sergekostenchuk/45telega/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sergekostenchuk/45telega/discussions)

## 🙏 Acknowledgments

- [Telethon](https://github.com/LonamiWebs/Telethon) - Telegram client library
- [MCP](https://modelcontextprotocol.io/) - Model Context Protocol
- [Claude](https://claude.ai) - AI assistant platform

---

Made with ❤️ by Sergey Kostenchuk

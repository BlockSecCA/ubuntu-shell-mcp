# Ubuntu Shell MCP Extension

## Directory Structure

Create this structure in a new folder (e.g., `C:\Users\YourName\OneDrive - YourCompany\code\ubuntu-shell-mcp`):

```
ubuntu-shell-mcp/
├── manifest.json
├── package.json
├── server/
│   └── index.js
└── node_modules/  (will be created by npm install)
```

## Files

### 1. manifest.json

```json
{
  "manifest_version": "0.2",
  "name": "ubuntu-shell-mcp",
  "version": "1.0.0",
  "description": "Execute bash commands on a remote Ubuntu server via SSH",
  "author": {
    "name": "YourName"
  },
  "server": {
    "type": "node",
    "entry_point": "server/index.js",
    "mcp_config": {
      "command": "node",
      "args": [
        "${__dirname}/server/index.js",
        "--host",
        "${user_config.ssh_host}",
        "--user",
        "${user_config.ssh_user}"
      ]
    }
  },
  "user_config": {
    "ssh_host": {
      "title": "SSH Host",
      "description": "Hostname or IP address of the Ubuntu server (e.g., 'ubuntupc' or '192.168.1.XXX')",
      "type": "string",
      "required": true
    },
    "ssh_user": {
      "title": "SSH Username",
      "description": "Username for SSH connection (e.g., 'your-username')",
      "type": "string",
      "required": true
    }
  },
  "tools": [
    {
      "name": "bash",
      "description": "Execute a bash command on the Ubuntu server"
    }
  ],
  "license": "MIT"
}
```

### 2. package.json

```json
{
  "name": "ubuntu-shell-mcp",
  "version": "1.0.0",
  "description": "MCP server to execute bash commands on Ubuntu via SSH",
  "type": "module",
  "main": "server/index.js",
  "scripts": {
    "pack": "npx @anthropic-ai/mcpb pack"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": [
    "mcp",
    "ubuntu",
    "ssh",
    "bash",
    "shell",
    "claude",
    "desktop-extension"
  ],
  "author": "YourName",
  "license": "MIT"
}
```

### 3. server/index.js

See the code artifact I'll create next.

## Setup Steps

1. **Create the directory structure**:
   ```cmd
   cd "C:\Users\YourName\OneDrive - YourCompany\code"
   mkdir ubuntu-shell-mcp
   cd ubuntu-shell-mcp
   mkdir server
   ```

2. **Create the files** with content from this artifact

3. **Install dependencies**:
   ```cmd
   npm install
   ```

4. **Package the extension**:
   ```cmd
   npm run pack
   ```

5. **Install in Claude Desktop**:
   - Double-click the generated `ubuntu-shell-mcp.mcpb` file
   - Claude Desktop will prompt for SSH configuration
   - Enter: `ubuntupc` for host, `your-username` for user

## How It Works

- Runs locally on Windows using Claude Desktop's built-in Node.js
- Uses Windows' native SSH client to connect to Ubuntu
- Executes commands remotely and returns output
- SSH authentication uses your existing SSH keys/config

## Requirements

- SSH must be available in Windows PATH
- SSH key-based authentication configured for passwordless access

#!/usr/bin/env node

/**
 * Ubuntu Shell MCP Server
 * 
 * Executes bash commands on a remote Ubuntu server via SSH.
 * Runs locally on Windows, connects to Ubuntu via SSH.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { spawn } from "child_process";

console.error("[STARTUP] Ubuntu Shell MCP Server starting...");

// SSH connection details from command line arguments
let sshHost = null;
let sshUser = null;

// Parse command line arguments
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--host' && i + 1 < args.length) {
    sshHost = args[i + 1];
  } else if (args[i] === '--user' && i + 1 < args.length) {
    sshUser = args[i + 1];
  }
}

if (!sshHost || !sshUser) {
  console.error("[FATAL] Missing SSH configuration. --host and --user are required.");
  process.exit(1);
}

console.error(`[STARTUP] SSH Target: ${sshUser}@${sshHost}`);

/**
 * Execute a command on the remote Ubuntu server via SSH
 * @param {string} command - The bash command to execute
 * @returns {Promise<{stdout: string, stderr: string, exitCode: number}>}
 */
async function executeRemoteCommand(command) {
  return new Promise((resolve, reject) => {
    console.error(`[EXEC] Running command: ${command}`);
    
    // Use SSH to execute the command remotely
    // -o BatchMode=yes ensures no password prompts (uses keys only)
    // -o StrictHostKeyChecking=no auto-accepts new host keys (consider security implications)
    const sshProcess = spawn('ssh', [
      '-o', 'BatchMode=yes',
      '-o', 'ConnectTimeout=10',
      `${sshUser}@${sshHost}`,
      command
    ]);

    let stdout = '';
    let stderr = '';

    sshProcess.stdout.on('data', (data) => {
      const output = data.toString();
      stdout += output;
      console.error(`[STDOUT] ${output.trim()}`);
    });

    sshProcess.stderr.on('data', (data) => {
      const output = data.toString();
      stderr += output;
      console.error(`[STDERR] ${output.trim()}`);
    });

    sshProcess.on('close', (code) => {
      console.error(`[EXEC] Command completed with exit code: ${code}`);
      resolve({
        stdout: stdout,
        stderr: stderr,
        exitCode: code || 0
      });
    });

    sshProcess.on('error', (error) => {
      console.error(`[ERROR] SSH execution failed: ${error.message}`);
      reject(new Error(`SSH connection failed: ${error.message}. Ensure SSH is in PATH and key authentication is configured.`));
    });
  });
}

// Create server instance
console.error("[STARTUP] Creating MCP Server instance...");
const server = new Server(
  {
    name: "ubuntu-shell",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);
console.error("[STARTUP] Server instance created successfully");

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  console.error("[HANDLER] ListTools called");
  
  return {
    tools: [
      {
        name: "bash",
        description: `Execute a bash command on the Ubuntu server (${sshUser}@${sshHost}).

Commands are executed via SSH and run with the privileges of the SSH user.

Examples:
- "ls -la /home/user"
- "df -h"
- "cat /etc/os-release"
- "docker ps"

Note: Commands run in a non-interactive shell. Interactive commands or those requiring input will fail.`,
        inputSchema: {
          type: "object",
          properties: {
            command: {
              type: "string",
              description: "The bash command to execute on the Ubuntu server",
            },
          },
          required: ["command"],
        },
      },
    ],
  };
});
console.error("[STARTUP] ListTools handler registered");

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  console.error(`[HANDLER] CallTool called with tool: ${name}`);
  
  try {
    if (name === "bash") {
      const command = args?.command;
      
      if (!command || typeof command !== 'string') {
        throw new Error("command parameter is required and must be a string");
      }
      
      if (command.trim().length === 0) {
        throw new Error("command cannot be empty");
      }
      
      // Execute the command remotely
      const result = await executeRemoteCommand(command);
      
      // Build response text
      let output = '';
      if (result.stdout) {
        output += result.stdout;
      }
      if (result.stderr) {
        if (output) output += '\n';
        output += `STDERR:\n${result.stderr}`;
      }
      if (!result.stdout && !result.stderr) {
        output = '(no output)';
      }
      output += `\n(exit code: ${result.exitCode})`;
      
      return {
        content: [
          {
            type: "text",
            text: output
          }
        ]
      };
    }
    
    throw new Error(`Unknown tool: ${name}`);
    
  } catch (error) {
    console.error(`[ERROR] Tool execution failed: ${error.message}`);
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }],
      isError: true,
    };
  }
});
console.error("[STARTUP] CallTool handler registered");

// Start the server
async function main() {
  try {
    console.error("[STARTUP] Creating transport...");
    const transport = new StdioServerTransport();
    
    console.error("[STARTUP] Connecting server to transport...");
    await server.connect(transport);
    
    console.error("[STARTUP] ✓ Server connected and ready");
    console.error(`[STARTUP] ✓ Connected to: ${sshUser}@${sshHost}`);
    console.error("[STARTUP] ✓ Waiting for client requests...");
  } catch (error) {
    console.error("[FATAL] Server initialization failed:", error.message);
    console.error("[FATAL] Stack:", error.stack);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error("[FATAL] Uncaught error:", error.message);
  console.error("[FATAL] Stack:", error.stack);
  process.exit(1);
});

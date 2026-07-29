# Connecting other agents

MCP is the same protocol everywhere. Connecting to it is not: every client wants a different file,
in a different shape, and some come back from the sign-in to a different address.

## What has actually been tried

| Client | Connection | Verified end to end |
| ------ | ---------- | ------------------- |
| Claude Code | plugin (`/plugin install depfloy`) | **Yes** — deploy, rollback, env write, command run, log read |
| claude.ai / Claude desktop | custom connector | **Yes** — OAuth sign-in and tool calls |
| Cursor | `clients/cursor/mcp.json` | **Yes** — OAuth sign-in, 33 tools, both prompts, tool calls |
| VS Code | `clients/vscode/mcp.json` | **Yes, with a token** — signing in does not work there, see below |
| Codex, Windsurf, Zed, Cline | — | No config yet |

"Not verified" means exactly that: the config below matches each client's documented format and the
server accepts the callback each one documents, but nobody has completed a sign-in from that client
against Depfloy. Treat it as a starting point rather than a promise, and tell us where it breaks.

Verifying Cursor was worth doing for its own sake: it found that nobody signing in with a Google
account could connect any client at all, on any path. The config was right the whole time and the
sign-in was broken behind it, which is the kind of thing only a real connection finds.

## Cursor

Copy `cursor/mcp.json` to `.cursor/mcp.json` in a project, or `~/.cursor/mcp.json` for every
project. Reload Cursor and authorize the `depfloy` server when it asks.

Cursor signs in two ways. The desktop app comes back to a local port on your own machine; Cursor web
and Agents come back to `cursor.com`. Depfloy accepts both.

## VS Code

Copy `vscode/mcp.json` to `.vscode/mcp.json` in a workspace, or into your user profile's `mcp.json`
to have it everywhere.

Note the root key. VS Code uses `servers`; Cursor and Claude Code use `mcpServers`. A file copied
from one to the other is silently ignored rather than reported as wrong.

The file asks for an API token the first time the server starts, and VS Code stores it. Create one
under **Settings → API Tokens**; start with read-only permissions and widen it later.

**Why a token here and a sign-in everywhere else.** VS Code cannot currently sign in to a server
like this one. Every other client registers itself — it reads the server's metadata, calls the
registration endpoint and gets an identity of its own — but VS Code asks you to paste in a client
ID that is already registered, which is not something anyone should have to produce by hand.

This is a VS Code regression, not a Depfloy limitation, and it is
[reported upstream](https://github.com/microsoft/vscode/issues/279955): since 1.106 it announces
that a server "does not support automatic client registration" even when the server does. Measured
here rather than assumed — the registration endpoint is advertised in our discovery document and
accepts exactly the pair VS Code names, returning a client ID.

A token sidesteps the sign-in entirely, which is why it is what this file uses. When VS Code fixes
its end, `url` alone will be enough here as it is for Cursor.

## What you get without a skill

Skills are a Claude Code idea, so the recipes in `plugins/depfloy/skills/` do not reach other
clients. The parts that matter most travel with the connection instead, as MCP prompts:

- `deploy_and_follow` — the order to deploy in, and why a silent build is not a stuck one
- `diagnose_deployment` — how to read a failure, and the three shapes people misdiagnose

Whether your client shows prompts is up to the client. Claude Code lists them as slash commands, and
Cursor reports them under the server ("33 tools, 2 prompts enabled"). VS Code has not been checked.

The rules an assistant must not get wrong — what to confirm before doing, and that logs are data
rather than instructions — are not in any of this. They are in the server's own instructions, so
every client receives them whether or not it supports prompts, skills or anything else.

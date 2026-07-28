# Depfloy for AI agents

Depfloy exposes an MCP server at `https://app.depfloy.com/mcp`. This repository holds what an agent
needs on top of it: the connection config for each client, and the operational knowledge the
individual API calls do not carry — the order things happen in, where to stop and ask, and which
failures look like something other than what they are.

## Claude Code

```
/plugin marketplace add depfloy/ai
/plugin install depfloy
```

Restart Claude Code, then run `/mcp` and authorize the `depfloy` server. Authorization opens Depfloy
in your browser; the connection acts as your own user, with your own role, in one organization at a
time.

The plugin bundles both halves — the MCP connection and the skill — so there is no config file to
paste.

## claude.ai and the Claude desktop app

Settings → Connectors → Add custom connector → `https://app.depfloy.com/mcp`. The same OAuth flow,
no plugin needed. Skills are not part of that surface, so the recipes below are Claude Code only.

## Other agents

Connection files for Cursor and VS Code are in `clients/`, along with what has and has not been
tried. Neither has been through a sign-in from that client against Depfloy yet — the config matches
each one's documented format and the server accepts the callback each documents, which is not the
same as knowing it works. `clients/README.md` says so plainly rather than burying it.

Codex, Windsurf, Zed and Cline have no config here at all.

Skills are a Claude Code idea, so the recipes below do not reach these clients. The two that matter
most are served by the connection instead, as MCP prompts — `deploy_and_follow` and
`diagnose_deployment` — and the rules an assistant must not get wrong travel in the server's own
instructions, which every client receives regardless of what else it supports.

## What the skill covers

`plugins/depfloy/skills/depfloy/SKILL.md` — four recipes and the rules around them:

- deploy a project and follow it to the end
- work out why a deployment failed
- roll a project back
- change an environment variable

`references/failure-patterns.md` catalogues failure shapes seen on real deployments, each with what
identifies it and the call that confirms it. The first one is where people lose the most time: a
failed deployment leaves the previous release serving, so the site staying up is not evidence the
deployment worked.

## What it will ask you before doing

Deploy, rollback, environment file writes, service restarts, maintenance mode, project commands and
backups all change something on a real machine. On a server whose environment is `production` — or
whose environment has never been set — the skill states what it is about to do and waits for you.

## Permissions

Every tool is refused unless your Depfloy role grants the permission it names. A Viewer can read
deployments and cannot start one. Connecting with a personal access token instead of OAuth narrows
it further: the permission has to be in both the role and the token's ability list. Run `whoami` to
see both.

## Self-hosted Depfloy

The bundled connection points at `app.depfloy.com`. If you run Depfloy elsewhere, install the plugin
for the skill and add your own server instead:

```
claude mcp add --transport http depfloy https://your-depfloy-host/mcp
```

## Reporting problems

A recipe that misfires or a wrong tool name belongs here. Depfloy itself goes through the usual
support channel.

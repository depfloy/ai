# Depfloy for Claude Code

Connects Claude Code to your Depfloy account and gives it the operational knowledge the individual
API calls do not carry: the order things happen in, where to stop and ask, and which failures look
like something other than what they are.

## Install

```
/plugin marketplace add depfloy/claude-plugin
/plugin install depfloy
```

Restart Claude Code, then run `/mcp` and authorize the `depfloy` server. Authorization opens
Depfloy in your browser; the connection acts as your own user, with your own role, in one
organization at a time.

## What it adds

**The connection.** A `depfloy` MCP server pointed at `https://app.depfloy.com/mcp`, so no manual
config file is needed. 32 tools covering servers, projects, deployments, environment files,
application and deploy logs, scheduled and background jobs, backups, certificates and domains.

**The skill.** `skills/depfloy/SKILL.md` — four recipes and the rules that surround them:

- deploy a project and follow it to the end
- work out why a deployment failed
- roll a project back
- change an environment variable

`skills/depfloy/references/failure-patterns.md` catalogues failure shapes seen on real deployments,
each with what identifies it and the call that confirms it. The first one is the one people lose the
most time to: a failed deployment leaves the previous release serving, so the site staying up is not
evidence the deployment worked.

## What it will ask you before doing

Deploy, rollback, environment file writes, service restarts, maintenance mode, project commands and
backups all change something on a real machine. On a server whose environment is `production` — or
whose environment has never been set — the skill states what it is about to do and waits for you.

## Permissions

Every tool is refused unless your Depfloy role grants the permission it names. A Viewer can read
deployments and cannot start one. If you connect with a personal access token instead of OAuth, the
token's own ability list narrows it further: the permission has to be in both. Run `whoami` to see
both lists.

## Self-hosted Depfloy

The bundled MCP server points at `app.depfloy.com`. If you run Depfloy somewhere else, install the
plugin for the skill and add your own server instead:

```
claude mcp add --transport http depfloy https://your-depfloy-host/mcp
```

## Reporting problems

Issues that belong to the plugin — a recipe that misfires, a wrong tool name — go here. Issues with
Depfloy itself go through the usual support channel.

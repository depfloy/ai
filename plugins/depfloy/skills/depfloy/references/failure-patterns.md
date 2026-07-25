# Failure patterns

Shapes that have come up on real Depfloy deployments. Each one is written as: what the user reports,
what actually identifies it, and the call that confirms it. They matter because most of them look
like a different problem than they are, and the obvious first guess sends the investigation the wrong
way.

## "I deployed but my changes aren't live"

**Usually:** the deployment failed, and the previous release is still serving.

Depfloy builds a new release beside the running one and only switches once the build succeeds. A
failed deployment therefore changes nothing — the site keeps working, on the old code. Users read
that as a caching problem or as the wrong branch having been deployed.

**Confirm:** `list_deployments(project_id)` — read `succeeded` on the newest entry. The commit
actually serving is the `commit` of the most recent deployment with `succeeded: true`, which is not
the top of the list when the newest one failed.

**Do not** clear caches, redeploy, or change the branch before reading the deploy log. Redeploying an
unfixed failure just fails again.

## "The deploy says it completed but the site returns 502"

**Usually:** the application process is not running, so nothing after the build is the problem.

The most common cause on servers running several Node applications with little RAM: a blue/green
redeploy briefly runs two copies of the application, memory runs out, and the process is killed after
the deployment has already been recorded as finished.

**Confirm:** `get_deployment` shows `succeeded: true`. `read_project_logs(project_id)` shows the
application either silent or exiting at start-up. `get_monitoring(server_id)` shows whether a memory
alert exists and whether `trigger_count` moved recently — that is the closest signal the MCP surface
offers, as there is no live-metrics tool.

**What helps:** deploying the project again on its own, with no other deployment running at the same
time. Deploying several projects on one small server concurrently is what produces the memory spike.

## "The page loads but every stylesheet and script 404s"

**Usually:** the release the site is serving was removed from disk.

The application still answers from a deleted working directory, so HTML renders, but the hashed asset
files are gone.

**Confirm:** `get_deployment` on the last successful deployment, then `read_project_logs` — asset
requests appear as 404s while page requests succeed.

**What helps:** deploying again puts a complete release back on disk. This is not a rollback case —
rollback targets an earlier release that may also have been pruned.

## "I changed an environment variable and nothing happened"

**Always:** the change is on the server but the running application has not been restarted with it.

`update_env` writes the file. The application picks it up on the next deployment, not before.

**Confirm:** `get_env(project_id)` shows the new value. `list_deployments(project_id)` shows no
deployment since the change.

**What helps:** deploy. Say this before the user starts debugging the application.

## "The deploy has been running for fifteen minutes"

**Check first:** whether the project has a custom deploy script that restarts a service Depfloy
already restarts as part of the deployment. Restarting the same service from inside the script while
Depfloy is holding the SSH session produces a connection that never returns, and the deployment sits
until it times out.

**Confirm:** `get_deployment(deployment_id)` — `recent_output` stops at the same line and does not
advance between polls. Compare with `duration_seconds` on earlier deployments of the same project.

**What helps:** removing the service restart from the custom script. Depfloy restarts the
application's own processes after a successful deployment; a script that also does it is competing
with the deployment that is running it.

## "A background job or scheduled task stopped running"

**Confirm before assuming the code is at fault:** `list_background_jobs(server_id)` shows whether the
process is running at all, and `get_background_job_logs(server_id, job_id)` shows why it exited.
`restart_background_job(server_id, job_id)` queues a restart and returns immediately — it reports
`queued`, not a running process, so check the job again rather than assuming it settled.

Both job tools take the server id as well as the job id; the job id alone is not enough.

A queue worker that exits repeatedly usually fails on the first job it picks up, so the last lines
before each exit are the same. Read several exits, not just the newest.

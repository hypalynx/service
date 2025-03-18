# Service

A repository used to configure VPSs, with the aim of setting them up to run services that we create
that are:

- Updated when main branch is updated (via github actions => VPS with blue/green deploy script for
  docker compose setup)

## TODO

1. Update format from OG project
2. Include alert manager (and a way to either send email/slack messages/sms)
3. loki should use s3 as a chunk store (default is filesystem and that will fill up quick)
4. open telemetry (a.k.a OTEL) with pg_trace, basically propagating headers down

## Application Layer

- Use react (with vite, which proxies the backend API on /api)
- Use air with golang

## Setup

- Locally, keep the deploy files in your app repo under ./deploy, with the exception of
  compose.yaml which sits at the root. You can run a copy of the apps locally with `docker compose
  up` and also run your application outside of docker.
  - So long as you are writing to `/tmp/services-logs` for the application outside docker, all logs
    should be displayed in loki.

- In Production (though not finalized) the idea is that you can copy up the compose and deploy
  folders to a VPS and just do the same except with the prod flag e.g: `docker compose --profile
  "prod" up`

## Manual Deploy Notes

_These are a series of steps I had to perform to set up deployment manually so we can create a
script from them._

1. Create Debian 12 VPS (make sure ssh key is assigned)
2. SSH in as root
3. `apt update && apt upgrade` (keep the local sshd_config installed when asked)
4. Install docker, docker-compose & ufw (legacy/python) `apt install docker docker-compose ufw`
5. Then for UFW:
```bash
ufw allow 22/tcp
ufw enable
ufw status # just to verify what we've done
```
6. Create `app` user
```bash
useradd -m -d /home/app -s /bin/bash -G docker app
mkdir -p /home/app/.ssh
cp /root/.ssh/authorized_keys /home/app/.ssh/authorized_keys
chown -R app:app /home/app
```
7. Pull over config files:
    - ~/.docker/config.json (so we can authorize and pull down our docker images)
    - ./deploy

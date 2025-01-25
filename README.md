# Service

A repository used to configure VPSs, with the aim of setting them up to run services that we create
that are:

- Updated when main branch is updated (via github actions => VPS with blue/green deploy script for
  docker compose setup)

## Setup

- Locally, keep the deploy files in your app repo under ./deploy, with the exception of
  compose.yaml which sits at the root. You can run a copy of the apps locally with `docker compose
  up` and also run your application outside of docker.
  - So long as you are writing to `/tmp/services-logs` for the application outside docker, all logs
    should be displayed in loki.

- In Production (though not finalized) the idea is that you can copy up the compose and deploy
  folders to a VPS and just do the same except with the prod flag e.g: `docker compose --profile
  "prod" up`

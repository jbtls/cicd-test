# Simple Ubuntu LTS-based Webserver

This repository contains a minimal Dockerized webserver based on Ubuntu 22.04 and lighttpd, built to demonstrate a simple GitHub Actions CI/CD pipeline that builds, tests, and (for tagged main releases) publishes container images to GitHub Container Registry (GHCR).

**Primary goals:**
- Build a reproducible Docker image based on Ubuntu LTS running `lighttpd`.
- Provide `main` and `dev` branches with different CI behavior.
- Run builds and tests on GitHub Actions (GitHub-hosted runners). Optionally publish images to `ghcr.io` for tagged main releases.

## Repository layout
- `Dockerfile` — builds the Ubuntu + lighttpd image.
- `lighttpd.conf` — lighttpd configuration used inside the image.
- `index.html` — simple site content (prevents 403 Forbidden).
- `.github/workflows/docker-dev.yml` — CI for `dev` branch (build, test, push `:dev`).
- `.github/workflows/docker-main.yml` — CI for `main` branch (detects tag builds, tests, and pushes tagged images to GHCR).

## Branches & CI behavior
- `dev` branch:
  - On every push, Actions will build the image, push `ghcr.io/<owner>/lighttpd-webserver:dev`, run the container on the runner and perform a health check.
- `main` branch:
  - Use tags to publish versioned images. Tag format: `vMAJOR.MINOR.PATCH` (example: `v1.2.0`).
  - The workflow builds and tests on every run; it will only push to GHCR when the run is triggered by a tag push (i.e., `refs/tags/*`). When pushing a tag, the image is published as `ghcr.io/<owner>/lighttpd-webserver:<tag>` (e.g., `v1.2.0`).

Notes: Pull requests to `main` will build and test but will not publish images unless a tag is also present.

## How CI builds & pushes work (summary)
- Both workflows use `docker/build-push-action` to build images on GitHub-hosted runners.
- `dev` workflow: logs into `ghcr.io` with the repository `GITHUB_TOKEN`, pushes `:dev`, then runs the container locally on the runner for a health check.
- `main` workflow: always builds a local image for testing; if the run is for a tag, it also pushes the image to `ghcr.io/<owner>/lighttpd-webserver:<tag>` and runs the same health check.

## Local development and testing
Build and run locally using Docker:
```bash
# build
docker build -t local/lighttpd:dev .

# run (forward port 8080)
docker run -d --name local-lighttpd -p 8080:8080 local/lighttpd:dev

# check
curl http://127.0.0.1:8080

# cleanup
docker stop local-lighttpd && docker rm local-lighttpd
```

## Self testing

### Pushing to GitHub (create private repo and push)
Option A — using `gh` (recommended):
```bash
gh repo create YOUR_USER/YOUR_REPO --private --source=. --remote=origin --push
git push -u origin dev
git push -u origin main
```

Option B — manual (create repo on GitHub web):
```bash
git remote add origin git@github.com:YOUR_USER/YOUR_REPO.git
git push -u origin main
git push -u origin dev
```

### Triggering a release on `main` (publish tagged image)
```bash
git checkout main
git tag v0.1.0
git push origin v0.1.0
```

After pushing the tag, GitHub Actions will run the `docker-main.yml` workflow and (if successful) publish `ghcr.io/<owner>/lighttpd-webserver:v0.1.0`.

### GitHub Container Registry (GHCR) notes
- Images pushed to `ghcr.io` default to private visibility. CI runs in this repository can push/pull using the built-in `GITHUB_TOKEN` (no extra secret required).
- To allow other repositories or external systems to pull the images, change the package visibility in the GitHub Packages settings or create a PAT with appropriate scopes.

### Files to review
- See `.github/workflows/docker-dev.yml` and `.github/workflows/docker-main.yml` for exact CI steps.

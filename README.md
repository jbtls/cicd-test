# Simple Ubuntu LTS-based Webserver

This is a minimal webserver project for testing CI/CD pipelines with Docker and GitHub Actions. All builds and tests run on GitHub's own infrastructure (GitHub Actions Runners). No external DockerHub build is required.

## Features
- Dockerfile based on Ubuntu LTS
- Main and dev branches
- GitHub Actions workflows:
  - On main: Build Docker image on tag push/PR, use tag as version (runs on GitHub Actions infrastructure)
  - On dev: Build Docker image and run container health tests on every push (runs on GitHub Actions infrastructure)

## Usage
- Clone the repository
- Use the provided Dockerfile to build and run the webserver locally

## CI/CD
- See .github/workflows for workflow details

---

**Replace this README with project-specific details as needed.**

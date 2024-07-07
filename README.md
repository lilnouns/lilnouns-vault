# Foundry and Hardhat Template

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/nekofar/foundry-hardhat-template?include_prereleases)](https://github.com/nekofar/foundry-hardhat-template/releases)
[![GitHub Workflow Status (branch)](https://img.shields.io/github/actions/workflow/status/nekofar/foundry-hardhat-template/build.yml)](https://github.com/nekofar/foundry-hardhat-template/actions/workflows/build.yml)
[![GitHub](https://img.shields.io/github/license/nekofar/foundry-hardhat-template)](https://github.com/nekofar/foundry-hardhat-template/blob/master/LICENSE)
[![X (formerly Twitter) Follow](https://img.shields.io/badge/follow-%40nekofar-ffffff?logo=x&style=flat)](https://x.com/nekofar)
[![Farcaster (Warpcast) Follow](https://img.shields.io/badge/follow-%40nekofar-855DCD.svg?logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iMzIzIiBoZWlnaHQ9IjI5NyIgdmlld0JveD0iMCAwIDMyMyAyOTciIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik01NS41ODY3IDAuNzMzMzM3SDI2My40MTNWMjk2LjI2N0gyMzIuOTA3VjE2MC44OTNIMjMyLjYwN0MyMjkuMjM2IDEyMy40NzkgMTk3Ljc5MiA5NC4xNiAxNTkuNSA5NC4xNkMxMjEuMjA4IDk0LjE2IDg5Ljc2NDIgMTIzLjQ3OSA4Ni4zOTI2IDE2MC44OTNIODYuMDkzM1YyOTYuMjY3SDU1LjU4NjdWMC43MzMzMzdaIiBmaWxsPSJ3aGl0ZSIvPgo8cGF0aCBkPSJNMC4yOTMzMzUgNDIuNjhMMTIuNjg2NyA4NC42MjY3SDIzLjE3MzNWMjU0LjMyQzE3LjkwODIgMjU0LjMyIDEzLjY0IDI1OC41ODggMTMuNjQgMjYzLjg1M1YyNzUuMjkzSDExLjczMzNDNi40NjgyMiAyNzUuMjkzIDIuMiAyNzkuNTYyIDIuMiAyODQuODI3VjI5Ni4yNjdIMTA4Ljk3M1YyODQuODI3QzEwOC45NzMgMjc5LjU2MiAxMDQuNzA1IDI3NS4yOTMgOTkuNDQgMjc1LjI5M0g5Ny41MzMzVjI2My44NTNDOTcuNTMzMyAyNTguNTg4IDkzLjI2NTEgMjU0LjMyIDg4IDI1NC4zMkg3Ni41NlY0Mi42OEgwLjI5MzMzNVoiIGZpbGw9IndoaXRlIi8+CjxwYXRoIGQ9Ik0yMzQuODEzIDI1NC4zMkMyMjkuNTQ4IDI1NC4zMiAyMjUuMjggMjU4LjU4OCAyMjUuMjggMjYzLjg1M1YyNzUuMjkzSDIyMy4zNzNDMjE4LjEwOCAyNzUuMjkzIDIxMy44NCAyNzkuNTYyIDIxMy44NCAyODQuODI3VjI5Ni4yNjdIMzIwLjYxM1YyODQuODI3QzMyMC42MTMgMjc5LjU2MiAzMTYuMzQ1IDI3NS4yOTMgMzExLjA4IDI3NS4yOTNIMzA5LjE3M1YyNjMuODUzQzMwOS4xNzMgMjU4LjU4OCAzMDQuOTA1IDI1NC4zMiAyOTkuNjQgMjU0LjMyVjg0LjYyNjdIMzEwLjEyN0wzMjIuNTIgNDIuNjhIMjQ2LjI1M1YyNTQuMzJIMjM0LjgxM1oiIGZpbGw9IndoaXRlIi8+Cjwvc3ZnPgo=&style=flat)](https://warpcast.com/nekofar)
[![Donate](https://img.shields.io/badge/donate-nekofar.crypto-a2b9bc?logo=ko-fi&logoColor=white)](https://ud.me/nekofar.crypto)

> [!WARNING]
> Please note that the project is currently in an experimental phase, and it is subject to significant changes as it
> progresses.

## Description

This template is designed to streamline the process of creating smart contracts using Foundry and Hardhat. It provides a
robust starting point for smart contract development, integrating the best practices and tools needed to build, test,
and deploy contracts efficiently.

## Using This Template

You can use this repository as a template to create a new GitHub repository with the same directory structure and files.
Here's how:

1. On the [repository page](https://github.com/nekofar/foundry-hardhat-template), click the **Use this template**
   button.
2. Choose the owner of the new repository and enter a repository name.
3. Optionally, add a description for your repository.
4. Choose the repository visibility (Public or Private).
5. Click **Create repository from template** to create your new repository.

After creating your repository from this template, clone it and install the dependencies:

```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY
cd YOUR-REPOSITORY
pnpm install
```

## Usage

Here's how you can use this template:

- **Building Contracts**: Run `pnpm run build` to compile your smart contracts.
- **Running Tests**: Execute `pnpm run test` to run tests for your contracts using Hardhat and Forge.
- **Linting**: Use `pnpm run lint` to lint your Solidity code.

## License

This project is licensed under the Apache-2.0 License - see
the [LICENSE](https://github.com/nekofar/foundry-hardhat-template/blob/master/LICENSE) file for details.

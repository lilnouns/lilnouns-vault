# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0-alpha.20] - 2024-06-29

### Miscellaneous Tasks

- Upgrade pnpm version in github actions workflow
- Add Foundry installation to GitHub Actions workflow

## [1.0.0-alpha.19] - 2024-06-29

### Miscellaneous Tasks

- Update SPDX license identifier

## [1.0.0-alpha.18] - 2024-06-29

### Bug Fixes

- Solve some minor issues and update dependencies

## [1.0.0-alpha.17] - 2024-06-29

### Miscellaneous Tasks

- Add timezone to the Husky hooks
- Update solidity version to ^0.8.26
- Update pnpm version in GitHub Actions workflow

## [1.0.0-alpha.16] - 2024-03-22

### Miscellaneous Tasks

- Add `.venv` folder to the `.gitignore` file

## [1.0.0-alpha.15] - 2024-03-15

### Bug Fixes

- Solve some minor issues and update dependencies

## [1.0.0-alpha.14] - 2024-02-16

### Miscellaneous Tasks

- Improve `postinstall` to run forge dependency manager after install

## [1.0.0-alpha.13] - 2024-02-16

### Documentation

- Update README.md to solve some typo issues (#36)

### Miscellaneous Tasks

- Enable `engine-strict` on `.npmrc` file
- Add `pnpm` to the engines on `package.json`
- Add `preinstall` to prevent devs from using other package managers
- Add `postinstall` to run forge dependency manager after install

## [1.0.0-alpha.12] - 2024-01-31

### Bug Fixes

- Solve some minor issues and update dependencies

## [1.0.0-alpha.11] - 2024-01-28

### Miscellaneous Tasks

- Install `slither` if its not available
- Migrate huskey configs to the new major version
- Update `node` engine version on `package.json`

## [1.0.0-alpha.10] - 2024-01-25

### Miscellaneous Tasks

- Add forge formatter to `.lintstagerc`
- Update forge tests verbosity in script on `package.json`

## [1.0.0-alpha.9] - 2024-01-23

### Miscellaneous Tasks

- Improve coding style configs for `prettier` and `forge`
- Remove `forge` from linting and formatting
- Rename `.lintstagedrc` to `.lintstagedrc.json` for readability
- Rename `.prettierrc` to `.prettierrc.json` for readability
- Add a new `.editorconfig` file for better editor compatibility
- Add `husky` to the `prepare` script on `package.json`

### Styling

- Reformat code for better readability

## [1.0.0-alpha.8] - 2024-01-22

### Miscellaneous Tasks

- Add `slither` to the linting follow on `package.json`
- Change pragma solidity version from 0.8.13 to 0.8.18
- Add a new configuration file for `slither`
- Add forge formatter to `.lintstagerc`
- Change back `printWidth` to the default on `.prettierrc`
- Change compiler version to `0.18.18` on `foundry.toml`
- Change scripts to sequential instead of parallel on `package.json`
- Add `node_modules` to the `libs` on `foundry.toml`
- Change `compile_force_framework` to `foundry` on `slither.config.json`

## [1.0.0-alpha.7] - 2024-01-21

### Documentation

- Add more description and usage guide to the `README.md`

### Miscellaneous Tasks

- Add `*.sol` files to the `.lintstagedrc`
- Add `lint-staged` to the Husky `pre-commit`
- Add a new configuration file for `prettier`
- Add a new configuration file for `solhint`
- Add new `prebuild` and `pretest` scripts to `package.json`
- Change default node version for `nvm` to `lts/iron`
- Add `gas_reports` for all contract in `foundry.toml`

## [1.0.0-alpha.6] - 2024-01-21

### Miscellaneous Tasks

- Update build script on `package.json`
- Change minimum node engine to 18 on `package.json`
- Import `hardhat-solhint` on `hardhat.config.ts`
- Add new scripts for linting solidity code in `package.json`

## [1.0.0-alpha.5] - 2024-01-20

### Bug Fixes

- Solve some minor issues and update dependencies

## [1.0.0-alpha.4] - 2024-01-20

### Bug Fixes

- Solve some minor issues and update dependencies

## [1.0.0-alpha.3] - 2024-01-20

### Features

- Add type-safe smart contract interactions

## [1.0.0-alpha.2] - 2024-01-20

### Testing

- Replace `Counter` test file by typescript version

### Miscellaneous Tasks

- Add typescript configuration file
- Replace Hardhat configuration with typescript one

### Revert

- Add some packages with high security risks to resolutions

## [1.0.0-alpha.1] - 2024-01-20

### Miscellaneous Tasks

- Update repository address on `template` workflow

## [1.0.0-alpha.0] - 2024-01-20

### Testing

- Add a new `Counter` test file for Hardhat

### Documentation

- Add the Apache License file to the project
- Remove default project readme file
- Add a new readme file for the project
- Add issue templates for feature request and bug report
- Add new config file for GitHub Sponsorship

### Miscellaneous Tasks

- Forge init
- Add a new `package.json` file
- Add a new `hardhat.config.js` file
- Add Hardhat and Node cache files to `.gitignore`
- Update package manager configuration
- Add new config file for Dependabot
- Add new config file for stale bot
- Add new workflows for GitFlow and Template
- Replace `test` workflow by `build` workflow
- Remove unnecessary comments and cleanup `build` workflow

<!-- generated by git-cliff -->

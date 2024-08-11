// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit, Nonces } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract ERC20Mock is ERC20, ERC20Permit, ERC20Votes {
  constructor(
    string memory name,
    string memory symbol
  ) ERC20(name, symbol) ERC20Permit(name) {}

  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }

  function _update(
    address from,
    address to,
    uint256 value
  ) internal override(ERC20, ERC20Votes) {
    super._update(from, to, value);
  }

  function nonces(
    address owner
  ) public view override(ERC20Permit, Nonces) returns (uint256) {
    return super.nonces(owner);
  }
}

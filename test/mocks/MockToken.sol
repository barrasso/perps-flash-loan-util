// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @notice Mock ERC20 token
/// @dev Exposed mint/burn functions for testing purposes
contract MockToken is ERC20("Mock Token", "MOCK", 18) {
    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external {
        _burn(_from, _amount);
    }
}

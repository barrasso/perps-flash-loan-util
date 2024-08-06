// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";

contract FlashLoanProxy is ERC1967Proxy, Ownable {
    constructor(
        address _logic,
        bytes memory _data
    ) ERC1967Proxy(_logic, _data) {
        transferOwnership(msg.sender);
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        _upgradeTo(newImplementation);
    }
}

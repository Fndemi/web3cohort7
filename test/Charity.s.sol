// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "src/CharityPlatform.sol"; // Adjust the path as necessary
import "forge-std/Script.sol";

contract DeployCharityPlatform is Script {
    function run() public {
        vm.startBroadcast(); // Starts broadcasting transactions

        // Deploy the CharityPlatform contract
        CharityPlatform charityPlatform = new CharityPlatform();

        vm.stopBroadcast(); // Stops broadcasting transactions

        // Log the contract address
        console.log("CharityPlatform deployed to:", address(charityPlatform));
    }
}

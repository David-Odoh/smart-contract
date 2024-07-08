// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseScript} from "./DeployBase.s.sol";
import {console2 as console} from "forge-std/console2.sol";
import {DigitalCertificates} from "../src/DigitalCertificates.sol";

contract DeployDigitalCertificates is BaseScript {
  DigitalCertificates public digitalCertificates;
   address public centralAuthority;
   address public deploymentAddress;

     function run() external {
        startBroadcast();
        digitalCertificates = new DigitalCertificates();
        deploymentAddress = address(digitalCertificates);
        centralAuthority = msg.sender; // Set the deployer as the central authority

        vm.stopBroadcast();

        console.log("DigitalCertificates contract deployed at:", deploymentAddress);

    }
}

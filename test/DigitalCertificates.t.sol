// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DigitalCertificates} from "../src/DigitalCertificates.sol";

contract DigitalCertificatesTest is Test {
    DigitalCertificates public digitalCertificates;
    address centralAuthority = address(0x1);
    address regulator = address(0x2);
    address issuer = address(0x3);
    address graduate = address(0x4);

    function setUp() public {
        vm.prank(centralAuthority);
        digitalCertificates = new DigitalCertificates();
        digitalCertificates.registerWallet(centralAuthority, "Central Authority", DigitalCertificates.UserRole.CentralAuthority);

    }

    function testRegisterWallet() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);

        (string memory name, address userAddress, DigitalCertificates.UserRole role, bool isSuspended) = digitalCertificates.users(regulator);
        assertEq(name, "Regulator 1");
        assertEq(userAddress, regulator);
        assertEq(uint(role), uint(DigitalCertificates.UserRole.Regulator));
        assertEq(isSuspended, false);
    }

    function testRegisterRegulator() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);

        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        (, , DigitalCertificates.UserRole role, ) = digitalCertificates.users(regulator);
        assertEq(uint(role), uint(DigitalCertificates.UserRole.Regulator));
    }

    function testRevokeRegulator() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);

        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(centralAuthority);
        digitalCertificates.revokeRegulator(regulator, true);

        (, , , bool isSuspended) = digitalCertificates.users(regulator);
        assertEq(isSuspended, true);
    }

    function testRegisterIssuer() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        (, , DigitalCertificates.UserRole role, ) = digitalCertificates.users(issuer);
        assertEq(uint(role), uint(DigitalCertificates.UserRole.Issuer));
    }

    function testRevokeIssuer() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        vm.prank(regulator);
        digitalCertificates.revokeIssuer(issuer, true);

        (, , , bool isSuspended) = digitalCertificates.users(issuer);
        assertEq(isSuspended, true);
    }

    function testIssueCertificate() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        vm.prank(issuer);
        digitalCertificates.issueCertificate("Certificate 1", "Type 1", graduate);

        (string memory file, string memory fileType, address graduateAddress, bool isValid) = digitalCertificates.certificates("Certificate 1");
        assertEq(file, "Certificate 1");
        assertEq(fileType, "Type 1");
        assertEq(graduateAddress, graduate);
        assertEq(isValid, true);
    }

    function testRevokeCertificate() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        vm.prank(issuer);
        digitalCertificates.issueCertificate("Certificate 1", "Type 1", graduate);

        vm.prank(issuer);
        digitalCertificates.revokeCertificate("Certificate 1", false);

        (, , , bool isValid) = digitalCertificates.certificates("Certificate 1");
        assertEq(isValid, false);
    }

    function testGetAllRegulators() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        DigitalCertificates.User[] memory allRegulators = digitalCertificates.getAllRegulators();
        assertEq(allRegulators.length, 1);
        assertEq(allRegulators[0].userAddress, regulator);
    }

    function testGetIssuersByRegulator() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        DigitalCertificates.User[] memory allIssuers = digitalCertificates.getIssuersByRegulator(regulator);
        assertEq(allIssuers.length, 1);
        assertEq(allIssuers[0].userAddress, issuer);
    }

    function testGetCertificatesByIssuer() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        vm.prank(issuer);
        digitalCertificates.issueCertificate("Certificate 1", "Type 1", graduate);

        DigitalCertificates.Certificate[] memory allCertificates = digitalCertificates.getCertificatesByIssuer(issuer);
        assertEq(allCertificates.length, 1);
        assertEq(allCertificates[0].file, "Certificate 1");
    }

    function testVerifyCertificate() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        vm.prank(issuer);
        digitalCertificates.issueCertificate("Certificate 1", "Type 1", graduate);

        bool isValid = digitalCertificates.verifyCertificate("Certificate 1");
        assertEq(isValid, true);
    }

    function testGetRegulatorByAddress() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        (string memory name, address userAddress, DigitalCertificates.UserRole role, bool isSuspended) = digitalCertificates.getRegulatorByAddress(regulator);
        assertEq(name, "Regulator 1");
        assertEq(userAddress, regulator);
        assertEq(uint(role), uint(DigitalCertificates.UserRole.Regulator));
        assertEq(isSuspended, false);
    }

    function testGetIssuerByAddress() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        (string memory name, address userAddress, DigitalCertificates.UserRole role, bool isSuspended) = digitalCertificates.getIssuerByAddress(issuer);
        assertEq(name, "Issuer 1");
        assertEq(userAddress, issuer);
        assertEq(uint(role), uint(DigitalCertificates.UserRole.Issuer));
        assertEq(isSuspended, false);
    }

    function testGetCertificateByGraduateAddress() public {
        vm.prank(centralAuthority);
        digitalCertificates.registerWallet(regulator, "Regulator 1", DigitalCertificates.UserRole.Regulator);
        vm.prank(centralAuthority);
        digitalCertificates.registerRegulator(regulator, "Regulator 1");

        vm.prank(regulator);
        digitalCertificates.registerWallet(issuer, "Issuer 1", DigitalCertificates.UserRole.Issuer);
        vm.prank(regulator);
        digitalCertificates.registerIssuer(issuer, "Issuer 1");

        vm.prank(issuer);
        digitalCertificates.issueCertificate("Certificate 1", "Type 1", graduate);

        DigitalCertificates.Certificate[] memory certificates = digitalCertificates.getCertificateByGraduateAddress(graduate);
        assertEq(certificates.length, 1);
        assertEq(certificates[0].file, "Certificate 1");
    }
}

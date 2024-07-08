// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";

contract DigitalCertificates {

    enum UserRole { None, CentralAuthority, Regulator, Issuer, Graduates, Recruiter }

    struct User {
        string name;
        address userAddress;
        UserRole role;
        bool isSuspended;
    }

    struct Certificate {
        string file;
        string fileType;
        address graduateAddress;
        bool isValid;
    }

    mapping(address => User) public users;
    mapping(string => Certificate) public certificates;
    address[] public regulators;
    mapping(address => address[]) public issuersByRegulator;
    mapping(address => string[]) public certificatesByIssuer;

    event RegulatorRegistered(address regulator, string name);
    event IssuerRegistered(address issuer, string name);
    event CertificateIssued(string file, address issuer, address graduateAddress);
    event CertificateRevoked(string file);
    event RegulatorSuspended(address regulator);
    event IssuerSuspended(address issuer);
    event WalletRegistered(address indexed userAddress, string name, UserRole role);

    modifier onlyCentralAuthority() {
        require(users[msg.sender].role == UserRole.CentralAuthority, "Only central authority can perform this action");
        _;
    }

    modifier onlyRegulator() {
        require(users[msg.sender].role == UserRole.Regulator && !users[msg.sender].isSuspended, "Only active regulators can perform this action");
        _;
    }

    modifier onlyIssuer() {
        require(users[msg.sender].role == UserRole.Issuer && !users[msg.sender].isSuspended, "Only active issuers can perform this action");
        _;
    }

    constructor() {}

    // Central Authority Functions

 // Function to register a wallet address for each role
    function registerWallet(address _userAddress, string memory _name, UserRole _role) external {
        require(users[_userAddress].userAddress == address(0), "User already registered");
        users[_userAddress] = User(_name, _userAddress, _role, false);
        emit WalletRegistered(_userAddress, _name, _role);
    }
        function registerRegulator(address _regulator, string memory _name) external  {
        users[_regulator] = User(_name, _regulator, UserRole.Regulator, false);
        regulators.push(_regulator);
        emit RegulatorRegistered(_regulator, _name);
    }

    function revokeRegulator(address _regulator, bool _isSuspended) external  {
        require(users[_regulator].role == UserRole.Regulator, "Address is not a regulator");
        users[_regulator].isSuspended = _isSuspended;
        emit RegulatorSuspended(_regulator);
    }

    // Regulator Functions
    function registerIssuer(address _issuer, string memory _name) external  {
        users[_issuer] = User(_name, _issuer, UserRole.Issuer, false);
        issuersByRegulator[msg.sender].push(_issuer);
        emit IssuerRegistered(_issuer, _name);
    }

    function revokeIssuer(address _issuer, bool _isSuspended) external  {
        require(users[_issuer].role == UserRole.Issuer, "Address is not an issuer");
        users[_issuer].isSuspended = _isSuspended;
        emit IssuerSuspended(_issuer);
    }

    // Issuer Functions
    function issueCertificate(string memory _file, string memory _fileType, address _graduateAddress) external  {
        certificates[_file] = Certificate(_file, _fileType, _graduateAddress, true);
        certificatesByIssuer[msg.sender].push(_file);
        emit CertificateIssued(_file, msg.sender, _graduateAddress);
    }

    function revokeCertificate(string memory _file, bool _isValid) external  {
        require(certificates[_file].graduateAddress != address(0), "Certificate does not exist");
        certificates[_file].isValid = _isValid;
        emit CertificateRevoked(_file);
    }

    // Getter Functions
    function getAllRegulators() external view returns (User[] memory) {
        User[] memory allRegulators = new User[](regulators.length);
        for (uint i = 0; i < regulators.length; i++) {
            allRegulators[i] = users[regulators[i]];
        }
        return allRegulators;
    }

    function getIssuersByRegulator(address _regulator) external view returns (User[] memory) {
        address[] memory issuers = issuersByRegulator[_regulator];
        User[] memory allIssuers = new User[](issuers.length);
        for (uint i = 0; i < issuers.length; i++) {
            allIssuers[i] = users[issuers[i]];
        }
        return allIssuers;
    }

    function getCertificatesByIssuer(address _issuer) external view returns (Certificate[] memory) {
        string[] memory files = certificatesByIssuer[_issuer];
        Certificate[] memory allCertificates = new Certificate[](files.length);
        for (uint i = 0; i < files.length;) {
            allCertificates[i] = certificates[files[i]];
             unchecked {
                ++i;
            }
        }
        return allCertificates;
    }

    function verifyCertificate(string memory _file) external view returns (bool) {
        return certificates[_file].isValid;
    }

    function getRegulatorByAddress(address _regulator) external view returns (string memory name, address regulator, UserRole role, bool isSuspended) {
        User memory user = users[_regulator];
        return (user.name, user.userAddress, user.role, user.isSuspended);
    }

    function getIssuerByAddress(address _issuer) external view returns (string memory name, address issuer, UserRole role, bool isSuspended) {
        User memory user = users[_issuer];
        return (user.name, user.userAddress, user.role, user.isSuspended);
    }

    function getCertificateByGraduateAddress(address _graduateAddress) external view returns (Certificate[] memory) {
        Certificate[] memory result = new Certificate[](certificatesByIssuer[_graduateAddress].length);
        uint counter = 0;
        for (uint i = 0; i < certificatesByIssuer[_graduateAddress].length; i++) {
            Certificate memory cert = certificates[certificatesByIssuer[_graduateAddress][i]];
            if (cert.graduateAddress == _graduateAddress) {
                result[counter] = cert;
                counter++;
            }
        }
        return result;
    }
}

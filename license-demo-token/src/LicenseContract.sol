// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

contract LicenseContract {
    struct License {
        uint256 id;
        string nodeAddress;
        uint256 lastAccessed;
        uint256 totalClaimed;
    }

    uint256 MAX_CLAIM_PER_LICENSE = 1000;

    uint LICENSE_PRICE = 1 ether;

    uint256 public licenseCounter;  

    address public owner;  

    mapping(address => mapping(uint256 => License)) public licenses;
    mapping(address => uint256[]) public licensesByOwner;
    mapping(uint256 => address) public licenseOwner;


    constructor() {
        owner = msg.sender;
    }


    function getOwner() public view returns (address) {
        return owner;
    }

    function getLicensePrice() public view returns (uint) {
        return LICENSE_PRICE;
    }


    function buyLicense() public payable returns (uint256) {
        uint256 licensePrice = getLicensePrice();
        require(msg.value == licensePrice, "You must pay 1 ether to buy a license");
        licenseCounter++;
        licenses[msg.sender][licenseCounter] = License(
            licenseCounter,
            "0x0",
            block.timestamp,
            0
        );
        licensesByOwner[msg.sender].push(licenseCounter);
        licenseOwner[licenseCounter] = msg.sender;
        
        uint256 ownerStake = licensePrice / 2;
        payable(owner).transfer(ownerStake);
        return licenseCounter;
    }

    function getLicenseOwner(uint256 _licenseId) public view returns (address) {
        return licenseOwner[_licenseId];
    }


    function getLicenseByOwner(address _owner, uint256 _index) public view returns (License memory) {
        License memory license = licenses[_owner][_index];
        return license;
    }


    function getMyLicenses() public view returns (License[] memory) {
        uint256[] memory licenseIds = licensesByOwner[msg.sender];
        License[] memory result = new License[](licenseIds.length);
        for (uint256 i = 0; i < licenseIds.length; i++) {
            result[i] = licenses[msg.sender][licenseIds[i]];
        }
        return result;
    }


    function hasLicense(address _owner, uint256 _licenseId) public view returns (bool) {
        return licenseOwner[_licenseId] == _owner;
    }


    function deleteLicense(uint256 _licenseId) public {
        require(hasLicense(msg.sender, _licenseId), "You do not own this license");
        delete licenses[msg.sender][_licenseId];
        delete licenseOwner[_licenseId];
        uint256[] storage licensesArray = licensesByOwner[msg.sender];
        for (uint256 i = 0; i < licensesArray.length; i++) {
            if (licensesArray[i] == _licenseId) {
                licensesArray[i] = licensesArray[licensesArray.length - 1];
                licensesArray.pop();
                break;
            }
        }
    }


    function transferLicense(address _newOwner, uint256 _licenseId) public {
        require(hasLicense(msg.sender, _licenseId), "You do not own this license");
        
        License memory license = licenses[msg.sender][_licenseId];

        deleteLicense(_licenseId);

        licenses[_newOwner][_licenseId] = license;
        licenseOwner[_licenseId] = _newOwner;
        licensesByOwner[_newOwner].push(_licenseId);
    }



    function calculateRevenue(uint256 _licenseId) public view returns (uint256) {
        // for each second since the last access, the owner gets 1 wei
        License memory license = licenses[msg.sender][_licenseId];
        return (block.timestamp - license.lastAccessed);
    }


    function claimRevenue(uint256 _licenseId) public returns (uint256) {
        // console.log("License: ", _licenseId, " By ", msg.sender);
        require(hasLicense(msg.sender, _licenseId), "Claim not allowed");
        uint256 revenue = calculateRevenue(_licenseId);
        uint256 totalClaimed = licenses[msg.sender][_licenseId].totalClaimed;
        require(totalClaimed <= MAX_CLAIM_PER_LICENSE, "You have reached the maximum claimable amount");  
        if (totalClaimed + revenue > MAX_CLAIM_PER_LICENSE) {
            revenue = MAX_CLAIM_PER_LICENSE - totalClaimed;
        }
        require(revenue > 0, "No reward to claim");
        require(address(this).balance >= revenue, "Not enough balance to claim revenue");
        // transfer half of the revenue to the owner
        payable(msg.sender).transfer(revenue);
        licenses[msg.sender][_licenseId].lastAccessed = block.timestamp;
        licenses[msg.sender][_licenseId].totalClaimed += revenue;
        return revenue;
    }
    
}

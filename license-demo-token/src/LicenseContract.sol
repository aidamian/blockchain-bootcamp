// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Mock ERC-20 token for testing
contract MockERC20 is ERC20 {
    constructor() ERC20("Test Token", "TST") {
        _mint(msg.sender, 1_000_000 * 10**18); // Mint 1 million tokens
    }
}


contract LicenseContract {
    struct License {
        uint256 id;
        string nodeAddress;
        uint256 lastAccessed;
        uint256 totalClaimed;
    }

    uint256 MAX_CLAIM_PER_LICENSE = 10**16; 
    uint256 REWARD_PER_SECOND = 10**13;
    uint256 LICENSE_PRICE = 1 * 10**18; // 1 token (assuming 18 decimals)

    uint256 public licenseCounter;
    address public owner;
    IERC20 public token; // The ERC-20 token used for payments

    mapping(address => mapping(uint256 => License)) public licenses;
    mapping(address => uint256[]) public licensesByOwner;
    mapping(uint256 => address) public licenseOwner;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    receive() external payable {}

    function buyLicense() public returns (uint256) {
        uint256 licensePrice = getLicensePrice();
        require(token.balanceOf(msg.sender) >= licensePrice, "Insufficient token balance");
        require(token.allowance(msg.sender, address(this)) >= licensePrice, "Token allowance too low");

        // Transfer tokens from the buyer to the owner
        uint256 ownerStake = licensePrice / 2;
        uint256 protocolStake = licensePrice - ownerStake;
        require(token.transferFrom(msg.sender, owner, ownerStake), "Owner payment failed");
        require(token.transferFrom(msg.sender, address(this), protocolStake), "Protocol payment failed");

        // Register the license
        licenseCounter++;
        licenses[msg.sender][licenseCounter] = License(
            licenseCounter,
            "0x0",
            block.timestamp,
            0
        );
        licensesByOwner[msg.sender].push(licenseCounter);
        licenseOwner[licenseCounter] = msg.sender;

        return licenseCounter;
    }

    function claimRevenue(uint256 _licenseId) public returns (uint256) {
        require(hasLicense(msg.sender, _licenseId), "Claim not allowed");

        License storage license = licenses[msg.sender][_licenseId];
        uint256 revenue = (block.timestamp - license.lastAccessed) * REWARD_PER_SECOND;
        uint256 totalClaimed = license.totalClaimed;

        require(totalClaimed < MAX_CLAIM_PER_LICENSE, "Maximum claimable amount reached");
        if (totalClaimed + revenue > MAX_CLAIM_PER_LICENSE) {
            revenue = MAX_CLAIM_PER_LICENSE - totalClaimed;
        }

        require(revenue > 0, "No reward to claim");
        require(token.balanceOf(address(this)) >= revenue, "Not enough balance in contract");

        // Update license state
        license.lastAccessed = block.timestamp;
        license.totalClaimed += revenue;

        // Transfer tokens to the license owner
        token.transfer(msg.sender, revenue);

        return revenue;
    }


    function getOwner() public view returns (address) {
        return owner;
    }

    function getLicensePrice() public view returns (uint) {
        return LICENSE_PRICE;
    }

    function getMaxClaimPerLicense() public view returns (uint) {
        return MAX_CLAIM_PER_LICENSE;
    }

    function getRewardPerSecond() public view returns (uint) {
        return REWARD_PER_SECOND;
    }

    function getLicenseOwner(uint256 _licenseId) public view returns (address) {
        return licenseOwner[_licenseId];
    }

    function getFutureReward(uint256 _licenseId) public view returns (uint256) {
        License memory license = licenses[msg.sender][_licenseId];
        return (MAX_CLAIM_PER_LICENSE - license.totalClaimed);
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
    
}

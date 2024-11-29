// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LicenseContract {
    struct License {
        uint256 id;
        string nodeAddress;
        uint256 lastAccessed;
    }

    uint256 public licenseCounter;    

    mapping(address => mapping(uint256 => License)) public licenses;
    mapping(address => uint256[]) public licensesByOwner;
    mapping(uint256 => address) public licenseOwner;


    function createLicense(string memory _nodeAddress) public {
        licenseCounter++;
        licenses[msg.sender][licenseCounter] = License(
            licenseCounter,
            _nodeAddress,
            block.timestamp
        );
        licensesByOwner[msg.sender].push(licenseCounter);
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
        licenses[_newOwner][_licenseId] = licenses[msg.sender][_licenseId];
        delete licenses[msg.sender][_licenseId];
        licenseOwner[_licenseId] = _newOwner;
        licensesByOwner[msg.sender].push(_licenseId);
    }

    function buyLicense() public payable {
        require(msg.value == 1 ether, "You must pay 1 ether to buy a license");
        licenseCounter++;
        licenses[msg.sender][licenseCounter] = License(
            licenseCounter,
            "0x0",
            block.timestamp
        );
        licensesByOwner[msg.sender].push(licenseCounter);
    }


    function calculateRevenue(uint256 _licenseId) public view returns (uint256) {
        require(hasLicense(msg.sender, _licenseId), "You do not own this license");
        // for each second since the last access, the owner gets 1 wei
        License memory license = licenses[msg.sender][_licenseId];
        return (block.timestamp - license.lastAccessed);
    }


    function claimRevenue(uint256 _licenseId) public {
        require(hasLicense(msg.sender, _licenseId), "You do not own this license");
        uint256 revenue = calculateRevenue(_licenseId);
        payable(msg.sender).transfer(revenue);
    }
    
}

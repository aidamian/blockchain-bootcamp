// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LicenseContract} from "../src/LicenseContract.sol";


contract LicenseContractTest is Test {
    LicenseContract licenseContract;

    address owner = address(0xABCD); // Contract deployer
    address user1 = address(0x1234);
    address user2 = address(0x5678);

    function setUp() public {
        licenseContract = new LicenseContract();
        vm.deal(owner, 100 ether); // Set owner initial balance
        vm.deal(user1, 10 ether); // Set user1 initial balance
        vm.deal(user2, 10 ether); // Set user2 initial balance
    }

    function testBuyLicense() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        LicenseContract.License memory license = licenseContract.getLicenseByOwner(user1, 1);
        assertEq(license.id, licenseId);
        assertEq(license.nodeAddress, "0x0");
        assertGt(license.lastAccessed, 0);
    }

    function testCannotBuyLicenseWithoutSufficientFunds() public {
        vm.prank(user1);
        vm.expectRevert("You must pay 1 ether to buy a license");
        licenseContract.buyLicense{value: 0.5 ether}();
    }

    function testGetMyLicenses() public {
        vm.startPrank(user1);
        uint256 licenseId1 = licenseContract.buyLicense{value: 1 ether}();
        uint256 licenseId2 = licenseContract.buyLicense{value: 1 ether}();
        LicenseContract.License[] memory licenses = licenseContract.getMyLicenses();
        assertEq(licenses.length, 2);
        assertEq(licenses[0].id, licenseId1);
        assertEq(licenses[1].id, licenseId2);
    }

    function testCannotClaimRevenueOnOthersLicense() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        vm.prank(user2);
        vm.expectRevert("Claim not allowed");
        licenseContract.claimRevenue(licenseId);
    }

    function testClaimRevenue() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        // Advance time
        vm.warp(block.timestamp + 10);

        vm.prank(user1);
        uint256 contractBalance = address(licenseContract).balance;
        uint256 userBalance = user1.balance;

        uint256 claimedRevenue = licenseContract.claimRevenue(licenseId);
        assertEq(user1.balance, userBalance + claimedRevenue);
        assertEq(address(licenseContract).balance, contractBalance - claimedRevenue);
    }

    function testCannotClaimRevenueBeyondMax() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        // Advance time to exceed MAX_CLAIM_PER_LICENSE
        vm.warp(block.timestamp + 2000);

        vm.prank(user1);
        uint256 contractBalance = address(licenseContract).balance;
        uint256 userBalance = user1.balance;

        licenseContract.claimRevenue(licenseId);

        assertEq(user1.balance, userBalance + 1000); // MAX_CLAIM_PER_LICENSE
        assertEq(address(licenseContract).balance, contractBalance - 1000);
    }

    function testDeleteLicense() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        vm.prank(user1);
        licenseContract.deleteLicense(licenseId);

        vm.expectRevert("Claim not allowed");
        licenseContract.claimRevenue(licenseId);
    }

    function testTransferLicense() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        vm.prank(user1);
        licenseContract.transferLicense(user2, licenseId);

        vm.warp(block.timestamp + 2000);

        LicenseContract.License memory license = licenseContract.getLicenseByOwner(user2, licenseId);
        assertEq(license.id, licenseId);

        vm.expectRevert("Claim not allowed");
        vm.prank(user1);
        licenseContract.claimRevenue(licenseId);

        vm.prank(user2);
        licenseContract.claimRevenue(licenseId);
    }

    function testCannotTransferUnownedLicense() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        vm.prank(user2);
        vm.expectRevert("You do not own this license");
        licenseContract.transferLicense(user2, licenseId);
    }

    function testHasLicense() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();

        assertTrue(licenseContract.hasLicense(user1, licenseId));
        assertFalse(licenseContract.hasLicense(user2, licenseId));
    }

    function testNotRewardAvailable() public {
        vm.prank(user1);
        uint256 licenseId = licenseContract.buyLicense{value: 1 ether}();
        address licenseOwner = licenseContract.getLicenseOwner(licenseId);

        // console.log("License ID: ", licenseId);
        // console.log("User1: ", user1);
        // console.log("License Owner: ", licenseOwner);

        assertEq(licenseOwner, user1);
        assertTrue(licenseContract.hasLicense(user1, licenseId));

        // first time claim immediately after buying
        vm.prank(user1);
        vm.expectRevert("No reward to claim");
        licenseContract.claimRevenue(licenseId);

        // then claim after 10 seconds
        vm.warp(block.timestamp + 10);
        vm.prank(user1);
        uint256 user1Balance = user1.balance;
        uint256 claimed = licenseContract.claimRevenue(licenseId);
        assertEq(user1.balance, user1Balance + claimed);

        // claim again just after claiming
        vm.prank(user1);
        vm.expectRevert("No reward to claim");
        licenseContract.claimRevenue(licenseId);
    }
}

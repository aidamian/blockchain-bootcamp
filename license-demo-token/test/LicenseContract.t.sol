// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LicenseContract, MockERC20} from "../src/LicenseContract.sol";


contract LicenseContractTest is Test {
    LicenseContract licenseContract;
    MockERC20 token;

    address owner = address(0xABCD); // Contract deployer
    address user1 = address(0x1234);
    address user2 = address(0x5678);
    address user3 = address(0x9876);

    uint256 licensePrice;

    function setUp() public {
        // Deploy the token and license contract
        token = new MockERC20();
        // Distribute tokens to users
        token.transfer(user1, 1000 * 10**18);
        token.transfer(user2, 1000 * 10**18);
        token.transfer(user3,  0.5 * 10**18);

        vm.prank(owner);
        licenseContract = new LicenseContract(address(token));

        // Set the license price
        licensePrice = licenseContract.getLicensePrice();
    }

    function logEth(string memory message, uint256 value) public pure {
        uint256 wholePart = value / (10**18);
        uint256 fractionalPart = (value % (10**18)) / 1e14; // To get 4 decimal places

        console.log("%s %d.%d", message, wholePart, fractionalPart);
    }    

    function buyForUser(address user) public returns (uint256) {
        // Step 1: User approves the license contract to spend tokens
        vm.prank(user);
        token.approve(address(licenseContract), licensePrice);

        // Step 2: User calls buyLicense to purchase a license
        vm.prank(user);
        uint256 licenseId = licenseContract.buyLicense();        

        return licenseId;
    }

    function testBuyLicense() public {
        console.log("Owner: ", owner);
        console.log("Genesis:", licenseContract.getOwner());
        logEth("User1 balance: ", token.balanceOf(user1));
        logEth("User2 balance: ", token.balanceOf(user2));
        logEth("Owner balance: ", token.balanceOf(owner));

        uint256 licenseId = buyForUser(user1);

        LicenseContract.License memory license = licenseContract.getLicenseByOwner(user1, 1);
        assertEq(license.id, licenseId);
        assertEq(license.nodeAddress, "0x0");
        assertGt(license.lastAccessed, 0);

        buyForUser(user1);
        buyForUser(user2);

        console.log("Expecting user1 to have 2 licenses and user2 to have 1 license decreasing balance");
        logEth("User1 balance: ", token.balanceOf(user1));
        logEth("User2 balance: ", token.balanceOf(user2));
        logEth("Owner balance: ", token.balanceOf(owner));

    }

    function testCannotBuyLicenseWithoutSufficientFunds() public {                
        logEth("User3 balance: ", token.balanceOf(user3));
        // Step 1: User approves the license contract to spend tokens
        vm.prank(user3);
        token.approve(address(licenseContract), licensePrice);

        // Step 2: User calls buyLicense to purchase a license
        vm.expectRevert("Insufficient token balance");
        vm.prank(user3);
        licenseContract.buyLicense();        

    }

    function testGetMyLicenses() public {
        uint256 licenseId1 = buyForUser(user1);
        uint256 licenseId2 = buyForUser(user1);
        vm.startPrank(user1);
        LicenseContract.License[] memory licenses = licenseContract.getMyLicenses();
        assertEq(licenses.length, 2);
        assertEq(licenses[0].id, licenseId1);
        assertEq(licenses[1].id, licenseId2);
    }

    function testCannotClaimRevenueOnOthersLicense() public {
        uint256 licenseId = buyForUser(user1);

        vm.prank(user2);
        vm.expectRevert("Claim not allowed");
        licenseContract.claimRevenue(licenseId);
    }

    function testClaimRevenue() public {
        uint256 licenseId = buyForUser(user1);

        // Advance time
        vm.warp(block.timestamp + 10);

        uint256 contractBalance = token.balanceOf(address(licenseContract));
        uint256 userBalance = token.balanceOf(user1);
        logEth("User1 balance before claim: ", userBalance);
        logEth("Contract balance before claim: ", token.balanceOf(address(licenseContract)));
        vm.prank(user1);
        uint256 claimedRevenue = licenseContract.claimRevenue(licenseId);
        logEth("User1 balance after claim: ", token.balanceOf(user1));
        logEth("Contract balance after claim: ", token.balanceOf(address(licenseContract)));
        logEth("Claimed: ", claimedRevenue);
        assertEq(token.balanceOf(user1), userBalance + claimedRevenue);
        assertEq(token.balanceOf(address(licenseContract)), contractBalance - claimedRevenue);
    }

    function testCannotClaimRevenueBeyondMax() public {
        logEth("Owner balance before purchase: ", token.balanceOf(owner));
        logEth("Contract funds before purchase: ", token.balanceOf(address(licenseContract)));
        logEth("User1 balance before purchase: ", token.balanceOf(user1));

        uint256 licenseId = buyForUser(user1);

        logEth("Contract funds after purchase: ", token.balanceOf(address(licenseContract)));
        logEth("Owner balance after purchase: ", token.balanceOf(owner));
        logEth("User1 balance after purchase: ", token.balanceOf(user1));

        // Advance time to exceed MAX_CLAIM_PER_LICENSE
        uint256 timeAdvance = 2000;
        vm.warp(block.timestamp + timeAdvance);

        uint256 contractBalance = token.balanceOf(address(licenseContract));
        uint256 userBalance = token.balanceOf(user1);
        logEth("User1 balance before claim: ", userBalance);
        vm.prank(user1);
        uint256 futureReward = licenseContract.getFutureReward(licenseId);
        logEth("User1 future reward:", futureReward);
        vm.prank(user1);
        uint256 reward = licenseContract.claimRevenue(licenseId);
        logEth("User1 balance after claim: ", token.balanceOf(user1));

        uint256 theoreticalReward = timeAdvance * licenseContract.getRewardPerSecond();
        logEth("Theoretical reward: ", theoreticalReward);
        logEth("Reward claimed    : ", reward);
        vm.prank(user1);
        futureReward = licenseContract.getFutureReward(licenseId);
        logEth("User1 future reward:", futureReward);

        uint256 maxPossibleReward = licenseContract.getMaxClaimPerLicense();
        assertEq(token.balanceOf(user1), userBalance + maxPossibleReward); // MAX_CLAIM_PER_LICENSE
        assertEq(token.balanceOf(address(licenseContract)), contractBalance - maxPossibleReward);

        // claim again 
        vm.warp(block.timestamp + timeAdvance);
        
        contractBalance = token.balanceOf(address(licenseContract));
        userBalance = token.balanceOf(user1);
        logEth("User1 balance before claim: ", userBalance);
        vm.prank(user1);
        futureReward = licenseContract.getFutureReward(licenseId);
        logEth("User1 future reward:", futureReward);
        vm.prank(user1);
        vm.expectRevert("Maximum claimable amount reached");
        reward = licenseContract.claimRevenue(licenseId);
        logEth("User1 balance after claim: ", token.balanceOf(user1));

    }

    function testDeleteLicense() public {
        uint256 licenseId = buyForUser(user1);

        vm.prank(user1);
        licenseContract.deleteLicense(licenseId);

        vm.expectRevert("Claim not allowed");
        licenseContract.claimRevenue(licenseId);
    }

    function testTransferLicense() public {
        uint256 licenseId = buyForUser(user1);

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
        uint256 licenseId = buyForUser(user1);

        vm.prank(user2);
        vm.expectRevert("You do not own this license");
        licenseContract.transferLicense(user2, licenseId);
    }

    function testHasLicense() public {
        
        uint256 licenseId = buyForUser(user1);

        assertTrue(licenseContract.hasLicense(user1, licenseId));
        assertFalse(licenseContract.hasLicense(user2, licenseId));
    }

    function testNoRewardAvailable() public {
        uint256 licenseId = buyForUser(user1);
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
        uint256 user1Balance = token.balanceOf(user1);
        logEth("User1 balance before claim: ", user1Balance);
        logEth("Contract balance before claim: ", token.balanceOf(address(licenseContract)));
        vm.prank(user1);
        uint256 claimed = licenseContract.claimRevenue(licenseId);
        logEth("User1 balance after claim: ", token.balanceOf(user1));
        logEth("Claimed: ", claimed);
        assertEq(token.balanceOf(user1), user1Balance + claimed);

        // claim again just after claiming
        vm.prank(user1);
        vm.expectRevert("No reward to claim");
        licenseContract.claimRevenue(licenseId);
    }
}

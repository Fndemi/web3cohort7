// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/CharityPlatform.sol";

contract CharityPlatformTest is Test {
    CharityPlatform charityPlatform;

    address public campaignOwner = address(0x1);
    address public donor = address(0x2);
    address public admin = address(0x3);
    uint256 public campaignId = 1;
    string public campaignTitle = "Test Campaign";
    string public campaignDescription = "A campaign for testing purposes";
    uint256 public targetAmount = 10 ether;

    function setUp() public {
        charityPlatform = new CharityPlatform();
        vm.deal(campaignOwner, 100 ether); // Give campaign owner some ether
        vm.deal(donor, 100 ether); // Give donor some ether
        vm.deal(admin, 100 ether); // Give admin some ether
    }

    function testCreateCampaign() public {
        vm.prank(campaignOwner);
        charityPlatform.createCampaign(campaignTitle, campaignDescription, targetAmount);

        CharityPlatform.Campaign memory campaign = charityPlatform.getCampaign(campaignId);
        assertEq(campaign.title, campaignTitle);
        assertEq(campaign.description, campaignDescription);
        assertEq(campaign.targetAmount, targetAmount);
        assertEq(campaign.owner, campaignOwner);
        assertEq(campaign.isCompleted, false);
    }

    function testCampaignCompletion() public {
        vm.prank(campaignOwner);
        charityPlatform.createCampaign(campaignTitle, campaignDescription, targetAmount);

        vm.prank(donor);
        charityPlatform.donateToCampaign{value: targetAmount}(campaignId);

        CharityPlatform.Campaign memory campaign = charityPlatform.getCampaign(campaignId);
        assertEq(campaign.isCompleted, true);
    }

    function testCampaignDoesNotExist() public {
        vm.prank(donor);
        vm.expectRevert(CharityPlatform.CampaignDoesNotExist.selector);
        charityPlatform.donateToCampaign{value: 1 ether}(999);
    }

    function testDonateToCampaign() public {
        vm.prank(campaignOwner);
        charityPlatform.createCampaign(campaignTitle, campaignDescription, targetAmount);

        vm.prank(donor);
        charityPlatform.donateToCampaign{value: 1 ether}(campaignId);

        CharityPlatform.Campaign memory campaign = charityPlatform.getCampaign(campaignId);
        CharityPlatform.Donor[] memory donors = charityPlatform.getDonors(campaignId);

        assertEq(campaign.raisedAmount, 1 ether);
        assertEq(donors.length, 1);
        assertEq(donors[0].donorAddress, donor);
        assertEq(donors[0].amount, 1 ether);
    }

    function testDonationAmountMustBeGreaterThanZero() public {
        vm.prank(campaignOwner);
        charityPlatform.createCampaign(campaignTitle, campaignDescription, targetAmount);

        vm.prank(donor);
        vm.expectRevert(CharityPlatform.DonationAmountMustBeGreaterThanZero.selector);
        charityPlatform.donateToCampaign{value: 0 ether}(campaignId);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(campaignOwner);
        charityPlatform.createCampaign(campaignTitle, campaignDescription, targetAmount);

        vm.prank(donor);
        charityPlatform.donateToCampaign{value: 10 ether}(campaignId);

        vm.prank(admin);
        vm.expectRevert(CharityPlatform.OnlyCampaignOwnerCanWithdrawFunds.selector);
        charityPlatform.withdrawFunds(campaignId);
    }

    function testWithdrawFunds() public {
        vm.prank(campaignOwner);
        charityPlatform.createCampaign(campaignTitle, campaignDescription, targetAmount);

        vm.prank(donor);
        charityPlatform.donateToCampaign{value: 10 ether}(campaignId);

        uint256 balanceBefore = address(campaignOwner).balance;
        vm.prank(campaignOwner);
        charityPlatform.withdrawFunds(campaignId);

        uint256 balanceAfter = address(campaignOwner).balance;
        assertEq(balanceAfter, balanceBefore + 10 ether);

        CharityPlatform.Campaign memory campaign = charityPlatform.getCampaign(campaignId);
        assertEq(campaign.raisedAmount, 0);
    }
}

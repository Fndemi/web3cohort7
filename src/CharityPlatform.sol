// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CharityPlatform is ReentrancyGuard, AccessControl {
    // Struct for Campaign
    struct Campaign {
        uint256 id;
        string title;
        string description;
        uint256 targetAmount;
        uint256 raisedAmount;
        address owner;
        bool isCompleted;
    }

    // Struct for Donor
    struct Donor {
        address donorAddress;
        uint256 amount;
    }

    // State variables
    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Donor[]) public campaignDonors;

    // Custom errors
    error TargetAmountMustBeGreaterThanZero();
    error DonationAmountMustBeGreaterThanZero();
    error CampaignAlreadyCompleted();
    error CampaignDoesNotExist();
    error OnlyCampaignOwnerCanWithdrawFunds();
    error NoFundsToWithdraw();

    // Events
    event CampaignCreated(uint256 indexed campaignId, string title, address indexed owner);
    event DonationReceived(uint256 indexed campaignId, address indexed donor, uint256 amount);
    event FundsWithdrawn(uint256 indexed campaignId, uint256 amount);

    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CAMPAIGN_OWNER_ROLE = keccak256("CAMPAIGN_OWNER_ROLE");

    // Constructor to set up roles
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // The deployer gets the DEFAULT_ADMIN_ROLE by default
    }

    // Modifier to check if the caller is the campaign owner
    modifier onlyCampaignOwner(uint256 _campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        if (msg.sender != campaign.owner) {
            revert OnlyCampaignOwnerCanWithdrawFunds();
        }
        _;
    }

    // Modifier to check if campaign exists
    modifier campaignExists(uint256 _campaignId) {
        if (campaigns[_campaignId].id == 0) {
            revert CampaignDoesNotExist();
        }
        _;
    }

    // Function to create a campaign
    function createCampaign(string calldata _title, string calldata _description, uint256 _targetAmount) external {
        if (_targetAmount == 0) {
            revert TargetAmountMustBeGreaterThanZero();
        }

        uint256 campaignId = ++campaignCount;
        campaigns[campaignId] = Campaign({
            id: campaignId,
            title: _title,
            description: _description,
            targetAmount: _targetAmount,
            raisedAmount: 0,
            owner: msg.sender,
            isCompleted: false
        });

        // Grant the creator the campaign owner role
        _grantRole(CAMPAIGN_OWNER_ROLE, msg.sender);

        emit CampaignCreated(campaignId, _title, msg.sender);
    }

    // Function to donate to a campaign
    function donateToCampaign(uint256 _campaignId) external payable campaignExists(_campaignId) {
        if (msg.value == 0) {
            revert DonationAmountMustBeGreaterThanZero();
        }

        Campaign storage campaign = campaigns[_campaignId];
        if (campaign.isCompleted) {
            revert CampaignAlreadyCompleted();
        }

        campaign.raisedAmount += msg.value;
        campaignDonors[_campaignId].push(Donor({donorAddress: msg.sender, amount: msg.value}));

        if (campaign.raisedAmount >= campaign.targetAmount) {
            campaign.isCompleted = true;
        }

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // Function to withdraw funds from a campaign with reentrancy protection
    function withdrawFunds(uint256 _campaignId) external onlyCampaignOwner(_campaignId) nonReentrant {
        Campaign storage campaign = campaigns[_campaignId];
        if (campaign.raisedAmount == 0) {
            revert NoFundsToWithdraw();
        }

        uint256 amountToWithdraw = campaign.raisedAmount;
        campaign.raisedAmount = 0;

        // Transfer funds
        (bool success,) = payable(campaign.owner).call{value: amountToWithdraw}("");
        require(success, "Funds transfer failed");

        emit FundsWithdrawn(_campaignId, amountToWithdraw);
    }

    // Get donors for a specific campaign
    function getDonors(uint256 _campaignId) external view campaignExists(_campaignId) returns (Donor[] memory) {
        return campaignDonors[_campaignId];
    }

    function getCampaign(uint256 campaignId) public view returns (Campaign memory) {
        return campaigns[campaignId];
    }
}

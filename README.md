Charity Platform Smart Contract

Overview

The Charity Platform is a decentralized application built on Ethereum using Solidity. It enables transparent and efficient fundraising for charitable campaigns. Key features include campaign creation, donations, fund withdrawals, and role-based access control.

Features

1. Campaign Management

Create Campaigns: Users can create campaigns with a title, description, and target amount.

View Campaigns: Retrieve details of specific campaigns by their ID.

Role Assignment: Campaign creators are granted the CAMPAIGN_OWNER_ROLE automatically.

2. Donations

Contribute Funds: Supporters can donate ETH to campaigns.

Donation Tracking: All donations are logged with the donor’s address and amount contributed.

Completion Check: Campaigns are marked as completed when the target amount is reached.

3. Fund Withdrawal

Secure Withdrawals: Only campaign owners can withdraw funds, with protection against reentrancy attacks.

Event Logging: Withdrawals are recorded on-chain with the FundsWithdrawn event.

4. Role-Based Access Control

Roles:

DEFAULT_ADMIN_ROLE: Full administrative control (assigned to the deployer).

CAMPAIGN_OWNER_ROLE: Assigned to campaign creators for fund management.

Granular Permissions: Uses OpenZeppelin’s AccessControl for secure role management.

5. Security Features

Reentrancy Protection: Withdrawals are safeguarded using OpenZeppelin’s ReentrancyGuard.

Custom Errors: Replaces require statements with gas-efficient custom errors.

6. Funds Management

Transfer Mechanism: Uses call for transferring ETH, ensuring compatibility with evolving gas limits.

Refund Safety: Prevents withdrawals if no funds are available.

Design Highlights

Custom Errors

Improves gas efficiency and code clarity with descriptive errors like:

TargetAmountMustBeGreaterThanZero

DonationAmountMustBeGreaterThanZero

CampaignAlreadyCompleted

CampaignDoesNotExist

OnlyCampaignOwnerCanWithdrawFunds

NoFundsToWithdraw

ReentrancyGuard

Integrates OpenZeppelin’s ReentrancyGuard to mitigate vulnerabilities in fund withdrawal functions.

Access Control

Leverages OpenZeppelin’s AccessControl for secure role-based permissions.

Fund Transfers

Uses Solidity’s call method for ETH transfers, ensuring safety and compatibility.

Events

CampaignCreated: Logs campaign creation.

DonationReceived: Logs each donation.

FundsWithdrawn: Logs fund withdrawals.

Smart Contract Architecture

State Variables

campaignCount: Tracks the total number of campaigns.

campaigns: Maps campaign IDs to campaign details.

campaignDonors: Maps campaign IDs to lists of donors.

Modifiers

onlyCampaignOwner: Ensures only the campaign owner can perform certain actions.

campaignExists: Validates the existence of a campaign.

How to Use

Deployment

Clone the repository.

Use Foundry to compile and deploy the contract:

forge build
forge script script/Charity.s.sol --broadcast

Interacting with the Contract

Frontend: Use Ether.js to enable user interactions via a web interface.

Backend Scripts: Utilize Foundry’s tools for automated tasks like deployment and testing.

Future Enhancements

Governance Features: Allow donors to vote on fund allocation.

Enhanced Reporting: Provide detailed campaign analytics.

Multi-token Support: Accept donations in various ERC-20 tokens.

License

This project is licensed under the MIT License.

Acknowledgements

Built using Solidity and Foundry, with foundational libraries from OpenZeppelin. Inspired by the potential of blockchain to enable transparency and trust in charitable systems.


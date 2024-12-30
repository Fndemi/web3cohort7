import { ethers } from "ethers";
import fs from "fs";
import path from "path";
import readline from "readline";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

// Set the directory path for ABI file and contract address
const __dirname = new URL('.', import.meta.url).pathname;

// Connect to Sepolia network using Alchemy
const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL); // Load Sepolia RPC URL from .env
const contractABI = JSON.parse(fs.readFileSync(path.join(__dirname, 'out/CharityPlatform.sol/CharityPlatform.json'))).abi;

// Define your wallet's private key and create a wallet object
const privateKey = process.env.PRIVATE_KEY; // Load private key from .env
const wallet = new ethers.Wallet(privateKey, provider);

// The address of the deployed contract on Sepolia
const contractAddress = "0x307211088f632B511E875847855CA1b7f47De908"; // Updated deployed contract address

// Create a contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

// Initialize readline interface
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

// Helper function for user input
const askQuestion = (question) => new Promise((resolve) => rl.question(question, resolve));

// Function to view all campaigns
async function viewCampaigns() {
    console.log("\nDeployer Campaign Management Mode");

    try {
        // Dynamically fetch all campaigns by looping through campaign IDs
        const campaignCount = await contract.campaignCount(); // Get the total number of campaigns
        for (let i = 1; i <= campaignCount; i++) {
            const campaign = await contract.getCampaign(i); // Get each campaign using its ID
            console.log(`
            Campaign ID: ${campaign.id}
            Title: ${campaign.title}
            Description: ${campaign.description}
            Target Amount: ${ethers.formatUnits(campaign.targetAmount, 18)} ETH
            Raised Amount: ${ethers.formatUnits(campaign.raisedAmount, 18)} ETH
            Status: ${campaign.isCompleted ? 'Completed' : 'Active'}
            `);
        }
    } catch (error) {
        console.error("Error fetching campaigns:", error.message);
    }
}

// Function for the deployer to create campaigns
async function createCampaign() {
    console.log("\nDeployer Campaign Creation Mode");
    const title = await askQuestion("Enter the campaign title: ");
    const description = await askQuestion("Enter the campaign description: ");
    const targetAmount = ethers.parseUnits(await askQuestion("Enter the target amount in ETH: "), 18);

    try {
        const tx = await contract.createCampaign(title, description, targetAmount);
        console.log(`Creating campaign... Transaction Hash: ${tx.hash}`);
        const receipt = await tx.wait();
        console.log(`Campaign created successfully in block ${receipt.blockNumber}`);
    } catch (error) {
        console.error("Error creating campaign:", error.message);
    }
}

// Function to allow users to donate to a campaign
async function donateToCampaign() {
    console.log("\nUser Donation Mode");
    const campaignId = parseInt(await askQuestion("Enter the campaign ID to donate to: "));
    const amount = ethers.parseUnits(await askQuestion("Enter the donation amount in ETH: "), 18);

    try {
        const tx = await contract.donateToCampaign(campaignId, { value: amount });
        console.log(`Donating... Transaction Hash: ${tx.hash}`);
        const receipt = await tx.wait();
        console.log(`Donation successful in block ${receipt.blockNumber}`);
    } catch (error) {
        console.error("Error donating to campaign:", error.message);
    }
}

// Main function to separate deployer and user flows
async function main() {
    const userType = await askQuestion("Are you the deployer or a user? (deployer/user): ");

    if (userType.toLowerCase() === "deployer") {
        const action = await askQuestion("What would you like to do? (1: Create Campaign, 2: View Campaigns): ");
        if (action === "1") {
            await createCampaign();
        } else if (action === "2") {
            await viewCampaigns();
        } else {
            console.log("Invalid input! Please choose '1' or '2'.");
        }
    } else if (userType.toLowerCase() === "user") {
        await donateToCampaign();
    } else {
        console.log("Invalid input! Please type 'deployer' or 'user'.");
    }

    rl.close();
}

// Run the script
main().catch((error) => {
    console.error("Error in script:", error.message);
    rl.close();
});

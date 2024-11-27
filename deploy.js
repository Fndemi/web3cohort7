const { ethers } = require("ethers");
require("dotenv").config();
const advancedBookStoreABI = require("./artifacts/contracts/Advanced.sol/AdvancedBookStore.json");

// Load environment variables
const alchemyRpcUrl = process.env.ALCHEMY_RPC_URL;  // Full Alchemy RPC URL with API Key
const privateKey = process.env.WALLET_PRIVATE_KEY;  // Your wallet private key from .env file

// Set up the provider using the Alchemy RPC URL
const provider = new ethers.providers.JsonRpcProvider(alchemyRpcUrl);  // Correct way to instantiate the provider
const wallet = new ethers.Wallet(privateKey, provider);

// Contract address of the deployed contract
const contractAddress = '0xf2dbb5cecc9eac0b4d9c870cff9d4293741af4fd'; // Replace with your deployed contract address

// Create contract instance
const contract = new ethers.Contract(contractAddress, advancedBookStoreABI.abi, wallet);

// Function to add a book to the contract
const addBookToContract = async (bookId, title, author, price, stock) => {
    try {
        console.log(`Attempting to add book with ID: ${bookId}`);
        const txResponse = await contract.addBook(bookId, title, author, price, stock);
        console.log(`Transaction Hash: ${txResponse.hash}`);
        console.log(`Check the transaction on Sepolia: https://sepolia.etherscan.io/tx/${txResponse.hash}`);
        await txResponse.wait(); // Wait for the transaction to be mined
        console.log("Book added successfully.");
    } catch (error) {
        console.error("Error adding book:", error);
    }
};

// Function to get book details from the contract
const getBookFromContract = async (bookId) => {
    try {
        console.log(`Fetching details for book ID: ${bookId}`);
        const book = await contract.getBooks(bookId);
        console.log(`Book Details:`);
        console.log(`Title: ${book[0]}`);
        console.log(`Author: ${book[1]}`);
        console.log(`Price: ${ethers.utils.formatEther(book[2])} ETH`);
        console.log(`Stock: ${book[3]}`);
    } catch (error) {
        console.error("Error fetching book details:", error);
    }
};

// Function to buy a book from the contract
const buyBookFromContract = async (bookId, quantity) => {
    try {
        console.log(`Attempting to buy ${quantity} copies of book with ID: ${bookId}`);
        const book = await contract.getBooks(bookId);
        const price = ethers.utils.parseEther(book[2].toString());  // Convert price to Wei
        const totalPrice = price.mul(quantity);  // Calculate total price
        console.log(`Total price for ${quantity} copies: ${ethers.utils.formatEther(totalPrice)} ETH`);

        const txResponse = await contract.buyBook(bookId, quantity, { value: totalPrice });
        console.log(`Transaction Hash: ${txResponse.hash}`);
        console.log(`Check the transaction on Sepolia: https://sepolia.etherscan.io/tx/${txResponse.hash}`);
        await txResponse.wait(); // Wait for the transaction to be mined
        console.log(`Book purchase completed.`);
    } catch (error) {
        console.error("Error buying book:", error);
    }
};

// Sample data for a book
const bookDetails = {
    bookId: 5,
    title: "Harry Potter",
    author: "J.K. Rowling",
    price: 10, // Price in ETH
    stock: 100
};

// Interact with the contract
(async () => {
    console.log("Starting interaction with the contract...");
    // Uncomment to add a book
    await addBookToContract(bookDetails.bookId, bookDetails.title, bookDetails.author, bookDetails.price, bookDetails.stock);

    // Uncomment to fetch details of a book
await getBookFromContract(5);

    // Uncomment to buy a book
    await buyBookFromContract(5, 1);
})();

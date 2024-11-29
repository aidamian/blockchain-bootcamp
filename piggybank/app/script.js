// script.js

const app_ver = "0.2.0";

// inject version in html page for dappVersion element
// Wait for the DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
  // Inject version into the HTML page for the dappVersion element
  const versionElement = document.getElementById("dappVersion");
  if (versionElement) {
      versionElement.innerText = app_ver;
  } else {
      console.error("Element with ID 'dappVersion' not found in the DOM.");
  }
});
// Ensure Web3 is available globally
let web3;

// Optional periodic check as a fallback
let currentChainId = null;

const ETH_SEPOLIA_CHAIN_ID = 11155111;
const ARBITRUM_SEPOLIA_CHAIN_ID = 421614;
const ARBITRUM_ONE_CHAIN_ID = 42161;

const supportedChainIds = [ETH_SEPOLIA_CHAIN_ID, ARBITRUM_SEPOLIA_CHAIN_ID, ARBITRUM_ONE_CHAIN_ID];


function getChainParams(chainIdDecimal) {
  switch (chainIdDecimal) {
    case ETH_SEPOLIA_CHAIN_ID: // Ethereum Sepolia Testnet
      return {
        chainId: '0x' + chainIdDecimal.toString(16),
        chainName: 'Sepolia',
        nativeCurrency: {
          name: 'SepoliaETH',
          symbol: 'ETH',
          decimals: 18
        },
        rpcUrls: ['https://rpc.sepolia.org'],
        blockExplorerUrls: ['https://sepolia.etherscan.io']
      };
    case ARBITRUM_SEPOLIA_CHAIN_ID: // Arbitrum Sepolia Testnet
      return {
        chainId: '0x' + chainIdDecimal.toString(16),
        chainName: 'Arbitrum Sepolia',
        nativeCurrency: {
          name: 'Arbitrum SepoliaETH',
          symbol: 'ETH',
          decimals: 18
        },
        rpcUrls: ['https://sepolia-rollup.arbitrum.io/rpc'],
        blockExplorerUrls: ['https://sepolia.arbiscan.io']
      };
    case ARBITRUM_ONE_CHAIN_ID: // Arbitrum One
      return {
        chainId: '0x' + chainIdDecimal.toString(16),
        chainName: 'Arbitrum One',
        nativeCurrency: {
          name: 'Ether',
          symbol: 'ETH',
          decimals: 18
        },
        rpcUrls: ['https://arb1.arbitrum.io/rpc'],
        blockExplorerUrls: ['https://arbiscan.io']
      };
    default:
      throw new Error('Unsupported chain ID');
  }
}


// Populate the network select dropdown
function populateNetworkSelect() {
  const networkSelect = document.getElementById('networkSelect');
  
  supportedChainIds.forEach(chainId => {
    try {
      const params = getChainParams(chainId); // Fetch chain details
      const option = document.createElement('option');
      option.value = params.chainId;
      option.textContent = params.chainName;
      networkSelect.appendChild(option);
    } catch (error) {
      console.error(`Error loading chain params for chainId ${chainId}:`, error.message);
    }
  });
}

// Call this function on page load or whenever the dropdown needs to be updated
populateNetworkSelect();




if (typeof window.ethereum !== 'undefined') {
    web3 = new Web3(window.ethereum);
} else {
    alert("Please install MetaMask to use this application.");
}

const contractABI = [
  {
    "inputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [],
    "name": "ballance",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "address payable",
        "name": "destAddr",
        "type": "address"
      }
    ],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "stateMutability": "payable",
    "type": "receive"
  }
];

const supportedNetworks = {
    11155111: "ETH Sepolia",
    421613: "Arbitrum Sepolia",
    42161: "Arbitrum One"
};

function logMessage(...messages) {
    const formattedMessage = messages.join(' ');
    console.log(formattedMessage);
    const logWindow = document.getElementById("logWindow");
    if (logWindow) {
        logWindow.value += formattedMessage + "\n";
        logWindow.scrollTop = logWindow.scrollHeight;
    } else {
        console.error("Log window element not found.");
    }
}

async function withdraw() {
    try {
        if (typeof window.ethereum === 'undefined') {
            alert("Please install MetaMask to use this feature.");
            return;
        }

        const contractAddress = document.getElementById("contractAddress").value.trim();
        const amount = document.getElementById("amount").value.trim();

        // Initialize Web3 before using utils
        const web3 = new Web3(window.ethereum);

        if (!web3.utils.isAddress(contractAddress)) {
            alert("Invalid contract address.");
            return;
        }

        if (!amount || isNaN(amount) || Number(amount) <= 0) {
            alert("Please enter a valid amount.");
            return;
        }

        await window.ethereum.request({ method: 'eth_requestAccounts' });
        
        // Ensure network compatibility
        const isNetworkSupported = await checkNetwork(web3);
        if (!isNetworkSupported) return;

        const contract = new web3.eth.Contract(contractABI, contractAddress);

        try {
            const amountInWei = web3.utils.toWei(amount, 'ether');
            const accounts = await web3.eth.getAccounts();
            const ownerAddress = accounts[0];

            // Check if amount exceeds contract balance
            const balanceInWei = await contract.methods.balance().call(); // Corrected method name
            if (BigInt(amountInWei) > BigInt(balanceInWei)) {
                alert("Withdrawal amount exceeds contract balance.");
                return;
            }

            logMessage(`Initiating withdrawal of ${amount} ETH to address ${ownerAddress}`);

            const transaction = await contract.methods.withdraw(amountInWei, ownerAddress).send({
                from: ownerAddress
            });

            alert("Withdrawal successful!");
            logMessage(`Transaction successful. Hash: ${transaction.transactionHash}`);
        } catch (error) {
            logMessage("Error withdrawing funds (Code:", error.code || 'N/A', "):", error.message);
            alert("An error occurred during withdrawal. Check the logs for details.");
        }
    } catch (error) {
        logMessage("Unexpected error in withdraw function:", error.message);
    }
}

async function getBalance() {
    try {
        if (typeof window.ethereum === 'undefined') {
            alert("Please install MetaMask to use this feature.");
            return;
        }

        const contractAddress = document.getElementById("contractAddress").value.trim();

        const web3 = new Web3(window.ethereum);

        if (!web3.utils.isAddress(contractAddress)) {
            alert("Invalid contract address.");
            return;
        }

        // Ensure network compatibility
        const isNetworkSupported = await checkNetwork(web3);
        if (!isNetworkSupported) return;

        const contract = new web3.eth.Contract(contractABI, contractAddress);

        try {
            logMessage(`Getting balance for contract ${contractAddress}`);
            const balanceInWei = await contract.methods.balance().call(); // Corrected method name
            const balanceInEth = web3.utils.fromWei(balanceInWei, 'ether');
            logMessage(`Balance: ${balanceInEth} ETH`);
            document.getElementById("balanceDisplay").innerText = balanceInEth;
        } catch (error) {
            logMessage("Error getting balance (Code:", error.code || 'N/A', "):", error.message);
            alert("An error occurred while getting the balance. Check the logs for details.");
        }
    } catch (error) {
        logMessage("Unexpected error in getBalance function:", error.message);
    }
}



async function checkNetwork(web3) {
    try {
        const chainId = await web3.eth.getChainId();
        const selectedChainIdDecimal = parseInt(document.getElementById("networkSelect").value);
        const selectedChainIdHex = '0x' + selectedChainIdDecimal.toString(16);

        if (chainId === selectedChainIdDecimal) {
            const networkName = supportedNetworks[chainId] || `Unknown Network (Chain ID: ${chainId})`;
            logMessage(`Connected to network: ${networkName} (Chain ID: ${chainId})`);
            const networkDisplay = document.getElementById("networkDisplay");
            if (networkDisplay) {
                networkDisplay.innerText = networkName;
            } else {
                logMessage("networkDisplay element not found.");
            }
            return true;
        } else {
            logMessage(`Current network (Chain ID: ${chainId}) does not match selected network (Chain ID: ${selectedChainIdDecimal}). Prompting network switch.`);
            try {
                // Attempt to switch network
                await window.ethereum.request({
                    method: 'wallet_switchEthereumChain',
                    params: [{ chainId: selectedChainIdHex }]
                });
                const networkName = supportedNetworks[selectedChainIdDecimal] || `Unknown Network (Chain ID: ${selectedChainIdDecimal})`;
                logMessage(`Switched to network: ${networkName} (Chain ID: ${selectedChainIdDecimal})`);
                return true;
            } catch (switchError) {
                // Error code 4902 indicates the chain is missing on MetaMask
                logMessage(`Network switch failed (Code: ${switchError.code || 'N/A'}):`, switchError.message);
                if (switchError.code === 4902 || switchError.message.includes('Unrecognized chain ID')) {                    
                    try {
                        const chainParams = getChainParams(selectedChainIdDecimal);
                        logMessage("Chain not added to MetaMask. Attempting to add chain", selectedChainIdDecimal, chainParams.chainName);
                        await window.ethereum.request({
                            method: 'wallet_addEthereumChain',
                            params: [chainParams],
                        });
                        // After adding, try switching again
                        await window.ethereum.request({
                            method: 'wallet_switchEthereumChain',
                            params: [{ chainId: selectedChainIdHex }]
                        });
                        const networkName = supportedNetworks[selectedChainIdDecimal] || `Unknown Network (Chain ID: ${selectedChainIdDecimal})`;
                        logMessage(`Added and switched to network: ${networkName} (Chain ID: ${selectedChainIdDecimal})`);
                        return true;
                    } catch (addError) {
                        logMessage("Failed to add chain (Code:", addError.code || 'N/A', "):", addError.message);
                        alert("Please add the network to MetaMask manually.");
                        return false;
                    }
                } else {
                    logMessage("Network switch failed:", switchError.message);
                    alert("Please switch to the selected network.");
                    return false;
                }
            }
        }
    } catch (error) {
        logMessage("Error checking network (Code:", error.code || 'N/A', "):", error.message);
        return false;
    }
}

function generateNonce() {
    return web3.utils.randomHex(16);
}

async function signIn() {
    try {
        if (typeof window.ethereum === 'undefined') {
            alert("MetaMask is required to use this feature.");
            return;
        }

        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.requestAccounts();
        const userAddress = accounts[0];

        if (sessionStorage.getItem("isSignedIn")) {
            logMessage("User already signed in for this session.");
            return;
        }

        const isNetworkSupported = await checkNetwork(web3);
        if (!isNetworkSupported) return;

        try {
            const nonce = generateNonce();

            const message = `
By confirming this signature and engaging with our platform, you confirm your status as the rightful account manager or authorized representative for the wallet address ${userAddress}. 
This action grants permission for a login attempt on the https://app.naeural.ai portal. Your interaction with our site signifies your acceptance of Naeural's EULA, Terms of Service, and Privacy Policy, as detailed in our official documentation. 
You acknowledge having fully reviewed these documents, accessible through our website. We strongly advise familiarizing yourself with these materials to fully understand our data handling practices and your entitlements as a user.

Date: ${new Date().toISOString()}
Nonce: ${nonce}
            `;

            const signature = await window.ethereum.request({
                method: 'personal_sign',
                params: [message, userAddress],
            });

            logMessage("Message signed successfully. Signature:", signature, "Nonce:", nonce);
            // Optionally send nonce and signature to backend here
            sessionStorage.setItem("isSignedIn", true);
            alert("Sign-in successful!");
        } catch (error) {
            logMessage("Error during signing (Code:", error.code || 'N/A', "):", error.message);
            alert("Failed to sign in.");
        }
    } catch (error) {
        logMessage("Unexpected error in signIn function:", error.message);
    }
}

// Event listeners for network and account changes
if (window.ethereum) {
    window.ethereum.on('chainChanged', handleChainChanged);
    window.ethereum.on('accountsChanged', handleAccountsChanged);
}

function handleChainChanged(chainId) {
    try {
        const chainIdDecimal = parseInt(chainId, 16);
        logMessage(`Network changed to Chain ID: ${chainIdDecimal}`);
        // Re-initialize the application or update the UI
        const web3 = new Web3(window.ethereum);
        checkNetwork(web3);
        // Optionally reload the page
        // window.location.reload();
    } catch (error) {
        logMessage("Error in handleChainChanged:", error.message);
    }
}

function handleAccountsChanged(accounts) {
    try {
        if (accounts.length === 0) {
            logMessage("No accounts available.");
            // Handle the case where the user has locked MetaMask
        } else {
            logMessage(`Account changed to ${accounts[0]}`);
            // Update the application state if necessary
        }
    } catch (error) {
        logMessage("Error in handleAccountsChanged:", error.message);
    }
}

// Event listener for network selection changes
document.getElementById('networkSelect').addEventListener('change', async function() {
    try {
        if (typeof window.ethereum !== 'undefined') {
            const web3 = new Web3(window.ethereum);
            await checkNetwork(web3);
        } else {
            alert("MetaMask is required to use this feature.");
        }
    } catch (error) {
        logMessage("Error handling networkSelect change:", error.message);
    }
});


async function periodicallyCheckNetwork() {
    try {
        if (typeof window.ethereum === 'undefined') return;
        const web3 = new Web3(window.ethereum);
        const chainId = await web3.eth.getChainId();
        if (chainId !== currentChainId) {
            logMessage(`Detected network change from ${currentChainId} to Chain ID: ${chainId}`);
            currentChainId = chainId;
            await checkNetwork(web3);
        }
    } catch (error) {
        logMessage("Error checking network (Code:", error.code || 'N/A', "):", error.message);
    }
}

// Check every 5 seconds
setInterval(periodicallyCheckNetwork, 5000);

// Trigger sign-in on page load
window.addEventListener('load', signIn);

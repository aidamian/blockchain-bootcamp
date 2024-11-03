
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


function logMessage(message) {
  // Log to console
  console.log(message);

  // Log to the log window
  const logWindow = document.getElementById("logWindow");
  logWindow.value += message + "\n";

  // Scroll to the bottom of the log window
  logWindow.scrollTop = logWindow.scrollHeight;
}

async function withdraw() {
  if (typeof window.ethereum === 'undefined') {
      alert("Please install MetaMask to use this feature.");
      return;
  }

  const contractAddress = document.getElementById("contractAddress").value;
  const amount = document.getElementById("amount").value;

  // Create contract instance
  const contract = new web3.eth.Contract(contractABI, contractAddress);


  if (!contractAddress || !amount) {
      alert("Please provide a valid contract address and amount.");
      return;
  }

  // Request account access if needed
  await window.ethereum.request({ method: 'eth_requestAccounts' });

  // Initialize web3
  const web3 = new Web3(window.ethereum);


  try {
      // Convert the amount from ETH to Wei
      const amountInWei = web3.utils.toWei(amount, 'ether');

      // Get the owner's address from MetaMask
      const accounts = await web3.eth.getAccounts();
      const ownerAddress = accounts[0];

      console.log(`Withdrawing from contract ${contractAddress} to address ${ownerAddress}`);

      // Send transaction to withdraw funds
      const transaction = await contract.methods.withdraw(amountInWei, ownerAddress).send({
          from: ownerAddress
      });

      alert("Withdrawal successful!");
      logMessage("Transaction receipt:", transaction);
  } catch (error) {
      logMessage("Error withdrawing funds:", error);
      alert("An error occurred during withdrawal. Check the console for details.");
  }
}

async function getBalance() {
  const contractAddress = document.getElementById("contractAddress").value;

  if (!contractAddress) {
      alert("Please provide a valid contract address.");
      return;
  }

  // Initialize web3
  const web3 = new Web3(window.ethereum);

  // Create contract instance
  const contract = new web3.eth.Contract(contractABI, contractAddress);

  try {
      logMessage(`Getting balance for contract ${contractAddress}`);
      // Call the `ballance` function to get the balance
      const balanceInWei = await contract.methods.ballance().call();
      const balanceInEth = web3.utils.fromWei(balanceInWei, 'ether');
      logMessage(`Balance: ${balanceInEth} ETH for contract ${contractAddress}`);

      // Update the displayed balance
      document.getElementById("balanceDisplay").innerText = balanceInEth;
  } catch (error) {
      logMessage("Error getting balance:", error);
      alert("An error occurred while getting the balance. Check the console for details.");
  }
}
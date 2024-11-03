const { Web3, ERR_CORE_CHAIN_MISMATCH }  = require('web3');
const web3 = new Web3('http://rpc.sepolia.org');
const abi = require('./ABI.json');
const contract = new web3.eth.Contract(abi, '0xD197aAf1Ef2584322F191b2B72388f18718A5BC7');

async function checkBalance(address) {
  try {
    const balance = await web3.eth.getBalance(address);
    const eth_balance = web3.utils.fromWei(balance, 'ether');
    console.log(`Balance of ${address}: ${eth_balance} ETH`);
  } catch (error) {
    console.error(`Error fetching balance for ${address}:`, error);
  }
}

async function checkBalanceViaContract(contract) {
  try {
    const ballance = await contract.methods.ballance().call();
    const eth_balance = web3.utils.fromWei(ballance, 'ether');
    console.log(`Balance of contract: ${eth_balance} ETH`);
  } catch (error) {
    console.error(`Error fetching balance for contract:`, error);
  }
}

checkBalance('0x31368849e6798bC405f501fee4f8b8cB75a0Fa16');
checkBalance('0xD197aAf1Ef2584322F191b2B72388f18718A5BC7');

checkBalanceViaContract(contract);


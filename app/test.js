const { Web3 }  = require('web3');
const web3 = new Web3('http://rpc.sepolia.org');

async function checkBalance(address) {
  try {
    const balance = await web3.eth.getBalance(address);
    console.log(`Balance of ${address}: ${balance}`);
  } catch (error) {
    console.error(`Error fetching balance for ${address}:`, error);
  }
}

checkBalance('0x31368849e6798bC405f501fee4f8b8cB75a0Fa16');
checkBalance('0xD197aAf1Ef2584322F191b2B72388f18718A5BC7');


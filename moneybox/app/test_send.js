const { Web3, ERR_CORE_CHAIN_MISMATCH }  = require('web3');
const web3 = new Web3('http://rpc.sepolia.org');
const abi = require('./ABI.json');
const contract = new web3.eth.Contract(abi, '0xD197aAf1Ef2584322F191b2B72388f18718A5BC7');

const fromAddress = '0x464579c1Dc584361e63548d2024c2db4463EdE48';
const toAddress = '0xD197aAf1Ef2584322F191b2B72388f18718A5BC7';

const privateKey = '';


const sendMoney = async (fromAddress, toAddress, privateKey, amount) => {
  try {
    const nonce = await web3.eth.getTransactionCount(fromAddress);
    const gasEstimate = await web3.eth.estimateGas({ 
        to: toAddress, 
        value: web3.utils.toHex(web3.utils.toWei(amount, 'ether')) 
    });
    const tx = {
      to: toAddress,
      value: web3.utils.toWei(amount, 'ether'),
      gas: gasEstimate,
      gasPrice: await web3.eth.getGasPrice(),
      nonce: nonce,
    };
    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log(`Transaction hash: ${receipt.transactionHash}`);
  } catch (error) {
    console.error(`Error sending money:`, error);
  }
}

sendMoney(fromAddress, toAddress, privateKey, '0.1');


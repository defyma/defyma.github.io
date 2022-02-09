require('dotenv').config();
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');

const data = require('../build/contracts/ThirtySixBearDoodles.json');
const abiArray = data.abi;
const contract_address = process.env.CONTRACT_ADDRESS;
const mnemonic = process.env.MNEMONIC;
const clientURL = process.env.CLIENT_URL;
const provider = new HDWalletProvider(mnemonic, clientURL);
const web3 = new Web3(provider);

async function mintNFT() {
    try {
        const accounts = await web3.eth.getAccounts();

        console.log('contract_address', contract_address);
        console.log('mint_to_address', accounts[0]);

        console.log('Connecting Contract ...');
        const contract = new web3.eth.Contract(abiArray, contract_address);

        console.log('Minting Bulk ...');
        await contract.methods.safeMintBulk(accounts[0], 10).send({from: accounts[0]});

        let x = await contract.methods.totalSupply().call();
        console.log('totalSupply: ', x);

        const balance = await contract.methods.balanceOf(accounts[0]).call();
        const owner = await contract.methods.ownerOf(balance).call();
        console.log('balance: ', balance);
        console.log('owner: ', owner);

        process.exit(0);
    } catch (err) {
        console.log(err);
    }
}

mintNFT().then(() => {
    process.exit();
}).catch(err => {
    console.log(err);
    process.exit();
});

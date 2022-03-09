// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { network } = require("hardhat");
const hre = require("hardhat");
const { NomicLabsHardhatPluginError } = require("hardhat/plugins");

const addresses = {
  mainnet: {
    factory: '0xb7926c0430afb07aa7defde6da862ae0bde767bc',
    arcadedoge: '0xEA071968Faf66BE3cc424102fE9DE2F63BBCD12D',
    wbnb: '0xae13d989dac2f0debff460ac112a837c89baa7cd',
    busd: '0x8301f2213c0eed49a7e28ae4c3e91722919b8b47'
  },
  testnet: {
    factory: '0xb7926c0430afb07aa7defde6da862ae0bde767bc',
    arcadedoge: '0xEA071968Faf66BE3cc424102fE9DE2F63BBCD12D',
    wbnb: '0xae13d989dac2f0debff460ac112a837c89baa7cd',
    busd: '0x8301f2213c0eed49a7e28ae4c3e91722919b8b47'
  }
}

async function main() {
  const signers = await ethers.getSigners();
  // Find deployer signer in signers.
  let deployer;
  signers.forEach((a) => {
    if (a.address === process.env.ADDRESS) {
      deployer = a;
    }
  });
  if (!deployer) {
    throw new Error(`${process.env.ADDRESS} not found in signers!`);
  }

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Network:", network.name);

  await deployNFT();
  await deployExchange();
}

async function deployNFT() {
  console.log('-------------------------');
  console.log('Deploying StoneMusic NFT...');
  if (network.name === "testnet" || network.name === "mainnet") {
    console.log('-------Deploying-----------')
    const nft = await ethers.getContractFactory("StoneMusicNFT");    
    const nftImplementation = await nft.deploy()

    await nftImplementation.deployed();
    console.log("Deployed Address: " + nftImplementation.address);

    console.log('-------Verifying-----------');
    try {
      await run("verify:verify", {
        address: nftImplementation.address,
        constructorArguments: []
      });
    } catch (error) {
      if (error instanceof NomicLabsHardhatPluginError) {
        console.log("Contract source code already verified");
      } else {
        console.error(error);
      }
    }
    console.log('-------Verified-----------');
  }
}

async function deployExchange() {
  console.log('-------------------------');
  console.log('Deploying Exchange...');
  if (network.name === "testnet" || network.name === "mainnet") {
    console.log('-------Deploying-----------')
    const exchange = await ethers.getContractFactory("ExchangeV1");    
    const exchangeImplementation = await exchange.deploy()

    await exchangeImplementation.deployed();
    console.log("Deployed Address: " + exchangeImplementation.address);

    console.log('-------Verifying-----------');
    try {
      await run("verify:verify", {
        address: exchangeImplementation.address,
        constructorArguments: []
      });
    } catch (error) {
      if (error instanceof NomicLabsHardhatPluginError) {
        console.log("Contract source code already verified");
      } else {
        console.error(error);
      }
    }
    console.log('-------Verified-----------');
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// deploying the contract 

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}


const main = async() => {

  const nftContract = await hre.ethers.getContractFactory('CryptoDevsNFT');
  const nftContractDeploy = await nftContract.deploy();
  await nftContractDeploy.wait;
  console.log('address of CryptoDevsNFTDeploy ::: ', nftContractDeploy.target);

  const marketPlaceContract = await hre.ethers.getContractFactory('MarketPlace');
  const marketPlaceContractDeploy = await marketPlaceContract.deploy();
  await marketPlaceContractDeploy.wait;
  console.log('address of CryptoDevsNFTDeploy ::: ', marketPlaceContractDeploy.target);

  const amount = hre.ethers.parseEther("0.1"); // You can change this value from 1 ETH to something else

  const daoContract = await hre.ethers.getContractFactory('CryptoDevsDao');
  const daoContractDeploy = await daoContract.deploy(marketPlaceContractDeploy.target, nftContractDeploy.target, {value: amount});
  await daoContractDeploy.wait;
  console.log('address of CryptoDevsNFTDeploy ::: ', daoContractDeploy.target);

  // verifying the contracts
  // Sleep for 30 seconds to let Etherscan catch up with the deployments
  await sleep(30 * 1000);

  // Verify the NFT Contract
  await hre.run("verify:verify", {
    address: nftContractDeploy.target,
    constructorArguments: [],
  });

  // Verify the Fake Marketplace Contract
  await hre.run("verify:verify", {
    address: marketPlaceContractDeploy.target,
    constructorArguments: [],
  });

  // Verify the DAO Contract
  await hre.run("verify:verify", {
    address: daoContractDeploy.target,
    constructorArguments: [
      marketPlaceContractDeploy.target,
      nftContractDeploy.target,
    ],
  });

}

const runMain = async() => {
  try{
    await main();
    process.exit(0);
  }catch(error){
    console.log('erro -> ',error);
    process.exit(1);
  }
}

runMain();


// address of CryptoDevsNFTDeploy :::  0x82444370D9d5cC4D60D1B03838AE56D7B166A907
// address of marketplace :::  0x11321cfAFDff039371F35b27065C9f8E18915f3f
// address of dao :::  0x9a3Fbe0A378d0022fA1c2D4a8C72D94347Ba5C3b

// https://mumbai.polygonscan.com/address/0x82444370D9d5cC4D60D1B03838AE56D7B166A907#code
// https://mumbai.polygonscan.com/address/0x11321cfAFDff039371F35b27065C9f8E18915f3f#code
// https://mumbai.polygonscan.com/address/0x9a3Fbe0A378d0022fA1c2D4a8C72D94347Ba5C3b#code
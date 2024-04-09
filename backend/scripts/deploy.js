const hre = require("hardhat");

async function main(){
    const signer = await hre.ethers.provider.getSigner();
    console.log("signer : ", signer.address);

    const contract = await hre.ethers.deployContract("Library");
    await contract.waitForDeployment();

    console.log("deployed at :", contract.target);
}

main();
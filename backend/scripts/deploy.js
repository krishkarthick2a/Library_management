const hre = require("hardhat");

async function main(){
    const signer = await hre.ethers.provider.getSigner();
    console.log("signer : ", signer.address);

    const token = await hre.ethers.deployContract("LibraryToken", [signer.address]);
    await token.waitForDeployment();

    const contract = await hre.ethers.deployContract("Library", [token.target]);
    await contract.waitForDeployment();

    console.log("token address : ", token.target);

    console.log("deployed at :", contract.target);
}

main();
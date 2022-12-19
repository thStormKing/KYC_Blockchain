const hre = require("hardhat");

async function main(){
    
    console.log('Starting');
    // Deploy contract customer
    const k = await hre.ethers.getContractFactory("KYC");
    const kyc = await k.deploy();
    await kyc.deployed();

    console.log('Contract customer deployed to: ',kyc.address);
}

main()
.then(()=>process.exit(0))
.catch((error)=>{
    console.error(error);
    process.exit(1);
});
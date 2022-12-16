const hre = require("hardhat");

async function main(){
    
    console.log('Starting');
    // Deploy contract customer
    const cust = await hre.ethers.getContractFactory("customer");
    const customer = await cust.deploy();
    await customer.deployed();

    console.log('Contract customer deployed to: ',customer.address);

    // Deploy contract bank after customer
    const bnk = await hre.ethers.getContractFactory("bank");
    const bank = await bnk.deploy(customer.address);
    await bank.deployed();

    console.log('Contract bank deployed to: ', bank.address);
}

main()
.then(()=>process.exit(0))
.catch((error)=>{
    console.error(error);
    process.exit(1);
});
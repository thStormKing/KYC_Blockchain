const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Bank", function(){
    it("Should add customer through the bank and retrieve the same", async function(){

        const cust = await ethers.getContractFactory("customer");
        const customer = await cust.deploy();
        
        // console.log('Deployed to address: ',customer.address);

        const k = await ethers.getContractFactory("kyc_request");
        const kyc = await k.deploy();

        await customer.deployed();
        await kyc.deployed();


        const bnk = await ethers.getContractFactory("bank");
        const bank = await bnk.deploy(customer.address,kyc.address);
        await bank.deployed();
        // console.log(customer.address);

        const addBanktx = await bank.addCustomer('Bank cust','Bank cust data');
        await addBanktx.wait();

        // console.log(addBanktx);

        const res = await bank.viewCustomer('Bank cust');
        // console.log(res);

        expect(res).to.eql(['Bank cust','Bank cust data',addBanktx.from]);
    });

    it("Should modify customer data",async function(){
        const cust = await ethers.getContractFactory("customer");
        const customer = await cust.deploy();
        
        // console.log('Deployed to address: ',customer.address);

        const k = await ethers.getContractFactory("kyc_request");
        const kyc = await k.deploy();

        await customer.deployed();
        await kyc.deployed();


        const bnk = await ethers.getContractFactory("bank");
        const bank = await bnk.deploy(customer.address,kyc.address);
        await bank.deployed();
        // console.log(customer.address);

        const addBanktx = await bank.addCustomer('Bank cust','Bank cust data');
        await addBanktx.wait();

        const modifyBanktx = await bank.modifyCustomer('Bank cust','New data');
        await modifyBanktx.wait();


        const res = await bank.viewCustomer('Bank cust');
        expect(res).to.eql(['Bank cust','New data',addBanktx.from]);
    });
});
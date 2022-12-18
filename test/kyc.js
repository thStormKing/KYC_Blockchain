const {expect} = require("chai");
const {ethers} = require("hardhat");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

describe("KYC", function(){    
    it("Should add new customer",async function(){
        const k = await ethers.getContractFactory("KYC");
        const kyc = await k.deploy();
        await kyc.deployed();

        let addCustTx = await kyc.addCustomer('Test Customer','Test Customer Data');
        addCustTx.wait();        

        addCustTx = await kyc.addCustomer('Test Customer2','Test Customer Data');
        addCustTx.wait();

        expect(await kyc.viewCustomer('Test Customer2')).to.eql(['Test Customer2','Test Customer Data',addCustTx.from]);
        expect(await kyc.viewCustomer('Test Customer')).to.eql(['Test Customer','Test Customer Data',addCustTx.from]);
    });

    it("Should not add existing customer",async function(){
        const k = await ethers.getContractFactory("KYC");
        const kyc = await k.deploy();
        await kyc.deployed();

        const addCustTx = await kyc.addCustomer('Test Customer','Test Customer Data');
        addCustTx.wait();

        await expect(kyc.addCustomer('Test Customer','Test Customer Data')).to.be.revertedWith("Customer is already present");
    });

    it("Modify existing customer",async function(){
        const k = await ethers.getContractFactory("KYC");
        const kyc = await k.deploy();
        await kyc.deployed();

        const addCustTx = await kyc.addCustomer('Test Customer','Test Customer Data');
        addCustTx.wait();

        let result = await kyc.viewCustomer('Test Customer');
        expect(result).to.eql(['Test Customer','Test Customer Data',addCustTx.from]);

        const modifyCustTx = await kyc.modifyCustomer('Test Customer','New Customer Data');
        modifyCustTx.wait();

        result = await kyc.viewCustomer('Test Customer');
        expect(result).to.eql(['Test Customer','New Customer Data',addCustTx.from]);
    });
    
});
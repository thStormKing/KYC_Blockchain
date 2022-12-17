const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Customer", function(){
    it("Should add a new product", async function(){
        const cust = await ethers.getContractFactory("customer");
        const customer = await cust.deploy();
        await customer.deployed();

        // console.log(customer.signer.getAddress());
        const addCustTx = await customer.addCustomer('Test cust','Test cust data',customer.signer.getAddress());

        await addCustTx.wait();

        // console.log(addCustTx);
        // const res = await customer.viewCustomer('Test cust');

        // console.log(typeof(res));
        expect(await customer.viewCustomer('Test cust')).to.eql(['Test cust','Test cust data',addCustTx.from]);
    });

    it("Should modify customer data", async function(){
        const cust = await ethers.getContractFactory("customer");
        const customer = await cust.deploy();
        await customer.deployed();

        // console.log('Test 2:');
        // console.log(customer.signer.getAddress());
        const addCustTx = await customer.addCustomer('Test cust2','Test cust data',customer.signer.getAddress());
        await addCustTx.wait();

        // console.log(addCustTx);
        // console.log('Cust: ', await customer.viewCustomer('Test cust2'));

        const modifyCustTx = await customer.modifyCustomer('Test cust2','Modified data');
        await modifyCustTx.wait();

        // console.log('Modified Cust: ', await customer.viewCustomer('Test Cust'));

        expect(await customer.viewCustomer('Test cust2')).to.eql(['Test cust2','Modified data',modifyCustTx.from]);
    });
});
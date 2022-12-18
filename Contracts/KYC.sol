// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract customer{
    // Data structure to hold customer information
    struct Customer {
        string username;
        string customerData;
        bool kycStatus;
        uint256 Downvotes;
        uint256 Upvotes;
        address Bank;
    }

    mapping(string=>Customer) public customers;

    // Modifier continue if the customer is not there
    modifier noCustomers(string memory _username){
        require(customers[_username].Bank == address(0),"Customer is already present");
        _;
    }

    // Modifier continue if customer is present
    modifier onlyCustomers(string memory _username){
        require(customers[_username].Bank != address(0),"Customer is not in database. Add customer.");
        _;
    }


    // Function to add customer
    function addCustomer(string memory _username, string memory _customerData, address sender) public noCustomers(_username){        
        // create customer record in struct
        customers[_username].username = _username;
        customers[_username].customerData = _customerData;
        customers[_username].Bank = sender;
        customers[_username].kycStatus = false;
        customers[_username].Upvotes = 0;        
        customers[_username].Downvotes = 0;        
    }

    // Function to view customer
    function viewCustomer(string memory _username) public view onlyCustomers(_username) returns(string memory, string memory, address){
        return (
            customers[_username].username,
            customers[_username].customerData,
            customers[_username].Bank
        );
    }

    // Function to modify customer information
    function modifyCustomer(string memory _username, string memory _customerData) public onlyCustomers(_username){
        customers[_username].customerData = _customerData;
    }

    // Function to upvote customer
    function upVote(string memory _username)public onlyCustomers(_username){
        customers[_username].Upvotes++;
    }
    // Function to downvote customer
    function downVote(string memory _username)public onlyCustomers(_username){
        customers[_username].Downvotes++;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {customer} from "./customer.sol";
import {kyc_request} from "./kyc_request.sol";

contract bank{
    //  Data structure to hold bank information
    struct Bank{
        string name;
        address ethAddress;
        uint256 complaintsReported;
        uint256 KYC_count;
        bool isAllowedToVote;
        string regNumber;
    }

    // Mapping to uniquely identify bank by the address
    mapping(address => Bank) banks;

    // Mapping referring back to the Customer struct
    // Customer object creation
    mapping(string=>customer.Customer) public customers;
    
    // KYC object creation
    mapping(string=>kyc_request.kyc) public kyc;

    // Modifier to check if customer exists
    modifier onlyCustomer(string memory _username){
        require(customers[_username].Bank != address(0),"Customer does not exist");
        _;
    }

    modifier allowVote(){
        require(banks[msg.sender].isAllowedToVote,"You are not allowed to vote");
        _;
    }

    // Create reference customer_ref to contract customer
    customer public customer_ref;
    kyc_request public kyc_ref;

    // Bank constructor
    constructor(customer _addressCustomerContract, kyc_request _addressKycContract){
        customer_ref = _addressCustomerContract;
        kyc_ref = _addressKycContract;
    }

    // Call customer.sol add function
    function addCustomer(string memory _username, string memory _customerData) public{
        address sender = msg.sender;        
        customer_ref.addCustomer(_username,_customerData,sender);
    }

    // Call customer.sol view function
    function viewCustomer(string memory _username) public view returns(string memory, string memory, address){   
        string memory username;
        string memory customerData;
        address bankAddress;

        (username,customerData,bankAddress) = customer_ref.viewCustomer(_username);
        return (username,customerData,bankAddress);
    }

    // Function to modify customer information
    function modifyCustomer(string memory _username, string memory _customerData) public {
        customer_ref.modifyCustomer(_username,_customerData);
    }

    // Function to upvote customer
    function upVote(string memory _username)public allowVote{
        customers[_username].Upvotes++;
    }

    // Function to downvote customer
    function downVote(string memory _username)public allowVote{
        customers[_username].Downvotes++;
    }

    // Add KYC request
    function addRequest(string memory _username, string memory _customerdata) public onlyCustomer(_username){        
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract kyc_request{
    //  Data structure to hold KYC information
    struct kyc{
        string username;
        address bankAddress;
        string customerData;
    }

    // Mapping to point to the struct using username
    mapping(string=>kyc) public KYC;
}
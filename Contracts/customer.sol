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
    function addCustomer(string memory _username, string memory _customerData) public noCustomers(_username){        
        // create customer record in struct
        customers[_username].username = _username;
        customers[_username].customerData = _customerData;
        customers[_username].Bank = msg.sender;
        
    }

    // Function to view customer
    function viewCustomer(string memory _username) public view onlyCustomers(_username) returns(string memory, string memory, address){
        return (
            customers[_username].username,
            customers[_username].customerData,
            customers[_username].Bank
        );
    }
}
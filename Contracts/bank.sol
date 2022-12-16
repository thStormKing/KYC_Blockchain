// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {customer} from "./customer.sol";

contract bank{
    // state variable to hold contract customer.sol
    // contract public customer_ref;

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

    // Create reference customer_ref to contract customer
    customer public customer_ref;
    constructor(customer _addressCustomerContract){
        customer_ref = _addressCustomerContract;
    }

    // Call customer.sol add function
    function addCustomer(string memory _username, string memory _customerData) public{        
        customer_ref.addCustomer(_username,_customerData);
    }

    // Call customer.sol view function
    function viewCustomer(string memory _username) public view{        
        customer_ref.viewCustomer(_username);
    }
}
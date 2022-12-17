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
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract KYC{
    // Data structure to hold customer information
    struct Customer {
        string username;
        string customerData;
        bool kycStatus;
        uint256 Downvotes;
        uint256 Upvotes;
        address Bank;
    }

    //  Data structure to hold bank information
    struct Bank{
        string name;
        address ethAddress;
        uint256 complaintsReported;
        uint256 KYC_count;
        bool isAllowedToVote;
        string regNumber;
    }

    //  Data structure to hold KYC information
    struct KYC_request{
        string username;
        address bankAddress;
        string customerData;
        uint256 kycList_index;
    }

    // Mappings to store and retrieve data from Customer, Bank and KYC_request
    mapping(string=>Customer) customers;
    mapping(address=>Bank) banks;
    mapping(string=>KYC_request) kyc_request;

    // List of KYC_requests
    KYC_request[] kycList;
    
    // Index for Kyc list
    uint256 kyc_index;

    // Counter for number of banks registered
    uint256 bankCounter;

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

    // Modifier to check if a bank can vote
    modifier allowVote(){
        require(banks[msg.sender].isAllowedToVote,"You are not allowed to vote");
        _;
    }

    // Modifier for Bank only operations
    modifier isBank(address bnkAddress){
        require(banks[bnkAddress].ethAddress != address(0),"Only Bank can perform this operation");
        _;
    }

    // Modifier for Admin only operations
    modifier isAdmin(address sender){
        require(admin == sender,"Only Admin can perform this operation");
        _;
    }

    address admin;

    // Constructor to set the admin
    constructor(){
        // Set admin address
        admin = msg.sender;

        // Initialise KYC index and bank counter to 0
        kyc_index = 0;
        bankCounter = 0;
    }

    // Function to add customer
    function addCustomer(string memory _username, string memory _customerData) public noCustomers(_username) isBank(msg.sender){        
        // create customer record in struct
        customers[_username].username = _username;
        customers[_username].customerData = _customerData;
        customers[_username].Bank = msg.sender;
        customers[_username].kycStatus = false;
        customers[_username].Upvotes = 0;        
        customers[_username].Downvotes = 0;        
    }

    // Function to view customer
    function viewCustomer(string memory _username) public view onlyCustomers(_username)  isBank(msg.sender) returns(string memory, string memory, address){
        return (
            customers[_username].username,
            customers[_username].customerData,
            customers[_username].Bank
        );
    }

    // Function to modify customer information
    function modifyCustomer(string memory _username, string memory _customerData) public onlyCustomers(_username) isBank(msg.sender){
        removeRequest(_username);
        Customer storage c = customers[_username];
        c.customerData=_customerData;
        c.Upvotes=0;
        c.Downvotes=0;
        c.Bank=msg.sender;
    }

    // Function to upvote customer
    function upVote(string memory _username) internal onlyCustomers(_username) allowVote isBank(msg.sender){
        customers[_username].Upvotes++;
    }
    // Function to downvote customer
    function downVote(string memory _username) internal onlyCustomers(_username) allowVote isBank(msg.sender){
        customers[_username].Downvotes++;
    }

    // Function to add data to KYC request struct and kyc_list
    function addRequest(string memory _username, string memory _customerdata) public onlyCustomers(_username) isBank(msg.sender){  
        // Add details to the KYC_request struct
        KYC_request storage kyc = kyc_request[_username];
        kyc.username=_username;
        kyc.customerData=_customerdata;
        kyc.bankAddress=msg.sender;
        kyc.kycList_index=kyc_index++;

        // Push kyc request information to kyc request list
        kycList.push(kyc);

        // Increment bank KYC_count
        banks[msg.sender].KYC_count++;
    }

    // Remove KYC request
    function removeRequest(string memory _username) internal onlyCustomers(_username)  isBank(msg.sender){
        // Get the index of the kyc request
        uint256 idx = kyc_request[_username].kycList_index;

        // Delete from KYC requests list. Not requests
        delete kycList[idx];
    }

    // Get Bank Complaints
    function getBankComplaint(address _bnk) public view  isBank(msg.sender) returns(uint256){
        return banks[_bnk].complaintsReported;
    }

    // View Bank Details
    function viewBankDetails(address _bnk) public view  isBank(msg.sender) returns(Bank memory){
        return banks[_bnk];
    }

    // Report Bank
    function reportBank(address _bnkAddress, string memory _name) public {
        Bank storage b = banks[_bnkAddress];
        require(b.ethAddress==_bnkAddress,"Bank address not found");
        string memory b_name = b.name;

        // Convert strings bank name and input name to bytes32 for easy comparison
        bytes32 bankName;
        assembly {
            bankName := mload(add(b_name,32))
        }
        bytes32 inName;
        assembly {
            inName := mload(add(_name,32))
        }

        require(bankName == inName,"Bank name and address do not match");
        b.complaintsReported++;

        validBank(_bnkAddress);
    }

    // Function to modify isAllowedToVote
    function validBank(address _bnkAddress) public {

    }
}
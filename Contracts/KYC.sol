// SPDX-License-Identifier: UNLICENSED
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

    // Modifier to check unique KYC requests
    modifier newKYC(string memory _name){
        require(convertStr(kyc_request[_name].username) != convertStr(_name),"KYC request already exists");
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

    // Modifier to check if bank exists
    modifier bankExists(address bnkAddress){
        require(banks[bnkAddress].ethAddress != address(0),"Bank does not exist");
        _;
    }

    // Modifier for Admin only operations
    modifier isAdmin(address sender){
        require(admin == sender,"Only Admin can perform this operation");
        _;
    }

    // Modifier to avoid duplicate banks
    modifier isNewBank(address _bankAddress){
        require(banks[_bankAddress].ethAddress == address(0),"Bank already exists");
        _;
    }

    // Store admin account address
    address admin;

    // Constructor to set the admin
    constructor(){
        // Set admin address
        admin = msg.sender;

        // Initialise KYC index and bank counter to 0
        kyc_index = 0;
        bankCounter = 0;

        // Adding bank address. This part can be used to automate creation of bank accounts
        addBank("Bank A",0x70997970C51812dc3A010C7d01b50e0d17dc79C8,"reg1");
        addBank("Bank B",0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,"reg2");
        addBank("Bank C",0x90F79bf6EB2c4f870365E785982E1f101E93b906,"reg3");
        addBank("Bank D",0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65,"reg4");
        addBank("Bank E",0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc,"reg5");
    }

    // Helper functions
    // Convert string to bytes32
    function convertStr(string memory _source) internal pure returns (bytes32 res){
        assembly{
            res := mload(add(_source,32))
        }
    }

    // Function to modify isAllowedToVote
    function validBank(address _bnkAddress) internal {
        if(banks[_bnkAddress].complaintsReported > bankCounter/2){
        banks[_bnkAddress].isAllowedToVote = false;
        }
    }

    // Function to validate customer
    function validateCustomer(string memory _name) internal onlyCustomers(_name) {
        if (bankCounter>5){
            if(customers[_name].Downvotes > bankCounter/3){
                customers[_name].kycStatus = false;
            }
        }
        
        if(customers[_name].Upvotes > customers[_name].Downvotes){
            customers[_name].kycStatus = true;
        }
    }

    // Function to Verify submitted KYC
    function verifyKYC(string memory _name) public isBank(msg.sender) onlyCustomers(_name){
        if(convertStr(customers[_name].customerData) != convertStr(kyc_request[_name].customerData)){
            // KYC verification has failed. Downvote customer
            downVote(_name);            
        } else {
            // KYC is valid, upvote the customer        
            upVote(_name);
        }

        if(customers[_name].Upvotes>customers[_name].Downvotes){
            customers[_name].kycStatus = true;
        } else if(customers[_name].Upvotes<customers[_name].Downvotes){
            customers[_name].kycStatus = false;
        }

        validateCustomer(_name);
    }

    // Functions for Bank Interface
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
    function viewCustomer(string memory _username) public view onlyCustomers(_username)  isBank(msg.sender) returns(string memory, string memory, address, bool, uint256,uint256){
        return (
            customers[_username].username,
            customers[_username].customerData,
            customers[_username].Bank,
            customers[_username].kycStatus,
            customers[_username].Upvotes,
            customers[_username].Downvotes
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
        addRequest(_username,_customerData);
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
    function addRequest(string memory _username, string memory _customerdata) public isBank(msg.sender) onlyCustomers(_username) newKYC(_username){  
        // Add details to the KYC_request struct
        KYC_request storage kyc = kyc_request[_username];
        kyc.username=_username;
        kyc.customerData=_customerdata;
        kyc.bankAddress=msg.sender;
        kyc.kycList_index=kyc_index++;

        // Push kyc request information to kyc request list
        kycList.push(kyc);

        // Change customer KYC status to true
        // customers[_username].kycStatus = true;

        // Increment bank KYC_count
        banks[msg.sender].KYC_count++;
    }

    // Remove KYC request
    function removeRequest(string memory _username) public onlyCustomers(_username)  isBank(msg.sender){
        // Get the index of the kyc request
        uint256 idx = kyc_request[_username].kycList_index;

        // Delete from KYC requests list. Not requests
        delete kycList[idx];
    }

    // View KYC Request
    function viewKYC(string memory _username) public view returns(string memory, string memory, address){
        return (
            kyc_request[_username].username,
            kyc_request[_username].customerData,
            kyc_request[_username].bankAddress
        );
    }

    // Get Bank Complaints
    function getBankComplaint(address _bnk) public view returns(uint256){
        return banks[_bnk].complaintsReported;
    }

    // View Bank Details
    function viewBankDetails(address _bnk) public view  returns(Bank memory){
        return banks[_bnk];
    }

    // Report Bank
    function reportBank(address _bnkAddress, string memory _name) public isBank(msg.sender) {
        Bank storage b = banks[_bnkAddress];
        require(b.ethAddress==_bnkAddress,"Bank address not found");
        string memory b_name = b.name;

        require(convertStr(b_name) == convertStr(_name),"Bank name and address do not match");
        b.complaintsReported++;

        validBank(_bnkAddress);
    }

    // Functions for Admin interface
    // Function to Add Bank
    function addBank(string memory _name, address _bankAddress, string memory _regNum) public isAdmin(msg.sender) isNewBank(_bankAddress){
        Bank storage b = banks[_bankAddress];
        b.name = _name;
        b.ethAddress = _bankAddress;
        b.complaintsReported = 0;
        b.KYC_count = 0;
        b.isAllowedToVote = true;
        b.regNumber = _regNum;
        bankCounter++;
    }

    // Funtion to change voting status
    function bank_isAllowedToVote(address _bnkAddress, bool _vote) public isAdmin(msg.sender) isBank(_bnkAddress){
        banks[_bnkAddress].isAllowedToVote = _vote;
    }

    // Funtion to remove bank
    function removeBank(address _bnkAddress) public isAdmin(msg.sender) bankExists(_bnkAddress){
        require(bankCounter>0,"There are no banks in the network. Please create them.");
        delete(banks[_bnkAddress]);
        bankCounter--;
    }
}
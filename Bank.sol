pragma solidity ^0.8.0;

contract dBank{
    
    // state variables
    
    address owner;
    
    event Registered(string _name, uint _balance, address _adrs, uint _trxCounter);
    event Deposited(address _adrs, uint _upBalance, uint _amt);
    
    struct User{
        
        string name;
        uint balance;
        address adrs;
        uint trxCounter;
        
    }
    mapping( address => User ) users;
    
    mapping(address => bool) kyc;
    
    mapping(address => bool) hold;
    // Modifier
    modifier KycTrue(){
        
        require(kyc[msg.sender], "KYC not completed yet.");
        _;
        
        
    }
    modifier checkBalance1(uint amount){
        require(users[msg.sender].balance >=amount,"Balance statement");
        _;
    }
    
    modifier hold1{
        require(!hold[msg.sender],"Your account is on hold");
        _;
    }
    // Constructor
    constructor () public {
        owner = msg.sender;
        require(users[msg.sender].adrs == address(0), "Account already exists");
        User memory user = User("Owner", 0, msg.sender, 0);
        users[msg.sender] = user;
        kyc[msg.sender] = true;
    }
    
    // Functional Declaration
    
    function register(string memory _name) public payable{
        
        require(users[msg.sender].adrs == address(0), "Account already exists");
        require(msg.value >= 2 ether, "You need to deposit atleast 2 ether to open account.");
        User memory user = User(_name, msg.value, msg.sender, 1);
        users[msg.sender] = user;
        emit Registered(_name, msg.value, msg.sender, 1);
        
    }
    
    function getKycStatus() public view returns(bool){
        return kyc[msg.sender];
    }
    
    function completeKyc(address _adrs) public {
        
        require( msg.sender == owner, "You are not the Owner." );
        require( kyc[_adrs] == false, "KYC already completed." );
        kyc[_adrs] = true;
        
    }
    
    function deposit() public KycTrue hold1 payable{
        
        
        
        users[msg.sender].balance += msg.value;
        users[msg.sender].trxCounter += 1;
        emit Deposited(msg.sender, users[msg.sender].balance, msg.value);
        
    }
    
    function withdraw(uint _amt) public KycTrue checkBalance1(_amt) hold1{
        
        
        users[msg.sender].balance -= _amt;
        users[msg.sender].trxCounter += 1;
        payable(msg.sender).transfer(_amt);
        
    }
    
    function transferTo(address payable _to, uint _amt) public KycTrue checkBalance1(_amt) {
        
        
        users[msg.sender].balance -= _amt;
        users[msg.sender].trxCounter += 1;
        _to.transfer(_amt);
        
    }
    
    function closeAccount() public{
        
        require(msg.sender != owner, "Owner cannot close account.");
        uint balance = users[msg.sender].balance;
        delete users[msg.sender];
        kyc[msg.sender] = false;
        payable(msg.sender).transfer(balance);
        
    }
    
    function checkBalance() public  view returns(uint) {
        
        return users[msg.sender].balance;
        
    }
    
    function getDBankBalance() public view returns(uint) {
        
        require(msg.sender == owner, "You are not the owner." );
        return address(this).balance;
    }
    
    function toggleHold(address _userAdrs) public {
        require(msg.sender == owner, "You are not the owner." );
        hold[_userAdrs] = !hold[_userAdrs];
    }
    
    function holdStatus(address _userAdrs) public view returns(bool) {
        return hold[_userAdrs];
    }
    
    receive () external payable {
            deposit();
    }
}

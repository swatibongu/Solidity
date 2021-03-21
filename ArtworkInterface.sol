pragma solidity ^0.8.0;


// ArtworkInterface
// State Variables:-
// 1) Name
// 2) Onwer Name
// 3) hash 
// 4) Type 
// 5) URL
// 6) Owner - Address 
// 7) registeredOn

// Functions:-
// constructor
// checkOwnership
// checkArtwork
// transferOwnership
// biSell (optional)
contract ArtworkInterface{
    
    // State Variables
    string artName;
    string ownerName;
    address owner;
    bytes32 hash;
    uint artType;
    string url;
    uint registeredOn;
    bool onsale;
    uint price;
    // Events
    event VerifyOwner(string _result);
    event VerifyArt(string _result);
    event OwnershipTransfered(address _prev, address _new);
    event GetArtwork(
            string _artName,
            string _ownerName,
            address _owner,
            bytes32 _hash,
            uint _artType,
            string _url,
            uint _registeredOn
            );
    
    // Constructor 
    constructor (
        string memory _artName,
        string memory _ownerName,
        address _owner,
        bytes32 _hash,
        uint _artType,
        string memory _url
        ) {
        artName = _artName;
        ownerName = _ownerName;
        owner = _owner;
        hash = _hash;
        artType = _artType;
        url = _url;
        registeredOn = block.timestamp;
    }
    
    modifier onlyOwner  {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    function checkOwner(address _owner) public {
        require(_owner == owner, "Not the owner");
        emit VerifyOwner("Verified");
    }
    
    function checkArtwork(string memory _art) public {
        require(keccak256(abi.encode(_art)) == hash, "This contract is not for above mentioned art");
        emit VerifyArt("Verified");
        
    }
    
    function transferOwnership(address _owner) public onlyOwner{
        owner = _owner;
        emit OwnershipTransfered(msg.sender, owner);
    }
    
    function getArtwork() public{
        emit GetArtwork(artName, ownerName, owner, hash, artType, url, registeredOn);
    }
    
     function BuyArtwork(address owner_prev) public payable{
     require(onsale ="not onsale");
     require(onsale == price);
     owner_prev = new_owner;
     address = msg.sender;
     
    }
    
   function togglesetprice(uint _price) public onlyOwner{
        price = _price;
   }
   
   function toggleOnSale() public onlyOwner{
       onsale = !onsale;
   }

}

// ArtworkManager
// State Variables:-
// 1) mapping for mapping user to deployed ArtworkInterface Contract
// 2) Enum => for different types of Artwork 

// Functions:-
// 1) Deploy Artwork Interface Instance && Map user to it's artwork.
// 2) User can get Artworks

contract ArtworkManager {
    
    // State Variables
    mapping(address => ArtworkInterface[]) userArt;
    mapping(bytes32 => address) artOwners;
    mapping(address => bool) bisell;
    // Events
    event NewArtRegistration(address, string);
    event ArtRegistered(address _artAdrs, address _owner, string _art);
    
    // Modifiers
    modifier checkIfRegistered(string memory _art){
        require(artOwners[keccak256(abi.encode(_art))]==address(0), "Already Registered");
        _;
    }
    
    // Functions
    function registerArtwork(string memory _art ,string memory _artUrl, string memory _owner, uint _type) public checkIfRegistered(_artUrl) {
        emit NewArtRegistration(msg.sender, _artUrl);
        bytes32 hash = keccak256(abi.encode(_artUrl));
        ArtworkInterface art = new ArtworkInterface(_art,
        _owner,
        msg.sender,
        hash,
        _type,
        _artUrl);
        userArt[msg.sender].push(art);
        artOwners[hash] = msg.sender;
        emit ArtRegistered(address(art), msg.sender, _art);
    }
    
    function getArtworkByOwner(address _owner) public view returns(ArtworkInterface[] memory) {
        return userArt[_owner];
    }
    
    function getOwnerByArtwork(string memory _art) public view returns(address _owner){
        return artOwners[keccak256(abi.encode(_art))];
    }
    
    function isRegistered(string memory _art) public view checkIfRegistered(_art){}

   
}

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Auction is Ownable {
    
    enum PlayerState{Registered, onAuction, Auctioned}
    
    PlayerState state;
    
    // Player Details
    uint public player_id;
    string public player_name;
    uint public player_age;
    string public player_type;
    
    // Player Details made by Auction Manager
    uint public rating;
    uint public base_price;
    uint public max_bid_count;
    
    uint public bid_counter;
    
    address public team_owner;
    
    bool isActive;

    uint highestBid;
    address highestBidder;

    mapping(address=>uint)  bidders;
    address[]  bidderArray;

    event PlayerContractCreated(string _name, string _type, uint _rating);
    
    event auctionStarted(address _auction, string _player_name);
    event HighBidAlert(uint _bid, address _bidder);
    event bidWithdrawn(uint _bid, address _bidder);
    event newTeam(address _new);
    event auctionCanceled(address _auction, string _player_name);
    event auctionEnded(address _auction, string _player_name);
    event setTeam(address team);

    constructor (
        uint _player_id,
        string memory _player_name,
        uint _player_age,
        string memory _player_type,
        uint _rating,
        uint _base_price,
        uint _max_bid_count
        )  {
            
        player_id = _player_id;
        player_age =  _player_age;
        player_type = _player_type;
        rating = _rating;
        base_price = (_base_price*(1 ether))/100;
        max_bid_count = _max_bid_count;
        player_name = _player_name;
        
        state = PlayerState.Registered;
        transferOwnership(tx.origin);
        emit PlayerContractCreated(player_name, player_type, rating);
        
    }

    function startAuction() public onlyOwner{
        isActive=true;
        state = PlayerState.onAuction;
        emit auctionStarted(address(this),player_name);
    }

    function bid() public payable{
        assert(isActive);
        require(msg.sender!=owner(),"Owner cannot bid");
        require(bidders[msg.sender]+msg.value>base_price,"Bid Value less than base price");
        require(bidders[msg.sender]+msg.value>highestBid,"Unnecessary Bid");
        bidders[msg.sender]+=msg.value;
        bidderArray.push(msg.sender);
        highestBid=bidders[msg.sender];
        highestBidder=msg.sender;
        bid_counter++;
        if(bid_counter == max_bid_count) {
            _stopAuction();
        }
        emit HighBidAlert(highestBid,highestBidder);
    }

    function withdrawBid() public{
        assert(bidders[msg.sender]!=0 && highestBid!=bidders[msg.sender]);
        uint amount = bidders[msg.sender];
        bidders[msg.sender]=0;
        emit bidWithdrawn(amount,msg.sender);
        bid_counter--;
        payable(msg.sender).transfer(amount);
    }

    function cancelAuction() public onlyOwner{
        isActive=false;
        state = PlayerState.Auctioned;
        for(uint i; i<bidderArray.length; i++){
            if(bidders[bidderArray[i]]!=0){
                payable(bidderArray[i]).transfer(bidders[bidderArray[i]]);
            }
        }
        emit auctionCanceled(address(this),player_name);
        selfdestruct(payable(owner()));
    }
    
    function _stopAuction() private{
        isActive=false;
        transferToTeam(highestBidder);
        state = PlayerState.Auctioned;
        emit setTeam(highestBidder);
        for(uint i; i<bidderArray.length; i++){
            if(bidderArray[i]!=highestBidder){
                payable(bidderArray[i]).transfer(bidders[bidderArray[i]]);
            }
        }
        _endAuction();
    }
    
    function _endAuction() private{
        assert(!isActive);
        require(team_owner==highestBidder,"Ownership haven't changed yet");
        emit auctionEnded(address(this),player_name);
        emit newTeam(highestBidder);
        selfdestruct(payable(owner()));
    }

    function stopAuction() public onlyOwner{
        _stopAuction();
    }


    function endAuction() public onlyOwner{
        _endAuction();
    }

    function getBalance() view public returns(uint){
        return payable(address(this)).balance;
    }

    function getHighestBid() view public returns(uint,address){
        return (highestBid,highestBidder);
    }
    
    function getBasePrice() view public returns(uint){
        return base_price;
    }

    function getPlayerOnAuction() view public returns(string memory _player_name, string memory _player_type, uint _base_price, uint _rating){
        return (player_name, player_type, base_price, rating);
    }

    function getMyBid() view public returns(uint _bid){
        return bidders[msg.sender];
    }

    function ping() public view returns(bool){
        return isActive;
    }
    
    function transferToTeam(address _team_owner) private {
        team_owner = _team_owner;
    }
    
    receive () external payable{
        bid();
    }

}

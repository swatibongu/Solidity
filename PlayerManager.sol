pragma solidity ^0.8.0;

import './Auction.sol';

contract PlayerManager{

    //add events to notify the client

    mapping(uint=>Auction) players;
    uint counter;

    event auctionStatus(string status, address _auction);
    event PlayerRegistered(Auction , address);
    
    function registerPlayer( string memory _player_name,uint _player_age, string memory _player_type) public {
        counter++;
        uint rating = uint(keccak256(abi.encode(_player_name)))%100;
        uint base_price = rating / 10;
        uint max_bid_counter = ((rating-1)%10)+1;
        Auction player = new Auction(counter, _player_name, _player_age, _player_type, rating, base_price, max_bid_counter);
        players[counter]=player;
        emit PlayerRegistered(player, address(player));
    }
}

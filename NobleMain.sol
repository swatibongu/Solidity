pragma solidity 0.8.0;


import './NobelToken';
import './OpenNFT.sol'
contract NobelMain{
    OpenNFT open;
    NobelToken nobel;
    constructor(
        address _open,
        uint _initial_supply
        ){
            open = OpenNFT(_open);
            nobel = new NobelToken(_initial_supply);
            
        }
        function getOpenBalances(address _checker) public returns(uint){
            return open.balanceOf(_checker);
            
        }
        function getNobelBalances(address _checker)public returns(uint){
            return nobel.balanceOf(_checker);
        }
}

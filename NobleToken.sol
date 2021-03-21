pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract NobelToken is ERC20PresetMinterPauser{
    uint public constant cooldown_after_mint = 20;
    uint public constant allowance_per_mint = 10000;
    uint internal last_mint_timestamp;
    constructor(
        uint _initial_supply
        
        )
        public ERC20PresetMinterPauser("NobelToken","NBT")
        {   last_mint_timestamp = block.timestamp;
            _mint(msg.sender, _initial_supply);
            
            
        }
        
        function decimals()public view override returns(uint8){
            return 0;
        }
        function mint(address to,uint256 amount)public override{
            
            require(hasRole(MINTER_ROLE,_msgSender()),
                    "ERC20PresetMinterPauser:must have minter role to mint");
                _mint_(to,amount);
        }
        function _mint_(address to, uint amount) internal{
            require(amount <=allowance_per_mint , "NobelToken:Exceeds Allowance");
           last_mint_timestamp = block.timestamp;
            _mint(to,amount);
           
        }
}

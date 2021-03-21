pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Strings.sol';

contract ProductManagement{
    
    using Strings for *;
    
    enum Product_Type{CAR,WHEEL,ENGINE,CHASIS,GEARS}
    enum Grade{A,B,C,D}
    
    struct Product{
        string serial;
        address brand;
        address manufacturer;
        Product_Type product_type;
        uint manufacture_date; 
        uint location;
        Grade grade;
        uint price;
        mapping(uint=>bytes32) parts;
        uint part_counter;
        mapping(uint=>address) owners;
        uint owner_counter;
    }
    
    mapping(bytes32=>Product) public products;
    mapping(bytes32=>address) public product_owners;
    
    mapping(uint=>bytes32) public hashes;
    uint public hash_counter;
    
    event ProductCreated(uint _location, uint _price, string _serial, address _brand, uint _grade, uint _product_type, uint total_parts);
    event ProductOwnershipTransfered(address prev_owner, address new_owner);
    
    // Functional Declarations
    
    function createProduct(
            uint _location,
            uint _price ,
            uint[] memory _parts,
            string memory _serial,
            address _brand,
            uint8 _grade,
            uint8 _product_type
            ) public {
        bytes32 uuid = hash(_serial, _brand, _product_type.toString());
        
        require(products[uuid].manufacturer == address(0),"Product Already Exists");
        
        uint j;
        if(_parts.length!=0){
            for(uint i; i<_parts.length;i++){
                require(products[hashes[_parts[i]]].manufacturer != address(0), "Product do not exist");
            }
            for( j ; j<_parts.length;j++){
                products[uuid].parts[j] = hashes[_parts[j]];
                product_owners[hashes[_parts[j]]] = _brand;
            }
        }
        
        products[uuid].serial = _serial;
        products[uuid].brand = _brand;
        products[uuid].manufacturer = msg.sender;
        products[uuid].manufacture_date = block.timestamp;
        products[uuid].product_type = Product_Type(_product_type);
        products[uuid].location = _location;
        products[uuid].grade = Grade(_grade);
        products[uuid].price = _price;
        products[uuid].owners[1] = _brand;
        products[uuid].owner_counter = 1;
        products[uuid].part_counter = j;
        
        
        hash_counter++;
        hashes[hash_counter] = uuid;
        
        product_owners[uuid] = _brand;
    }
    
    function getProductHash(string memory _serial,address _brand, uint8 _product_type) public pure returns(bytes32){
        return hash( _serial, _brand, _product_type.toString());
    }
    
    function transferOwnership(address _new_owner,string memory _serial,address _brand, uint8 _product_type) public {
        bytes32 uuid = hash(_serial, _brand, _product_type.toString());
        require(product_owners[uuid] == msg.sender, "You are not the Owner");
        require(product_owners[uuid] != _new_owner, "New owner is already current owner");
        product_owners[uuid] = _new_owner;
        products[ uuid ].owners[ products[uuid].owner_counter++ ] = _new_owner;
        emit ProductOwnershipTransfered( products[uuid].owners[products[uuid].owner_counter-1] , _new_owner );
    }
    
    function hash(string memory s1, address s2, string memory s3) private pure returns (bytes32){
        //First, get all values as bytes
        bytes memory b_s1 = bytes(s1);
        bytes20 b_s2 = bytes20(s2);
        bytes memory b_s3 = bytes(s3);

        //Then calculate and reserve a space for the full string
        string memory s_full = new string(b_s1.length + b_s2.length + b_s3.length);
        bytes memory b_full = bytes(s_full);
        uint j = 0;
        uint i;
        for(i = 0; i < b_s1.length; i++){
            b_full[j++] = b_s1[i];
        }
        for(i = 0; i < b_s2.length; i++){
            b_full[j++] = b_s2[i];
        }
        for(i = 0; i < b_s3.length; i++){
            b_full[j++] = b_s3[i];
        }

        //Hash the result and return
        return keccak256(b_full);
    }
    
}

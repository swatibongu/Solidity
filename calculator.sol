//Defining version
pragma solidity ^0.8.0;

//Can be considered as class
contract calc{
        
        int public result = 0;
        uint public expRes=0;
        
        
        //functions
        //function funcName(arguments) accessModifiers {
            //
        
        function sub(int i) public {
           result = result - i;
        }
        
        function add(int i) public {
           result = result + i ;
        }
        function mul(int i) public {
            result = result * i;
        }
        function div(int i) public {
            result = result / i;
            
        }
        function getdivresult() public view returns(int res,int8 dec){
            return(res,-2);
        }
       function exp(uint a, uint8 power) public {
        expRes = a**power;
    }
       
}

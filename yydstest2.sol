pragma solidity ^0.8;

contract yydstest2 {
    string public name = "yydstest2";
    string public symbol = "YT2";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100 * 10 ** 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);


    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowance;


    constructor() {
        balances[msg.sender]=totalSupply;
    }

    function balanceof(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns (bool){
        require(balanceof(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceof(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low ');

        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }





}

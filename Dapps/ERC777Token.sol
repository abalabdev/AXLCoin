pragma solidity ^0.4.25;


interface ERC777Token {
   // function name() public constant returns (string);
    //function symbol() public constant returns (string);
   // function totalSupply() public constant returns (uint256);
    function granularity() public constant returns (uint256);
   // function balanceOf(address owner) public constant returns (uint256);

    function send(address to, uint256 amount) public;
    function send(address to, uint256 amount, bytes userData) public;

    function authorizeOperator(address operator) public;
    function revokeOperator(address operator) public;
    function isOperatorFor(address operator, address tokenHolder) public constant returns (bool);
    function operatorSend(address from, address to, uint256 amount, bytes userData, bytes operatorData) public;
    event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    function tokenFallback(address _from, uint _value, bytes _data);
    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes userData,
        bytes operatorData
    ); // solhint-disable-next-line separate-by-one-line-in-contract
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes userData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

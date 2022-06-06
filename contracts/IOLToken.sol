pragma solidity ^0.8.0;

//import "openzeppelin-contracts/token/ERC20/ERC20.sol";
//import "openzeppelin-contracts/token/ERC20/TokenTimelock.sol";
import "openzeppelin-contracts/token/ERC20/ERC20Pausable.sol";


contract IOLToken is ERC20Pausable{

    address owner;

    constructor(uint256 initialSupply, string memory _name, string memory _symbol)
        ERC20(_name,_symbol)
        public
    {
        owner=msg.sender;
        _mint(msg.sender, initialSupply);
    }



}
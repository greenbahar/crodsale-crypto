// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "openzeppelin-contracts/token/ERC20/ERC20.sol";
// import "openzeppelin-contracts/token/ERC20/SafeERC20.sol";
import "./buyToken.sol";
// import "zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";


contract Presale is BuyToken{
    
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    address owner;
    
    constructor() public{
        owner = msg.sender;
    }

    //only buy token with one of the following currencies
    enum TokenPair {ETH, USDC, DAI}

    //start date-end date
    struct Items{
        uint      startDate;          //sale interval=1 week bydefault
        uint      endDate;
        uint256   aggregatedAmount;
        bytes     token1;
        bytes     token2;
        bool      failFlag;           //after that => WITHDRAW DEPOSITS
        uint      rate;
        address payable  wallet;
        ERC20     tokenAddress;
    }


    mapping(address=>bytes) PresaleOwner;                     //address of the creator and token name
    mapping(bytes=>Items) Ledger;                              //token name and details about presale
    mapping(address=>mapping(bytes=>uint))  ByersBalance;     //buyer:token:amount


    // create a presale
    function createPresale(
        bytes memory tokenName,
        bytes memory _TokenPair,
        uint256 _rate,
        address payable _wallet,
        ERC20 _token)
        public
    {
        require(_rate > 0);
        require(_wallet != address(0));
        require(address(_token) != address(0));
        require(_isTokenValid(tokenName,_TokenPair));

        PresaleOwner[msg.sender]=tokenName;
        Ledger[tokenName].startDate = block.timestamp;
        Ledger[tokenName].endDate = Ledger[tokenName].startDate + 30 days;
        Ledger[tokenName].aggregatedAmount = 0;
        Ledger[tokenName].token1 = tokenName;
        Ledger[tokenName].token2 = _TokenPair;
        Ledger[tokenName].failFlag = false;
        Ledger[tokenName].rate = _rate;
        Ledger[tokenName].wallet = _wallet;
        Ledger[tokenName].tokenAddress = _token;
    }

    function _isTokenValid(bytes memory tokenName, bytes memory _TokenPair) internal returns(bool){
        
        if (keccak256(abi.encodePacked(_TokenPair)) == keccak256(abi.encodePacked('ETH'))){
            Ledger[tokenName].token2 = bytes('ETH');
            return true;
        }
        else if (keccak256(abi.encodePacked(_TokenPair)) == keccak256(abi.encodePacked('USDC'))){
            Ledger[tokenName].token2 = bytes('USDC');
            return true;
        } 
        else if (keccak256(abi.encodePacked(_TokenPair)) == keccak256(abi.encodePacked('DAI'))){
            Ledger[tokenName].token2 = bytes('DAI');
            return true;
        }
        else{
            return false;   
        }
    }
    
    
    // buy tokenName by ether
    function purchaseToken(bytes memory tokenName) public payable{
        
        if (Ledger[tokenName].endDate < block.timestamp){
            Ledger[tokenName].failFlag = true;
            //withdraw deposits
            revert('presale is already ended.');
        }
        
        require(Ledger[tokenName].failFlag==true);
        
        address payable wallet = Ledger[tokenName].wallet;
        uint256 rate = Ledger[tokenName].rate;
        ERC20 token = Ledger[tokenName].tokenAddress;
        
        super.buyTokens(wallet, rate, token);
        
        Ledger[tokenName].aggregatedAmount += msg.value;
        
        
    }
    

    modifier onlyAdmin(){
        require(msg.sender == owner);
        _;
    }

    function forceFailByAdmin(bytes memory tokenName) public onlyAdmin(){
        
        Ledger[tokenName].failFlag = true;
    }
    
    
    modifier onlyFailPresale(bytes memory tokenName){
        require(Ledger[tokenName].failFlag == true);
        _;
    }
    
    function withdrawDeposit(bytes memory tokenName) public onlyFailPresale(tokenName){
      uint amount = ByersBalance[msg.sender][tokenName];
      ByersBalance[msg.sender][tokenName] = 0;
      payable(msg.sender).transfer(amount);
   }
}

//TODO: add liquidity on presale
//TODO: create a pair on uniswap on successful presale
    

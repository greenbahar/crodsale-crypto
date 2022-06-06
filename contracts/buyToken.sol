// SPDX-License-Identifier: MIT

pragma solidity >=0.4.24;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/token/ERC20/SafeERC20.sol";


contract BuyToken {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;


  event TokenPurchase(
    address indexed purchaser,
    uint256 value,
    uint256 amount
  );


  fallback () external {
    revert();
  }


  function buyTokens(address payable wallet, uint256 rate, ERC20 token) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount, rate);

    _processPurchase(token, tokens);
    emit TokenPurchase(
      msg.sender,
    //   _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(msg.sender, weiAmount);

    _forwardFunds(wallet);
    _postValidatePurchase(weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------


  function _preValidatePurchase(
    uint256 _weiAmount
  )
    internal
  {
    require(msg.sender != address(0));
    require(_weiAmount != 0);
  }


  function _postValidatePurchase(
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }


  function _deliverTokens(
    ERC20 token,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(msg.sender, _tokenAmount);
  }


  function _processPurchase(
    ERC20 token,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(token,_tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount, uint256 rate)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds(address payable wallet) internal {
    wallet.transfer(msg.value);
  }
}

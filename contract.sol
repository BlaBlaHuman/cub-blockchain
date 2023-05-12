// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract ETH_exchange {

    address private owner;

    /*
        stores supported tokens

        allowedTokens[token] == true // token is supported
        allowedTokens[token] == true // token is not supported
    */
    mapping(IERC20 => bool) private allowedTokens;

    /*
        exchangeRate represents costs of different tokens in wei
    */
    mapping (IERC20 => uint) private exchangeRate;


    /*
        constructor() requires some initial wei amount to be able to buy tokens
    */
    constructor() payable {
        owner = msg.sender;
        require(msg.value > 0, "Initial amount must be greater than zero"); 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation");
        _;
    }

    modifier tokenSupported(IERC20 _token) {
        require(allowedTokens[_token], "This token is not supported");
        _;
    }

    /*
        You can add and remove tokens with these two methods
    */
    function allowToken(address _token) onlyOwner external {
        allowedTokens[IERC20(_token)] = true;
    }

    function removeToken(address _token) onlyOwner external {
        allowedTokens[IERC20(_token)] = false;
    }


    /*
        An external method to check whether a token is allowed
    */
    function isAllowed(address _token) external view returns (bool) {
        return allowedTokens[IERC20(_token)];
    }


    /*
        An external method to get an exchange rate for a token
    */
    function getExchangeRate(address _token) tokenSupported(IERC20(_token)) external view returns (uint) {
        return exchangeRate[IERC20(_token)];
    }


    /*
        Allowes the owner to change the exchange rate for any token
    */
    function changeExchangeRate(address _token, uint _amount) onlyOwner tokenSupported(IERC20(_token)) external {
        exchangeRate[IERC20(_token)] = _amount;
    }

    /*
        Allows to deposit wei to the contract
    */
    function deposit() external payable {}

    /*
        Allows to deposit tokens to the contract
    */
    function depositToken(address _token, uint _amount) tokenSupported(IERC20(_token)) external {
        require(_amount > 0, "Depositing 0 tokens is not allowed");

        require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "The contract cannot spend the defined amount of tokens from the caller's balance");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Unable to transfer tokens");
    }  


    /*
        Allows withdrawing wei from the contract
    */
    function withdraw(address _to, uint _amount) onlyOwner external {
        require(payable(_to).send(_amount), "Unable to transfer wei");
    }

    /*
        Allows withdrawing tokens from the contract
    */
    function withdrawTokens(address _token, address _to, uint _amount) onlyOwner external {
        require(IERC20(_token).transferFrom(address(this), _to, _amount), "Unable to transfer tokens to the buyer");
    }


    /*
        Buys `_amount` tokens `_token` from the caller
    */
    function sellToken(address _token, uint _amount) tokenSupported(IERC20(_token)) external {
        require(_amount > 0, "Selling 0 tokens is not allowed");
        
        /*
            To sell tokens user has to allow the contract to spend tokens from their balance
        */
        require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "The contract cannot spend the defined amount of tokens from the caller's balance");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Unable to transfer tokens from the seller");

        require(address(this).balance >= exchangeRate[IERC20(_token)] * _amount, "Not enough wei to buy tokens");
        require(payable(msg.sender).send(exchangeRate[IERC20(_token)] * _amount), "Unable to transfer wei to the seller");
    }


    /*
        Sells tokens `_token` to the caller. The amount is defined by transfered wei and the exchange rate
    */
    function buyToken(address _token) tokenSupported(IERC20(_token)) external payable {
        require(msg.value > 0, "0 wei transfered");

        if (IERC20(_token).balanceOf(address(this)) >= msg.value / exchangeRate[IERC20(_token)]) {
            /*
                Case when the contract is able to sell the needed amount of tokens to the buyer
            */
            require(IERC20(_token).transferFrom(address(this), msg.sender, msg.value / exchangeRate[IERC20(_token)]), "Unable to transfer tokens to the buyer");
        }
        else {
            /*
                Case when there are not enough tokens to sell
                The contract needs to send the change back to the buyer
            */
            uint diff = msg.value - IERC20(_token).balanceOf(address(this)) * exchangeRate[IERC20(_token)];
            require(payable(msg.sender).send(diff), "Unable to pay the change");
            require(IERC20(_token).transferFrom(address(this), msg.sender, IERC20(_token).balanceOf(address(this))), "Unable to transfer tokens to the buyer");

        }

    }

    /*
        Allows to destroy the contract. Unfortunately, all tokens (except for ETH) will be lost, so you have to call `withdrawTokens` first.
        
        Note: 
        It is said that `selfdestruct` is deprecated, but I haven't found any other function with the same purpose.
    */

    function destroySmartContract(address payable _to) onlyOwner public {
        selfdestruct(_to);
    }
    
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract ETH_exchange {

    address private owner;
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

    function allowToken(address _token) onlyOwner external {
        allowedTokens[IERC20(_token)] = true;
    }

    function isAllowed(address _token) external view returns (bool) {
        return allowedTokens[IERC20(_token)];
    }

    function getExchangeRate(address _token) tokenSupported(IERC20(_token)) external view returns (uint) {
        return exchangeRate[IERC20(_token)];
    }

    function changeExchangeRate(address _token, uint _amount) onlyOwner tokenSupported(IERC20(_token)) external {
        exchangeRate[IERC20(_token)] = _amount;
    }

    function deposit() external payable {}

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
    
}

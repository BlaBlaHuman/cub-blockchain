// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract ETH_exchange {

    address private owner;
    mapping(IERC20 => bool) private allowedTokens;
    mapping (IERC20 => uint) private exchangeRate;

    constructor() payable {
        owner = msg.sender;
        require(msg.value > 0, "Initial amount must be greater than zero"); 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation");
        _;
    }

    function allowToken(address _token) onlyOwner external {
        allowedTokens[IERC20(_token)] = true;
    }

    function isAllowed(address _token) external view returns (bool) {
        return allowedTokens[IERC20(_token)];
    }

    function getExchangeRate(address _token) external view returns (uint) {
        require(allowedTokens[IERC20(_token)], "This token is not supported");
        return exchangeRate[IERC20(_token)];
    }

    function getBalance(address _token) external view returns (uint) {
        require(allowedTokens[IERC20(_token)], "This token is not supported");
        return IERC20(_token).balanceOf(address(this));
    }

    function changeExchangeRate(address _token, uint _amount) onlyOwner external {
        require(allowedTokens[IERC20(_token)], "This token is not supported");
        exchangeRate[IERC20(_token)] = _amount;
    }

    function sellToken(address _token, uint _amount) public {
        require(_amount > 0, "You are trying to send 0 tokens");
        require(allowedTokens[IERC20(_token)], "This token is not supported");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transaction was not successful");
        require(payable(msg.sender).send(exchangeRate[IERC20(_token)] * _amount), "Transaction was not successful");
    }

    function buyToken(address _token, uint _amount) public payable {
        require(_amount > 0, "You are trying to buy 0 tokens");
        require(allowedTokens[IERC20(_token)], "This token is not supported");
        require(exchangeRate[IERC20(_token)] * _amount >= msg.value);
        require(IERC20(_token).transferFrom(address(this), msg.sender, _amount), "Transaction was not successful");
    }
}

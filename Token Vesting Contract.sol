// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenVesting {
    address public admin;
    address public token;
    
    mapping(address => uint256) public vestingStart;
    mapping(address => uint256) public vestingAmount;

    event TokensVested(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);

    constructor(address _token) {
        admin = msg.sender;
        token = _token;
    }

    function startVesting(address user, uint256 amount) external {
        require(msg.sender == admin, "Only admin can start vesting");
        vestingStart[user] = block.timestamp;
        vestingAmount[user] = amount;
        emit TokensVested(user, amount);
    }

    function claimTokens() external {
        uint256 vestedAmount = calculateVestedAmount(msg.sender);
        require(vestedAmount > 0, "No tokens vested or claimable");
        vestingAmount[msg.sender] -= vestedAmount;
        IERC20(token).transfer(msg.sender, vestedAmount);
        emit TokensClaimed(msg.sender, vestedAmount);
    }

    function calculateVestedAmount(address user) public view returns (uint256) {
        uint256 timePassed = block.timestamp - vestingStart[user];
        uint256 totalVestingPeriod = 365 days;  // example vesting period
        uint256 totalAmount = vestingAmount[user];
        return (totalAmount * timePassed) / totalVestingPeriod;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}
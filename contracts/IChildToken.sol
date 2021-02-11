pragma solidity 0.7.5;

interface IChildToken {
    function deposit(address user, bytes calldata depositData) external;
}
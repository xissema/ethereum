// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ChiToken {
    function freeFromUpTo(address from, uint256 value) external;
}
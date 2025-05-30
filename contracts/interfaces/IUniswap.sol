// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IUniswapPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function sync() external;
    function mint(address to) external returns (uint liquidity);
}

interface IUniswapFactory {
    function getPair(address, address) external view returns (address);
}
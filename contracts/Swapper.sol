// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IUniswap.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


library Swapper {

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    function pairFor(address factory, address token0, address token1) internal view returns (address pair) {
        pair = IUniswapFactory(factory).getPair(token0, token1);
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1,) = IUniswapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 9975;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 10000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountsOut(address factory, uint256 amountIn, address[] memory path) internal view returns (uint256[] memory amounts) {
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = (amountA * reserveB) / reserveA;
    }

    function swap(address factory, address[] memory path, address _to) internal returns (uint256 amountOutput) {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = input < output ? (input, output) : (output, input);
            IUniswapPair pair = IUniswapPair(pairFor(factory, input, output));
            uint amountInput;
            {
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
            amountOutput = Swapper.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));

        }
    }


    function _getAddLiquidityQuotes(
        IUniswapPair pair,
        uint amountADesired,
        uint amountBDesired
    ) internal view returns (uint256 amountA, uint256 amountB) {
        (uint reserveA, uint reserveB,) = pair.getReserves();

        uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
        if (amountBOptimal <= amountBDesired) {
            (amountA, amountB) = (amountADesired, amountBOptimal);
        } else {
            uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
            assert(amountAOptimal <= amountADesired);
            (amountA, amountB) = (amountAOptimal, amountBDesired);
        }
    }

    function addLiquidity(
        address factory,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        address to
    ) public returns (uint256 liquidity){
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        (uint amountA, uint amountB) = token0 == tokenA ? (amountADesired, amountBDesired) : (amountBDesired, amountADesired);
        IUniswapPair pair = IUniswapPair(pairFor(factory, token0, token1));

        IERC20(tokenA).transfer(address(pair), amountA);
        IERC20(tokenB).transfer(address(pair), amountB);
        
        liquidity = pair.mint(to);
    }
}
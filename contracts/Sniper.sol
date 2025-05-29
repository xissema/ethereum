// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Swapper.sol";
import "./Refund.sol";
import "./interfaces/IUniswap.sol";
import "./interfaces/Chi.sol";


// 2 задание было делать лень, sorry
contract HSniper is Ownable, Pausable, Refund {

    address public immutable factory;
    ChiToken private immutable chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    mapping(address => bool) private purchased;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function hswap(uint256 amountIn, address[] calldata path, uint256 minLiquidity, bool safeBuy, bool honeyCheck, bool useChi) external {
        uint256 gasStart = gasleft();

        uint256 pathLength = path.length;
        require(!purchased[path[pathLength-1]], "HSniper: Token was already acquired");

        (uint256 reserveA, ) = Swapper.getReserves(factory, path[pathLength-2], path[pathLength-1]);

        require(reserveA >= minLiquidity, "Swapper: Insufficient liquidity");

        if (honeyCheck) {
            uint256 amountInCheck = amountIn * 1 / 100;
            amountIn = amountIn * 99 / 100;

            require(
                _buy(amountInCheck, path),
                "HSniper: Failed to honeycheck"
            );

            address[] memory reversedPath = reverseArray(path);

            uint256 balanceTarget = IERC20(path[pathLength-1]).balanceOf(address(this)); // checks token target balance after buy
            require(
                balanceTarget > 0,
                "HSniper: Failed to honeycheck"
            );
            
            _buy(
                balanceTarget,
                reversedPath
            );
        }

        uint256 balance = IERC20(path[0]).balanceOf(address(this)); // Pancake: K
        if (balance < amountIn) {
            amountIn = balance;
        }
        
        IERC20(path[0]).transfer(
            Swapper.pairFor(factory, path[0], path[1]),
            amountIn
        );

        address to = safeBuy ? owner(): address(this);

        Swapper.swap(
            factory,
            path,
            to
        );
        
        purchased[path[pathLength-1]] = true;

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            payable(owner()).transfer(ethBalance);
        }


        if (!useChi) {
            return;
        }

        uint256 initialGas = 21000 + 16 * msg.data.length;
        uint256 gasSpent = initialGas + gasStart - gasleft();
        uint256 freeUpValue = (gasSpent + 14154) / 41947;

        chi.freeFromUpTo(
            owner(),
            freeUpValue
        );
    }

    function clearPurchased(address _token) external onlyOwner {
        purchased[_token] = false;
    }

    function _buy(uint256 amountIn, address[] memory path) internal returns (bool) {
        address pair = Swapper.pairFor(factory, path[1], path[0]);
        IERC20(path[0]).transfer(
            pair,
            amountIn
        );

        Swapper.swap(
            factory,
            path,
            address(this)
        );

        IUniswapPair(pair).sync();
        
        return true;
    }

    function reverseArray(address[] calldata _array) internal pure returns(address[] memory) {
        uint256 length = _array.length;
        address[] memory reversedArray = new address[](length);
        uint256 j = 0;
        for(uint i = length; i >= 1; i--) {
            reversedArray[j] = _array[i-1];
            j++;
        }
        return reversedArray;
    }

    function getOutput(uint256 amountIn, address[] calldata path) external view returns (uint256) {
        uint256[] memory amounts =  Swapper.getAmountsOut(factory, amountIn, path);

        return amounts[amounts.length-1];
    }

}

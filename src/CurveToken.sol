//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts@v4.9.6/token/ERC20/ERC20.sol";

contract CurveToken is ERC20 {
    uint256 public constant INITIAL_PRICE = 1e18;
    uint256 public constant PRICE_SLOPE = 1e18;

    event Buy(address indexed buyer, uint256 tokensBought, uint256 totalCost);
    event Sell(address indexed seller, uint256 tokensSold, uint256 totalRevenue);

    constructor() ERC20("CurveToken", "CT") {}

    function buyTokens() public payable {
        require(msg.value > 0, "Must send Ether to buy tokens");

        uint256 tokensToMint = tokensForEther(msg.value);
        require(tokensToMint > 0, "Insufficient Ether to buy tokens");

        uint256 cost = etherForTokensToBuy(tokensToMint);
        require(cost <= msg.value, "Calculated cost exceeds sent Ether");

        _mint(msg.sender, tokensToMint);

        uint256 refund = msg.value - cost;
        if (refund > 0) {
            (bool success,) = msg.sender.call{value: refund}("");
            require(success, "Refund failed");
        }

        emit Buy(msg.sender, tokensToMint, cost);
    }

    function sellTokens(uint256 tokensToSell) external {
        require(tokensToSell > 0, "Must sell at least one token");
        require(balanceOf(msg.sender) >= tokensToSell, "Not enough tokens to sell");

        uint256 revenue = etherForTokensToSell(tokensToSell);
        require(address(this).balance >= revenue, "Insufficient contract balance");

        _burn(msg.sender, tokensToSell);

        payable(msg.sender).transfer(revenue);

        emit Sell(msg.sender, tokensToSell, revenue);
    }

    function tokensForEther(uint256 etherAmount) private view returns (uint256 tokens) {
        uint256 low = 0;
        uint256 high = 1e24;
        uint256 mid;
        uint256 cost;

        while (low < high) {
            mid = (low + high + 1) / 2;
            cost = etherForTokensToBuy(mid);

            if (cost == etherAmount) {
                return mid;
            } else if (cost < etherAmount) {
                low = mid;
            } else {
                high = mid - 1;
            }
        }

        return low;
    }

    function etherForTokensToBuy(uint256 tokens) private view returns (uint256 etherAmount) {
        uint256 supply = totalSupply();

        uint256 startPrice = INITIAL_PRICE + PRICE_SLOPE * supply;
        uint256 endPrice = INITIAL_PRICE + PRICE_SLOPE * (supply + tokens - 1);

        etherAmount = tokens * (startPrice + endPrice) / 2;
    }

    function etherForTokensToSell(uint256 tokens) private view returns (uint256 etherAmount) {
        uint256 supply = totalSupply();

        require(tokens <= supply, "Cannot sell more tokens than total supply");

        uint256 startPrice = INITIAL_PRICE + PRICE_SLOPE * (supply - tokens);
        uint256 endPrice = INITIAL_PRICE + PRICE_SLOPE * (supply - 1);

        etherAmount = tokens * (startPrice + endPrice) / 2;
    }

    receive() external payable {
        buyTokens();
    }
}

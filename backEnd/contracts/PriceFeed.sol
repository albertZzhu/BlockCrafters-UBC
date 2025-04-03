// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// USD as default/base accteptable tokens. Also accept ETH and BTC.
contract PriceFeed {
    AggregatorV3Interface internal ethUsdPriceFeed;
    AggregatorV3Interface internal btcUsdPriceFeed;

    modifier onlyETHAndBTC(string memory tokenType){
        require(keccak256(bytes(tokenType)) ==  keccak256("ETH") || keccak256(bytes(tokenType)) == keccak256("BTC"),
         "Only accept either ETH or BTC");
        _;
    }

    constructor() {
        ethUsdPriceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        btcUsdPriceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
    }

    function getETHPrice() public view returns (uint256) {
        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid ETH price from Chainlink");
        return uint256(price); // 8 decimals
    }

    function getBTCPrice() public view returns (uint256) {
        (, int256 price,,,) = btcUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid ETH price from Chainlink");
        return uint256(price); // 8 decimals
    }

    // Assume ETH and BTC come in with 18 decimals (like msg.value)
    function convertToUSD(string memory tokenType, uint256 amount) public view onlyETHAndBTC(tokenType) returns (uint256) {
        uint256 price;

        if (keccak256(bytes(tokenType)) == keccak256("ETH")) {
            price = getETHPrice(); // 8 decimals
        } else if (keccak256(bytes(tokenType)) == keccak256("BTC")) {
            price = getBTCPrice(); // 8 decimals
        }

        // amount (18) * price (8) / 1e8 = USD amount (18)
        return (amount * price) / 1e8;
    }
}
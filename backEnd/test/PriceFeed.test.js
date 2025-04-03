
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PriceFeed Contract", function () {
  let priceFeedContract;

  beforeEach(async function () {
    const PriceFeedFactory = await ethers.getContractFactory("PriceFeed");
    priceFeedContract = await PriceFeedFactory.deploy();
    await priceFeedContract.waitForDeployment();
  });

  it("should return a positive ETH/USD price", async function () {
    const price = await priceFeedContract.getETHPrice();
    console.log("ETH/USD price:", price.toString());
    expect(price).to.be.gt(0);
  });

  it("should return a positive BTC/USD price", async function () {
    const price = await priceFeedContract.getBTCPrice();
    console.log("BTC/USD price:", price.toString());
    expect(price).to.be.gt(0);
  });

  it("should convert ETH amount to USD correctly", async function () {
    const ethAmount = ethers.parseEther("1"); // 1 ETH
    const usdValue = await priceFeedContract.convertToUSD("ETH", ethAmount);
    console.log("1 ETH in USD:", usdValue.toString());
    expect(usdValue).to.be.gt(0);
  });

  it("should convert BTC amount to USD correctly", async function () {
    const btcAmount = ethers.parseEther("1"); // 1 BTC
    const usdValue = await priceFeedContract.convertToUSD("BTC", btcAmount);
    console.log("1 BTC in USD:", usdValue.toString());
    expect(usdValue).to.be.gt(0);
  });
});

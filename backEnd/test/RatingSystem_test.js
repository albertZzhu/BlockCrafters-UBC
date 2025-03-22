const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RatingSystem", function () {
  let ratingSystem;
  let owner;
  let startup;
  let rater1, rater2;

  beforeEach(async function () {
    [owner, startup, rater1, rater2] = await ethers.getSigners();

    ratingSystem = await ethers.deployContract("RatingSystem");
  });

  describe("Rating functionality", function () {
    it("Should allow rating a startup", async function () {
      // r1 rates the startup
      await ratingSystem.connect(rater1).rateStartup(startup.address, 4);
      
      // r1's rate = avg
      const avgRating = await ratingSystem.getAverageRating(startup.address);
      expect(avgRating).to.equal(4);
    });

    it("Should calculate average rating correctly", async function () {
      // r1 = 5, r2 = 3
      await ratingSystem.connect(rater1).rateStartup(startup.address, 5);
      await ratingSystem.connect(rater2).rateStartup(startup.address, 3);
      
      // 5 + 3 = 8/ 2 = 4
      const avgRating = await ratingSystem.getAverageRating(startup.address);
      expect(avgRating).to.equal(4);
    });

    it("Should return 0 for startups with no ratings", async function () {
      const avgRating = await ratingSystem.getAverageRating(rater2.address); // using rater2 as an unrated startup
      expect(avgRating).to.equal(0);
    });

    it("Should prevent ratings outside the valid range", async function () {
      // 0 < 1
      await expect(
        ratingSystem.connect(rater1).rateStartup(startup.address, 0)
      ).to.be.revertedWith("Rating must be 1-5");

      // 6 > 5
      await expect(
        ratingSystem.connect(rater1).rateStartup(startup.address, 6)
      ).to.be.revertedWith("Rating must be 1-5");
    });

    it("Should prevent rating the zero address", async function () {
      const zeroAddress = ethers.ZeroAddress;
      await expect(
        ratingSystem.connect(rater1).rateStartup(zeroAddress, 3)
      ).to.be.revertedWith("Invalid startup address");
    });
  });

  describe("Events", function () {
    it("Should emit StartupRated event when rating a startup", async function () {
      // Check for emitted event
      await expect(ratingSystem.connect(rater1).rateStartup(startup.address, 4))
        .to.emit(ratingSystem, "StartupRated")
        .withArgs(startup.address, rater1.address, 4);
    });    
  });
});
const { expect } = require("chai");

describe("UserRegister Contract", function () {
  let UserRegister, userRegister, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    UserRegister = await ethers.getContractFactory("UserRegister");
    userRegister = await UserRegister.deploy();
  });

  it("should allow a user to register with a valid email", async function () {
    await expect(userRegister.connect(addr1).registerUser())
      .to.emit(userRegister, "UserRegistered")
      .withArgs(addr1.address);

    const user = await userRegister.users(addr1.address);
    expect(user.isRegistered).to.be.true;
    expect(user.walletAddress).to.equal(addr1.address);
  });

  it("should not allow the same user to register twice", async function () {
    await userRegister.connect(addr1).registerUser();

    await expect(userRegister.connect(addr1).registerUser())
      .to.be.revertedWith("Already registered");
  });

  it("should initialize user data correctly", async function () {
    await userRegister.connect(addr1).registerUser();
    const user = await userRegister.users(addr1.address);

    expect(user.walletAddress).to.equal(addr1.address);
    expect(user.isRegistered).to.be.true;
  });
});

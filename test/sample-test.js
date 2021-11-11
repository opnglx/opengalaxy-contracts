const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Galaxy", function () {
  it("Should return totalSupply", async function () {
    const Galaxy = await ethers.getContractFactory("Galaxy");
    const galaxy = await Galaxy.deploy();
    await galaxy.deployed();
    const [owner, addr1] = await ethers.getSigners();

    expect(await galaxy.totalSupply()).to.equal("100000000000000000000000000");

    const transferToken = await galaxy.transfer(
      addr1.address,
      ethers.utils.parseEther("1000")
    );

    // wait until the transaction is mined
    await transferToken.wait();

    expect(await galaxy.balanceOf(addr1.address)).to.equal(
      ethers.utils.parseEther("1000")
    );

    const lockTokenForAYear = await galaxy.lockTokens(
      0,
      4,
      ethers.utils.parseEther("1000"),
      addr1.address
    );

    // wait until the transaction is mined
    await lockTokenForAYear.wait();

    expect(await galaxy.getTransferableLockedAmount(addr1.address)).to.equal(
      ethers.utils.parseEther("250")
    );

    await galaxy
      .connect(addr1)
      .transfer(owner.address, ethers.utils.parseEther("150"));

    expect(await galaxy.getTransferableLockedAmount(addr1.address)).to.equal(
      ethers.utils.parseEther("100")
    );

    await galaxy
      .connect(owner)
      .transfer(addr1.address, ethers.utils.parseEther("50"));

    await galaxy
      .connect(addr1)
      .transfer(owner.address, ethers.utils.parseEther("150"));

    expect(await galaxy.getTransferableLockedAmount(addr1.address)).to.equal(
      ethers.utils.parseEther("0")
    );
  });
});

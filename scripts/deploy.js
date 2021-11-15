// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  const totalSupply = 100000000;
  const teamAmount = (totalSupply * 0.15).toFixed(0);
  const stakingAmount = (totalSupply * 0.14).toFixed(0);
  const bountyAmount = (totalSupply * 0.01).toFixed(0);
  const listingAmount = (totalSupply * 0.03).toFixed(0);
  const marketingAmount = (totalSupply * 0.12).toFixed(0);
  const mergerAndAcquisitionAmount = (totalSupply * 0.1).toFixed(0);
  const salesAmount = (totalSupply * 0.3).toFixed(0);
  const investorsAmount = (totalSupply * 0.1).toFixed(0);
  const advisorsAmount = (totalSupply * 0.05).toFixed(0);

  const [
    owner,
    investors,
    advisors,
    team,
    staking,
    bounty,
    listing,
    marketing,
    mergerAndAcquisition,
    sales,
  ] = await ethers.getSigners();

  // We get the contract to deploy
  const Galaxy = await hre.ethers.getContractFactory("GalaxyToken");
  const galaxy = await Galaxy.deploy();

  await galaxy.deployed();

  console.log("Galaxy deployed to:", galaxy.address);

  // send tokens to team and lock them
  await galaxy
    .connect(owner)
    .transfer(team.address, ethers.utils.parseEther(String(teamAmount)));

  await galaxy
    .connect(owner)
    .lockTokens(
      6,
      12,
      ethers.utils.parseEther(String(teamAmount)),
      team.address
    );

  // send tokens to investors and lock them
  await galaxy
    .connect(owner)
    .transfer(
      investors.address,
      ethers.utils.parseEther(String(investorsAmount))
    );

  await galaxy
    .connect(owner)
    .lockTokens(
      8,
      12,
      ethers.utils.parseEther(String(investorsAmount)),
      investors.address
    );

  // send tokens to advisors and lock them
  await galaxy
    .connect(owner)
    .transfer(
      advisors.address,
      ethers.utils.parseEther(String(advisorsAmount))
    );

  await galaxy
    .connect(owner)
    .lockTokens(
      0,
      4,
      ethers.utils.parseEther(String(advisorsAmount)),
      advisors.address
    );

  // send tokens to staking
  await galaxy
    .connect(owner)
    .transfer(staking.address, ethers.utils.parseEther(String(stakingAmount)));

  // send tokens to bounty and lock them
  await galaxy
    .connect(owner)
    .transfer(bounty.address, ethers.utils.parseEther(String(bountyAmount)));

  await galaxy
    .connect(owner)
    .lockTokens(
      0,
      3,
      ethers.utils.parseEther(String(bountyAmount)),
      bounty.address
    );

  // send tokens to listing
  await galaxy
    .connect(owner)
    .transfer(listing.address, ethers.utils.parseEther(String(listingAmount)));

  // send tokens to marketing and lock them
  await galaxy
    .connect(owner)
    .transfer(
      marketing.address,
      ethers.utils.parseEther(String(marketingAmount))
    );

  await galaxy
    .connect(owner)
    .lockTokens(
      4,
      12,
      ethers.utils.parseEther(String(marketingAmount)),
      marketing.address
    );

  // send tokens to mergerAndAcquisition and lock them
  await galaxy
    .connect(owner)
    .transfer(
      mergerAndAcquisition.address,
      ethers.utils.parseEther(String(mergerAndAcquisitionAmount))
    );

  await galaxy
    .connect(owner)
    .lockTokens(
      12,
      1,
      ethers.utils.parseEther(String(mergerAndAcquisitionAmount)),
      mergerAndAcquisition.address
    );

  // send tokens to sales
  await galaxy
    .connect(owner)
    .transfer(sales.address, ethers.utils.parseEther(String(salesAmount)));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

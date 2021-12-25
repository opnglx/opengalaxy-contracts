module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  console.log("running Open Galaxy Lockable Crowdsale deployment script")

  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  const crowdsaleLockAddreess = (await deployments.get("CrowdsaleLock")).address
  const saleTokenAddress = (await deployments.get("OpenGalaxyToken")).address
  const fundingTokenAddress = (await deployments.get("ERC20Mock")).address

  await deploy("LockableCrowdsale", {
    from: deployer,
    log: true,
    autoMine: true,
    args: [crowdsaleLockAddreess, saleTokenAddress, fundingTokenAddress, 1, 1],
  })
}

module.exports.tags = ["LockableCrowdsale"]
module.exports.dependencies = ["CrowdsaleLock", "OpenGalaxyToken", "ERC20Mock"]

module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  console.log("running Crowdsale Lock deployment script")

  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  const saleTokenAddress = (await deployments.get("OpenGalaxyToken")).address

  const duration = 60

  await deploy("CrowdsaleLock", {
    from: deployer,
    log: true,
    autoMine: true,
    args: [saleTokenAddress, duration],
  })
}

module.exports.tags = ["CrowdsaleLock"]
module.exports.dependencies = ["OpenGalaxyToken"]

module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  console.log("running Open Galaxy Crowdsale deployment script")

  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy("ERC20Mock", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Tether", "USDT", 1000000],
  })

  const saleTokenAddress = (await deployments.get("OpenGalaxyToken")).address
  const fundingTokenAddress = (await deployments.get("ERC20Mock")).address

  await deploy("CrowdsaleV2", {
    from: deployer,
    log: true,
    autoMine: true,
    args: [saleTokenAddress, fundingTokenAddress, 1, 1],
  })
}

module.exports.tags = ["CrowdsaleV2"]
module.exports.dependencies = ["ERC20Mock"]

module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  console.log("running ERC20 Mock Token deployment script")

  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy("ERC20Mock", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Tether", "USDT", 1000000],
  })
}

module.exports.tags = ["ERC20Mock"]

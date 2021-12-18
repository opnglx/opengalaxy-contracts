module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  console.log("running Open Galaxy Token deployment script")

  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy("OpenGalaxyToken", {
    from: deployer,
    log: true,
    autoMine: true,
  })
}

module.exports.tags = ["OpenGalaxyToken"]

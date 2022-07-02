const hre = require("hardhat");

async function main() {
  const tokenAddress = ""
  const rewardAmountPerAddress = hre.ethers.utils.formatUnits(1000, "ether")

  const Airdrop = await hre.ethers.getContractFactory("Airdrop");
  const airdrop = await Airdrop.deploy(tokenAddress, rewardAmountPerAddress);
  await airdrop.deployed();

  console.log("Airdrop deployed to:", airdrop.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

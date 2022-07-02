require("@nomiclabs/hardhat-waffle");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: "0.8.4",
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    localhost: {
      url: 'http://127.0.0.1:8545',
      allowUnlimitedContractSize: true,
    },
    ftm: {
      url: 'https://rpc.ftm.tools/',
      allowUnlimitedContractSize: true,
      accounts: [],
    },
    testnet: {
      url: 'https://xapi.testnet.fantom.network/lachesis',
      allowUnlimitedContractSize: true,
      accounts: [],
    },
  }
};

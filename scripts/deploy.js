// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const swapperContract = await hre.ethers.getContractFactory("Swapper");
  const swapper = await swapperContract.deploy();
  await swapper.deployed();

  const HSniper = await hre.ethers.getContractFactory("HSniper", {
    libraries: {
      Swapper: swapper.address,
    },
  });
  const network = await hre.ethers.provider.getNetwork();
  const factory =
    network.chainId === 56
      ? "0xca143ce32fe78f1f7019d7d551a6402fc5350c73"
      : "0x6725F303b657a9451d8BA641348b6761A6CC7a17";

  const hSniper = await HSniper.deploy(factory);

  await hSniper.deployed();

  console.log(`Deployed to ${hSniper.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

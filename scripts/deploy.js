// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const HSniper = await hre.ethers.getContractFactory("HSniper");
  const hSniper = await HSniper.deploy("0xca143ce32fe78f1f7019d7d551a6402fc5350c73");

  await hSniper.deployed();

  console.log(
    `Deployed to ${hSniper.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

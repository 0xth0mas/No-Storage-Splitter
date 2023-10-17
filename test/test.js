const {
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Test", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySplitter() {
    

    // Contracts are deployed using the first signer/account by default
    const [owner, account1, account2, account3, account4] = await ethers.getSigners();

    const SplitterFactory = await ethers.getContractFactory("Splitter");
    const splitter = await SplitterFactory.deploy([account1.address, account2.address, account3.address, account4.address], [1000, 2000, 3000, 4000]);

    const TestERC20Factory = await ethers.getContractFactory("TestERC20");
    const testERC20 = await TestERC20Factory.deploy();

    console.log(await ethers.provider.getCode(splitter.target));


    return { splitter, testERC20, owner, account1, account2, account3, account4 };
  }

  describe("Test", function () {
    it("Should work", async function () {
      const { splitter, testERC20, owner, account1, account2, account3, account4 } = await loadFixture(deploySplitter);

      console.log("Balances start: ");
      console.log("Contract balance (ETH): " + await ethers.provider.getBalance(splitter.target));
      console.log("Payment #1 balance (ETH): " + await ethers.provider.getBalance(account1.address));
      console.log("Payment #2 balance (ETH): " + await ethers.provider.getBalance(account2.address));
      console.log("Payment #3 balance (ETH): " + await ethers.provider.getBalance(account3.address));
      console.log("Payment #4 balance (ETH): " + await ethers.provider.getBalance(account4.address));
      console.log("Contract balance (ERC20): " + await testERC20.balanceOf(splitter.target));
      console.log("Payment #1 balance (ERC20): " + await testERC20.balanceOf(account1.address));
      console.log("Payment #2 balance (ERC20): " + await testERC20.balanceOf(account2.address));
      console.log("Payment #3 balance (ERC20): " + await testERC20.balanceOf(account3.address));
      console.log("Payment #4 balance (ERC20): " + await testERC20.balanceOf(account4.address));

      const sendEth1 = { to: splitter.target, value: ethers.parseEther("0.1") }
      const receiptTx1 = await owner.sendTransaction(sendEth1);
      await receiptTx1.wait();

      await testERC20.mintSome();
      await testERC20.transfer(splitter.target, 10_000_000_000);

      console.log("Balances before: ");
      console.log("Contract balance (ETH): " + await ethers.provider.getBalance(splitter.target));
      console.log("Payment #1 balance (ETH): " + await ethers.provider.getBalance(account1.address));
      console.log("Payment #2 balance (ETH): " + await ethers.provider.getBalance(account2.address));
      console.log("Payment #3 balance (ETH): " + await ethers.provider.getBalance(account3.address));
      console.log("Payment #4 balance (ETH): " + await ethers.provider.getBalance(account4.address));
      console.log("Contract balance (ERC20): " + await testERC20.balanceOf(splitter.target));
      console.log("Payment #1 balance (ERC20): " + await testERC20.balanceOf(account1.address));
      console.log("Payment #2 balance (ERC20): " + await testERC20.balanceOf(account2.address));
      console.log("Payment #3 balance (ERC20): " + await testERC20.balanceOf(account3.address));
      console.log("Payment #4 balance (ERC20): " + await testERC20.balanceOf(account4.address));
      await splitter.release();
      await splitter.releaseToken(testERC20.target, 0);
      console.log("Balances after: ");
      console.log("Contract balance (ETH): " + await ethers.provider.getBalance(splitter.target));
      console.log("Payment #1 balance (ETH): " + await ethers.provider.getBalance(account1.address));
      console.log("Payment #2 balance (ETH): " + await ethers.provider.getBalance(account2.address));
      console.log("Payment #3 balance (ETH): " + await ethers.provider.getBalance(account3.address));
      console.log("Payment #4 balance (ETH): " + await ethers.provider.getBalance(account4.address));
      console.log("Contract balance (ERC20): " + await testERC20.balanceOf(splitter.target));
      console.log("Payment #1 balance (ERC20): " + await testERC20.balanceOf(account1.address));
      console.log("Payment #2 balance (ERC20): " + await testERC20.balanceOf(account2.address));
      console.log("Payment #3 balance (ERC20): " + await testERC20.balanceOf(account3.address));
      console.log("Payment #4 balance (ERC20): " + await testERC20.balanceOf(account4.address));
      console.log(await splitter.recipients());
      console.log(await splitter.shares());
      console.log(await splitter.totalShares());
    });
  });
});

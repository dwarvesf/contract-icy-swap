import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("IcySwap", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployIcySwapFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, secondAccount, thirdAccount] = await ethers.getSigners();

    const UsdcMock = await ethers.getContractFactory("UsdcMock");
    const usdcMock = await UsdcMock.deploy(
      ethers.utils.parseUnits("1000000", 6)
    );

    const IcyMock = await ethers.getContractFactory("IcyMock");
    const icyMock = await IcyMock.deploy(ethers.utils.parseEther("1000000"));

    const icyToUsdcConversionRate = "2"; // 1 icy = 2 usdc
    const IcySwap = await ethers.getContractFactory("IcySwap");
    const icySwap = await IcySwap.deploy(
      usdcMock.address,
      icyMock.address,
      ethers.utils.parseUnits(icyToUsdcConversionRate, 6)
    );

    return {
      usdcMock,
      icyMock,
      icySwap,
      icyToUsdcConversionRate,
      owner,
      secondAccount,
      thirdAccount,
    };
  }

  describe("Deployment", function () {
    it("Should set the right token and conversion rate", async function () {
      const { icyMock, usdcMock, icySwap, icyToUsdcConversionRate } =
        await loadFixture(deployIcySwapFixture);

      expect(await icySwap.icy()).to.equal(icyMock.address);
      expect(await icySwap.usdc()).to.equal(usdcMock.address);
      expect(await icySwap.icyToUsdcConversionRate()).to.equal(
        ethers.utils.parseUnits(icyToUsdcConversionRate, 6)
      );
    });

    it("Should set the right owner", async function () {
      const { icySwap, owner } = await loadFixture(deployIcySwapFixture);

      expect(await icySwap.owner()).to.equal(owner.address);
    });
  });

  describe("SetConversionRate", function () {
    describe("Validations", function () {
      it("Should revert with the right error if caller is not owner", async function () {
        const { icySwap, secondAccount } = await loadFixture(
          deployIcySwapFixture
        );

        await expect(
          icySwap.connect(secondAccount).setConversionRate("100")
        ).to.be.revertedWith("Ownable: caller is not the owner");
      });
    });

    describe("State", function () {
      it("Should update new conversion rate", async function () {
        const { icySwap } = await loadFixture(deployIcySwapFixture);
        await icySwap.setConversionRate("100");
        expect(await icySwap.icyToUsdcConversionRate()).to.equal("100");
      });
    });
  });

  describe("Swap", function () {
    describe("Swap ICY To USDC", function () {
      it("Should transfer the right amount to caller", async function () {
        const {
          usdcMock,
          icyMock,
          icySwap,
          icyToUsdcConversionRate,
          secondAccount,
        } = await loadFixture(deployIcySwapFixture);

        // prepare init balance
        await icyMock.transfer(
          secondAccount.address,
          ethers.utils.parseEther("100")
        );

        // Top up 1000 USDC
        const topupUsdcAmount = "1000";
        await usdcMock.transfer(
          icySwap.address,
          ethers.utils.parseUnits(topupUsdcAmount, 6)
        );

        // Swap icy to get usdc
        const icyAmountIn = "100";
        const expectedUsdcAmountOut = +icyAmountIn * +icyToUsdcConversionRate;
        await icyMock
          .connect(secondAccount)
          .approve(icySwap.address, ethers.utils.parseEther(icyAmountIn));
        await icySwap
          .connect(secondAccount)
          .swap(ethers.utils.parseEther(icyAmountIn));

        expect(await usdcMock.balanceOf(secondAccount.address)).to.equal(
          ethers.utils.parseUnits(`${expectedUsdcAmountOut}`, 6)
        );
        expect(await icyMock.balanceOf(secondAccount.address)).to.equal("0");

        expect(await usdcMock.balanceOf(icySwap.address)).to.equal(
          ethers.utils.parseUnits("800", 6)
        );
        expect(await icyMock.balanceOf(icySwap.address)).to.equal(
          ethers.utils.parseEther(icyAmountIn)
        );
      });
    });
  });

  describe("WithdrawToOwner", function () {
    it("Should transfer the token to owner", async function () {
      const {
        usdcMock,
        icyMock,
        icySwap,
        icyToUsdcConversionRate,
        owner,
        secondAccount,
      } = await loadFixture(deployIcySwapFixture);

      // prepare init balance
      await icyMock.transfer(
        secondAccount.address,
        ethers.utils.parseEther("100")
      );

      // Top up 1000 USDC
      const topupUsdcAmount = "1000";
      await usdcMock.transfer(
        icySwap.address,
        ethers.utils.parseUnits(topupUsdcAmount, 6)
      );

      // Swap icy to get usdc
      const icyAmountIn = "100";
      const expectedUsdcAmountOut = +icyAmountIn * +icyToUsdcConversionRate;
      await icyMock
        .connect(secondAccount)
        .approve(icySwap.address, ethers.utils.parseEther(icyAmountIn));
      await icySwap
        .connect(secondAccount)
        .swap(ethers.utils.parseEther(icyAmountIn));

      expect(await usdcMock.balanceOf(secondAccount.address)).to.equal(
        ethers.utils.parseUnits(`${expectedUsdcAmountOut}`, 6)
      );
      expect(await icyMock.balanceOf(secondAccount.address)).to.equal("0");

      const beforeOwnerIcyBalance = await icyMock.balanceOf(owner.address);
      await icySwap.withdrawToOwner(icyMock.address);
      expect(await icyMock.balanceOf(owner.address)).to.equal(
        beforeOwnerIcyBalance.add(ethers.utils.parseEther(icyAmountIn))
      );
    });
  });
});

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
      expect(await icySwap.icyToUsdcCoversionRate()).to.equal(
        ethers.utils.parseUnits(icyToUsdcConversionRate, 6)
      );
    });

    it("Should set the right owner", async function () {
      const { icySwap, owner } = await loadFixture(deployIcySwapFixture);

      expect(await icySwap.owner()).to.equal(owner.address);
    });
  });

  describe("TopupUsdc", function () {
    describe("Validations", function () {
      it("Should revert with the right error if caller is not owner", async function () {
        const { icySwap, secondAccount } = await loadFixture(
          deployIcySwapFixture
        );

        await expect(
          icySwap.connect(secondAccount).topUpUSDC("100")
        ).to.be.revertedWith("Ownable: caller is not the owner");
      });
    });

    describe("Transfer", function () {
      it("Should transfer usdc to contract", async function () {
        const { usdcMock, icySwap } = await loadFixture(deployIcySwapFixture);

        // Top up 1000 USDC
        const topupUsdcAmount = "1000";
        await usdcMock.approve(
          icySwap.address,
          ethers.utils.parseUnits(topupUsdcAmount, 6)
        );
        await icySwap.topUpUSDC(ethers.utils.parseUnits(topupUsdcAmount, 6));
        expect(await usdcMock.balanceOf(icySwap.address)).to.equal(
          ethers.utils.parseUnits("1000", 6)
        );
      });
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
        expect(await icySwap.icyToUsdcCoversionRate()).to.equal("100");
      });
    });
  });

  describe("Swap", function () {
    describe("Validations", function () {
      it("Should revert with the right error if send the invalid token", async function () {
        const { icySwap } = await loadFixture(deployIcySwapFixture);

        await expect(
          icySwap.swap(ethers.constants.AddressZero, "1000")
        ).to.be.revertedWith("not allow token");
      });
    });

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
        await usdcMock.approve(
          icySwap.address,
          ethers.utils.parseUnits(topupUsdcAmount, 6)
        );
        await icySwap.topUpUSDC(ethers.utils.parseUnits(topupUsdcAmount, 6));

        // Swap icy to get usdc
        const icyAmountIn = "100";
        const expectedUsdcAmountOut = +icyAmountIn * +icyToUsdcConversionRate;
        await icyMock
          .connect(secondAccount)
          .approve(icySwap.address, ethers.utils.parseEther(icyAmountIn));
        await icySwap
          .connect(secondAccount)
          .swap(icyMock.address, ethers.utils.parseEther(icyAmountIn));

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

    describe("Swap USDC To ICY", function () {
      it("Should transfer the right amount to caller", async function () {
        const { usdcMock, icyMock, icySwap, secondAccount, thirdAccount } =
          await loadFixture(deployIcySwapFixture);

        // prepare init balance
        await icyMock.transfer(
          secondAccount.address,
          ethers.utils.parseEther("100")
        );

        await usdcMock.transfer(
          thirdAccount.address,
          ethers.utils.parseUnits("200", 6)
        );

        // Top up 1000 USDC
        const topupUsdcAmount = "1000";
        await usdcMock.approve(
          icySwap.address,
          ethers.utils.parseUnits(topupUsdcAmount, 6)
        );
        await icySwap.topUpUSDC(ethers.utils.parseUnits(topupUsdcAmount, 6));

        // Swap icy to get usdc
        await icyMock
          .connect(secondAccount)
          .approve(icySwap.address, ethers.utils.parseEther("100"));
        await icySwap
          .connect(secondAccount)
          .swap(icyMock.address, ethers.utils.parseEther("100"));

        expect(await usdcMock.balanceOf(secondAccount.address)).to.equal(
          ethers.utils.parseUnits("200", 6)
        );
        expect(await icyMock.balanceOf(secondAccount.address)).to.equal("0");

        // Swap usdc to get icy
        await usdcMock
          .connect(thirdAccount)
          .approve(icySwap.address, ethers.utils.parseUnits("200", 6));
        await icySwap
          .connect(thirdAccount)
          .swap(usdcMock.address, ethers.utils.parseUnits("200", 6));

        expect(await usdcMock.balanceOf(thirdAccount.address)).to.equal("0");
        expect(await icyMock.balanceOf(thirdAccount.address)).to.equal(
          ethers.utils.parseEther("100")
        );

        expect(await usdcMock.balanceOf(icySwap.address)).to.equal(
          ethers.utils.parseUnits("1000", 6)
        );
        expect(await icyMock.balanceOf(icySwap.address)).to.equal("0");
      });
    });
  });
});

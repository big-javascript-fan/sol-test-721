const { expect } = require("chai")
const hre = require("hardhat")
const { ethers } = require("hardhat")
const { BigNumber } = require("ethers")
const {
	expectRevert
} = require('@openzeppelin/test-helpers');


let test721Instance;
let accessControlInstance;
let test1155Instance;
let nft721;
let nft1155;
let accessControl;
let owner;
let account1;
let account2;

describe("Test721", function () {
	before(async function () {
		let wallets = await ethers.getSigners();
		owner = wallets[0];
		account1 = wallets[1];
		account2 = wallets[2];
        accessControlInstance = await ethers.getContractFactory("TestAccessControl");
		test721Instance = await ethers.getContractFactory("Test721");
        test1155Instance = await ethers.getContractFactory("Test1155");
        accessControl = await accessControlInstance.deploy();
		nft721 = await test721Instance.deploy(accessControl.address);
        nft1155 = await test1155Instance.deploy();
        await nft1155.mint(account1.address, [1], [1000]);
        await nft1155.mint(account2.address, [1], [1000]);
        await accessControl.addAttributeManagerRole(account1.address);
		await nft1155.connect(account1).setApprovalForAll(nft721.address, true);
        await nft1155.connect(account2).setApprovalForAll(nft721.address, true);
        await nft1155.connect(owner).setApprovalForAll(nft721.address, true);
	})

	describe("setAttribute", async () => {
		it('should success on setAttribute', async () => {
            await nft721.connect(account1).setAttribute("test1", nft1155.address, 1, 1);
            await nft721.connect(account1).setAttribute("test1", nft1155.address, 1, 1);
            const attribute = await nft721.getAttribute("test1", 1);
            expect(attribute.erc1155Address).to.be.equal(nft1155.address);
            expect(attribute.token1155Id).to.be.equal(1);

            const balanceOfOwner = await nft1155.balanceOf(owner.address, 1);
            expect(balanceOfOwner).to.be.equal(1000);
		});

		it('should fail if non-attribute manager try to call setAttribute', async () => {
			expectRevert(
                nft721.connect(account2).setAttribute("test2", nft1155.address, 1, 1),
                "Need to be attribute manager role to set attribute"
            );
		});
	});
})
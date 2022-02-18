const { expect } = require('chai')
const { ethers } = require('hardhat')

describe("GivPaymentSplitter Tests", function () {
    let deployer
    let clubPhysique
    beforeEach(async () => {
        [deployer] = await ethers.getSigners()
        const clubPhysique = await ethers.getContractFactory('ERC721PresetMinterPauser')
        clubPhysique = await clubPhysique.deploy('clubPhysique', 'GIV')
        await clubPhysique.deployed()
    });
    describe('Add payees with varying amounts and distribute payments', async () => {})

});



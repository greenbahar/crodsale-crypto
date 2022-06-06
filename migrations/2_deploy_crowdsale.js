const IOLToken = artifacts.require("./IOLToken.sol");

module.exports = function (deployer) {
    const initialSupply = 1000;
    const _name = "IOL";
    const _symbol = "IOL";
    deployer.deploy(IOLToken, initialSupply, _name, _symbol);
};

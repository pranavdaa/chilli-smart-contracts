const ChilliToken = artifacts.require("ChilliToken");

module.exports = function (deployer) {
  deployer.deploy(
    ChilliToken,
    "Chilli",
    "CHI",
    0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa,
    "1000000000000000000000000"
    
    );
};

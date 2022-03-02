const math = artifacts.require("Math.sol");

module.exports = function (deployer) {
  deployer.deploy(math);
};
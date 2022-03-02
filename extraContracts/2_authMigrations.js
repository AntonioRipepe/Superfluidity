const auth = artifacts.require("DSAuth");

module.exports = function (deployer) {
  deployer.deploy(auth);
};
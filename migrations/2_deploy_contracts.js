var PlayFacade = artifacts.require("./PlayFacade.sol");

module.exports = function(deployer) {
  deployer.deploy(PlayFacade);
};

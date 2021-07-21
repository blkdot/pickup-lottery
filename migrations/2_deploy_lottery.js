const PickupLottery = artifacts.require("PickupLottery");

module.exports = function (deployer) {
  deployer.deploy(PickupLottery);
};

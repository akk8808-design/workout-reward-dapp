const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("WorkoutRewardTokenModule", (m) => {
  const token = m.contract("WorkoutRewardToken");
  return { token };
});

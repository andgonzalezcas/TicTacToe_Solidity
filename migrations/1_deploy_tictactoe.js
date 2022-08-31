let tictactoe = artifacts.require("TicTacToe");

module.exports = function(deployer) {
  deployer.deploy(tictactoe)
}
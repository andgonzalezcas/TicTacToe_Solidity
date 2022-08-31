// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract TicTacToe {
  enum Player {
    emptySpace,
    playerOne,
    playerTwo
  }

  enum Winner {
    undefined,
    playerOne,
    playerTwo,
    draw
  }

  struct Game {
    address playerOne;
    address playerTwo;
    Winner winner;
    Player playerTurn;
    Player[3][3] board;
  }

  mapping(uint256 => Game) private games;
  uint256 private gameListLarge;

  function newGame () public returns (uint256 gameId, string memory gameMessage) {
    Game memory game;
    game.playerTurn = Player.playerOne;
    gameListLarge++;
    games[gameListLarge] = game;
    return(gameListLarge, "Game created successfully");
  }
  
  function joinGame (uint256 _gameId) public validGameId(_gameId) returns (bool success, string memory successMessage){
    address player = msg.sender;
    Game storage game = games[_gameId];

    if (game.playerOne == address(0)) {
      game.playerOne = player;
      return (true, "Joined as player one.");
    } else if (game.playerOne == player) {
      return (true, "You are actually the player number one.");
    }else if (game.playerTwo == address(0)) {
      game.playerTwo = player;
      return (true, "Joined as player two.");
    } else if (game.playerTwo == player) {
      return (true, "You are actually the player number two.");
    } 
    return (false, "No more Player are allowed in this game, try another one.");
  }

  function makeMove (uint256 _gameId, uint256 _xCoord, uint256 _yCoord)
  public validGameId(_gameId) validGameOver(_gameId) validPlayerTurn(_gameId)
  returns (bool success, string memory successMessage){
    Game storage game = games[_gameId];

    if (game.board[_xCoord][_yCoord] != Player.emptySpace) {
      return (false, "There is already a mark at the given coordinates.");
    }
    game.board[_xCoord][_yCoord] = game.playerTurn;
    Winner winner = isWinner(game.board);

    if (winner != Winner.undefined) {
      game.winner = winner;
      return (true, "The game is over.");
    }
    changePlayerTurn(game);
    return (true, "");
  }

  function getCurrentPlayerTurn (Game storage _game) private view returns (address player) {
    if (_game.playerTurn == Player.playerOne) return _game.playerOne;
    if (_game.playerTurn == Player.playerTwo) return _game.playerTwo;
    return address(0);
  }

  function isWinner (Player[3][3] memory _board) private pure returns (Winner winner) {
    Winner player = isWinnerInRow(_board);
    if (player == Winner.playerOne) return Winner.playerOne;
    if (player == Winner.playerTwo)return Winner.playerTwo;

    player = isWinnerInCol(_board);
    if (player == Winner.playerOne) return Winner.playerOne;
    if (player == Winner.playerTwo) return Winner.playerTwo;

    player = isWinnerInDiagonal(_board);
    if (player == Winner.playerOne) return Winner.playerOne;
    if (player == Winner.playerTwo) return Winner.playerTwo;

    if (isBoardFull(_board)) return Winner.draw;
    return Winner.undefined;
  }

  function isWinnerInRow (Player[3][3] memory _board) private pure returns (Winner winner) {
    for (uint8 x = 0; x < 3; x++) {
      if (
        _board[x][0] == _board[x][1] &&
        _board[x][1] == _board[x][2] &&
        _board[x][0] != Player.emptySpace
      ) {
        if(_board[x][0] == Player.playerOne) return Winner.playerOne;
        return Winner.playerTwo;
      }
    }
    return Winner.undefined;
  }

  function isWinnerInCol (Player[3][3] memory _board) private pure returns (Winner winner) {
    for (uint8 y = 0; y < 3; y++) {
      if (
        _board[0][y] == _board[1][y] &&
        _board[1][y] == _board[2][y] &&
        _board[0][y] != Player.emptySpace
      ) {
        if(_board[0][y] == Player.playerOne) return Winner.playerOne;
        return Winner.playerTwo;
      }
    }
    return Winner.undefined;
  }

  function isWinnerInDiagonal (Player[3][3] memory _board) private pure returns (Winner winner) {
    if (
      _board[0][0] == _board[1][1] &&
      _board[1][1] == _board[2][2] &&
      _board[0][0] != Player.emptySpace
    ) {
      if(_board[1][1] == Player.playerOne) return Winner.playerOne;
      return Winner.playerTwo;
    }

    if (
      _board[0][2] == _board[1][1] &&
      _board[1][1] == _board[2][0] &&
      _board[0][2] != Player.emptySpace
    ) {
      if(_board[1][1] == Player.playerOne) return Winner.playerOne;
      return Winner.playerTwo;
    }
    return Winner.undefined;
  }

  function isBoardFull (Player[3][3] memory _board) private pure returns (bool isFull){
    for (uint8 x = 0; x < 3; x++) {
      for (uint8 y = 0; y < 3; y++) {
        if (_board[x][y] == Player.emptySpace) return false;
      }
    }
    return true;
  }

  function changePlayerTurn (Game storage _game) private {
    if (_game.playerTurn == Player.playerOne) {
      _game.playerTurn = Player.playerTwo;
    } else {
      _game.playerTurn = Player.playerOne;
    }
  }

  function getGameData (uint256 _gameId) public view validGameId(_gameId)
  returns (address winner, Player[3][3] memory board, address playerOne, address playerTwo){
    Game storage game = games[_gameId];
    if (game.winner == Winner.playerOne){
      return (game.playerOne, game.board, game.playerOne, game.playerTwo);
    } else if (game.winner == Winner.playerTwo) {
      return (game.playerTwo, game.board, game.playerOne, game.playerTwo);
    }
    return (address(0), game.board, game.playerOne, game.playerTwo);
  }

  function getBoard (uint256 _gameId) public view validGameId(_gameId) returns (Player[3][3] memory board) {
    Game storage game = games[_gameId] ;
    return (game.board);
  }

  modifier validGameId(uint256 _gameId) {
    require(gameListLarge >= _gameId, "Invalid game id, please confirm it and try it again.");
    _;
  }

  modifier validGameOver(uint256 _gameId) {
    Game storage game = games[_gameId];
    require(game.winner == Winner.undefined, "The game has already ended.");
    _;
  }

  modifier validPlayerTurn(uint256 _gameId) {
    Game storage game = games[_gameId];
    require(msg.sender == getCurrentPlayerTurn(game), "It is not your turn.");
    _;
  }
}
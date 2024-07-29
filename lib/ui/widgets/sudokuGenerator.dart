import 'dart:math';

class SudokuGenerator {
  SudokuGenerator({int emptySquares = 54, bool uniqueSolution = true}) {
    _emptySquares = emptySquares;
    _sudoku = List.generate(9, (i) => List.generate(9, (j) => 0));
    _fillValues();
  }

  late int _emptySquares;
  late List<List<int>> _sudoku;
  late List<List<int>> _sudokuSolved;

  List<List<int>> get newSudoku => _sudoku;
  List<List<int>> get newSudokuSolved => _sudokuSolved;

  void _fillValues() {
    _fillDiagonal();
    _fillRemaining(0, 0);
    _sudokuSolved = List.generate(9, (i) => List.from(_sudoku[i]));
    _removeClues();
  }

  void _fillDiagonal() {
    //!makes diagonal boxes
    for (var i = 0; i < 9; i += 3) {
      _fillBox(i, i);
    }
  }

  void _fillBox(int row, int column) {
    var rng = Random();
    List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(rng);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        _sudoku[row + i][column + j] = numbers[i * 3 + j];
      }
    }
  }

  bool _checkIfSafe(int i, int j, int number) {
    //!check if number is already in row, column or box then fill random numbers
    return _unUsedInRow(i, number) &&
        _unUsedInColumn(j, number) &&
        _unUsedInBox(i - (i % 3), j - (j % 3), number);
  }

  bool _unUsedInRow(int i, int number) => !_sudoku[i].contains(number);

  bool _unUsedInColumn(int j, int number) {
    for (var row in _sudoku) {
      if (row[j] == number) return false;
    }
    return true;
  }

  bool _unUsedInBox(int rowStart, int columnStart, int number) {
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (_sudoku[rowStart + i][columnStart + j] == number) return false;
      }
    }
    return true;
  }

  bool _fillRemaining(int i, int j) {
    //!box except diagonal
    if (j >= 9) {
      j = 0;
      i++;
      if (i >= 9) return true;
    }
    if (_sudoku[i][j] != 0) return _fillRemaining(i, j + 1);

    for (var number = 1; number <= 9; number++) {
      if (_checkIfSafe(i, j, number)) {
        _sudoku[i][j] = number;
        if (_fillRemaining(i, j + 1)) return true;
        _sudoku[i][j] = 0;
      }
    }
    return false;
  }

  void _removeClues() {
    //!makes empty squares
    var rng = Random();
    while (_emptySquares > 0) {
      var row = rng.nextInt(9);
      var column = rng.nextInt(9);
      if (_sudoku[row][column] != 0) {
        _sudoku[row][column] = 0;
        _emptySquares--;
      }
    }
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:sudoku/ui/widgets/cellCharacter.dart';
import 'package:sudoku/ui/widgets/boxInner.dart';
import 'package:sudoku/ui/widgets/focusClass.dart';
import 'package:sudoku/ui/widgets/sudokuGenerator.dart';
import 'package:sudoku/ui/widgets/sudokuSolver.dart';

class SudokuWidget extends StatefulWidget {
  const SudokuWidget({super.key});

  @override
  State<SudokuWidget> createState() => _SudokuWidgetState();
}

class _SudokuWidgetState extends State<SudokuWidget> {
  List<BoxInner> boxInners = [];
  FocusClass focusClass = FocusClass();
  bool isFinish = false;
  String? tapBoxIndex;

  @override
  void initState() {
    generateSudoku();

    // TODO: implement initState
    super.initState();
  }

  void generateSudoku() {
    isFinish = false;
    focusClass = FocusClass();
    tapBoxIndex = null;
    generatePuzzle();
    checkFinish();

    setState(() {});
  }

  void solveSudoku() {
    List<List<int>> board =
        _getBoardFromBoxInners(); //! It retrieves the current Sudoku board

    if (SudokuSolver.solve(board)) {
      _updateBoxInnersFromBoard(board);
      checkFinish();
    } else {
      print("No solution");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No solution'),
        ),
      );
    }

    setState(() {}); // refresh the UI.
  }

  List<List<int>> _getBoardFromBoxInners() {
    List<List<int>> board = List.generate(9, (_) => List.generate(9, (_) => 0));

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        int boxIndex = (i ~/ 3) * 3 +
            (j ~/ 3); // to find which 3x3 box the cell belongs to.
        int cellIndex = (i % 3) * 3 +
            (j % 3); //to find the position of the cell within the 3x3 box.
        String text = boxInners[boxIndex].cellChars[cellIndex].text ?? '';
        board[i][j] = text.isEmpty ? 0 : int.parse(text);
      }
    }

    return board;
  }

  void _updateBoxInnersFromBoard(List<List<int>> board) {
    //!If the board is solved,
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        int boxIndex = (i ~/ 3) * 3 + (j ~/ 3);
        int cellIndex = (i % 3) * 3 + (j % 3);
        boxInners[boxIndex].cellChars[cellIndex].text = board[i][j].toString();
        boxInners[boxIndex].cellChars[cellIndex].isCorrect = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //! ui

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        actions: [
          ElevatedButton(
              onPressed: () => solveSudoku(), child: const Icon(Icons.check)),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () => generateSudoku(),
              child: const Icon(Icons.refresh)),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: Colors.blue.shade300,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                // height: 400,
                color: Colors.blueGrey,
                padding: const EdgeInsets.all(5),
                width: double.maxFinite,
                alignment: Alignment.center,
                child: GridView.builder(
                  itemCount: boxInners.length,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  physics: const ScrollPhysics(),
                  itemBuilder: (buildContext, index) {
                    BoxInner boxInner = boxInners[index];

                    return Container(
                      color: Colors.red.shade100,
                      alignment: Alignment.center,
                      child: GridView.builder(
                        itemCount: boxInner.cellChars.length,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        physics: const ScrollPhysics(),
                        itemBuilder: (buildContext, indexChar) {
                          CellCharacter blokChar =
                              boxInner.cellChars[indexChar];
                          Color color = Colors.red.shade50;
                          Color colorText = Colors.black;

                          if (isFinish) {
                            color = Colors.green;
                          } else if (blokChar.isFocus && blokChar.text != "")
                            color = Colors.blue.shade100;
                          else if (blokChar.isDefault)
                            color = Colors.grey.shade400;

                          if (tapBoxIndex == "$index-$indexChar" && !isFinish) {
                            color = Colors.blue.shade300;
                          }

                          if (isFinish) {
                            colorText = Colors.white;
                          } else if (blokChar.isExist) colorText = Colors.red;

                          return Container(
                            color: color,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: blokChar.isDefault
                                  ? null
                                  : () => setFocus(index, indexChar),
                              child: Text(
                                "${blokChar.text}",
                                style: TextStyle(color: colorText),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 200,
                width: 240, // Add width to the container
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        itemCount: 9,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (buildContext, index) {
                          return ElevatedButton(
                            onPressed: () => setInput(index + 1),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              minimumSize: const Size(10, 40),
                            ),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () => setInput(null),
                      icon: const Icon(Icons.backspace),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  generatePuzzle() {
    boxInners.clear(); //clear out old data
    var sudokuGenerator = SudokuGenerator(emptySquares: 54); //empty square
    // Quiver for easy populate collection using partition
    List<List<List<int>>> completes = partition(
            sudokuGenerator.newSudokuSolved,
            // contains the fully solved Sudoku puzzle 9x9;
            // partition divides this completed puzzle into 3x3 sections
            sqrt(sudokuGenerator.newSudoku.length)
                .toInt()) //calculates the size of each section
        .toList();
    partition(
            sudokuGenerator
                .newSudoku, // contains the puzzle with some empty spaces.
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList()
        .asMap()
        .entries
        .forEach(
      (entry) {
        // allows us to iterate over each section with both the index and the section data 3x3
        List<int> tempListCompletes = completes[entry.key]
            .expand((element) => element)
            .toList(); //full completed row1
        List<int> tempList =
            entry.value.expand((element) => element).toList(); //row1 with gaps

        tempList.asMap().entries.forEach((entryIn) {
          int index =
              entry.key * sqrt(sudokuGenerator.newSudoku.length).toInt() +
                  (entryIn.key % 9).toInt() ~/ 3; //index for each position

          if (boxInners.where((element) => element.index == index).isEmpty) {
            boxInners.add(BoxInner(index,
                [])); //If no BoxInner object with the specified index exists, a new BoxInner object is created and added to the boxInners list.
          }

          BoxInner boxInner =
              boxInners.where((element) => element.index == index).first;

          boxInner.cellChars.add(CellCharacter(
            entryIn.value == 0 ? "" : entryIn.value.toString(), //value null
            index: boxInner.cellChars.length,
            isDefault: entryIn.value != 0, //t or false
            isCorrect: entryIn.value != 0,
            correctText: tempListCompletes[entryIn.key].toString(),
          ));
        });
      },
    );

    //! complte generate puzzle sudoku
  }

  setFocus(int index, int indexChar) {
    //! set focus on cell
    tapBoxIndex = "$index-$indexChar";
    focusClass.setData(index, indexChar);
    showFocusCenterLine();
    setState(() {});
  }

  void showFocusCenterLine() {
    // set focus color for line vertical & horizontal
    //!blue line
    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    for (var element in boxInners) {
      element.clearFocus();
    }

    boxInners.where((element) => element.index ~/ 3 == rowNoBox).forEach(
        (e) => e.setFocus(focusClass.indexChar!, Direction.Horizontal));

    boxInners
        .where((element) => element.index % 3 == colNoBox)
        .forEach((e) => e.setFocus(focusClass.indexChar!, Direction.Vertical));
  }

  setInput(int? number) {
    // set input data based grid
    // or clear out data
    if (focusClass.indexBox == null) return;
    if (boxInners[focusClass.indexBox!].cellChars[focusClass.indexChar!].text ==
            number.toString() ||
        number == null) {
      for (var element in boxInners) {
        element.clearFocus();
        element.clearExist();
      }
      boxInners[focusClass.indexBox!]
          .cellChars[focusClass.indexChar!]
          .setEmpty();
      tapBoxIndex = null;
      isFinish = false;
      showSameInputOnSameLine();
      //!The function checks if a cell is focused (it is).
// It checks if the current value matches the input or is null (it doesn't).
// It clears any existing focus and highlights.
// It updates the focused cell to "5".
// It highlights any duplicates of "5" in the same row or column.
// It checks if the puzzle is finished.
// It updates the UI to reflect these changes.
    } else {
      boxInners[focusClass.indexBox!]
          .cellChars[focusClass.indexChar!]
          .setText("$number");

      showSameInputOnSameLine();

      checkFinish();
    }

    setState(() {});
  }

  void showSameInputOnSameLine() {
    //! 3 3 red
    // show duplicate number on same line vertical & horizontal so player know he or she put a wrong value on somewhere

    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    String textInput =
        boxInners[focusClass.indexBox!].cellChars[focusClass.indexChar!].text!;

    for (var element in boxInners) {
      element.clearExist();
    }

    boxInners.where((element) => element.index ~/ 3 == rowNoBox).forEach((e) =>
        e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput,
            Direction.Horizontal));

    boxInners.where((element) => element.index % 3 == colNoBox).forEach((e) =>
        e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput,
            Direction.Vertical));

    List<CellCharacter> exists = boxInners
        .map((element) => element.cellChars)
        .expand((element) => element)
        .where((element) => element.isExist)
        .toList();

    if (exists.length == 1) exists[0].isExist = false;
  }

  void checkFinish() {
    //! check if the game is finish
    int totalUnfinish = boxInners
        .map((e) => e.cellChars)
        .expand((element) => element)
        .where((element) => !element.isCorrect)
        .length;

    isFinish = totalUnfinish == 0;
  }
}

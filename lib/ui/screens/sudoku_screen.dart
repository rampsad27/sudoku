import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:sudoku/ui/widgets/boxChar.dart';
import 'package:sudoku/ui/widgets/boxInner.dart';
import 'package:sudoku/ui/widgets/flocusClass.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  //variable
  List<BoxInner> boxInners = [];
  FocusClass focusClass = FocusClass();
  bool isFinish = false;
  String? tapBoxIndex;
  @override
  void initState() {
    super.initState();
    generateSudoku();
  }

  void generateSudoku() {
    isFinish = false;
    focusClass = FocusClass();
    tapBoxIndex = null;
    checkFinish();
    generatePuzzle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          ElevatedButton(
              onPressed: () => generatePuzzle(),
              child: const Icon(Icons.refresh_outlined)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: boxInners.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                physics: const ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  BoxInner boxInner = boxInners[index];
                  return GridView.builder(
                    itemCount: boxInner.blokChars.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      BlokChar blokChar = boxInner.blokChars[index];
                      return Container(
                        color: Colors.orangeAccent,
                        child: Center(child: Text("${blokChar.text}")),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: GridView.builder(
                    itemCount: 9,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return ElevatedButton(
                          onPressed: () {}, child: Text("${index + 1}"));
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.backspace_outlined))
              ],
            ),
          ],
        ),
      ),
    );
  }

  generatePuzzle() {
    boxInners.clear();
    //quiver for wasy population
    var sudokuGenerator = SudokuGenerator(emptySquares: 54);
    List<List<List<int>>> completes = partition(sudokuGenerator.newSudokuSolved,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList();
    partition(sudokuGenerator.newSudoku,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList()
        .asMap()
        .entries
        .forEach((entry) {
      List<int> tempListConpletes =
          completes[entry.key].expand((element) => element).toList();
      List<int> tempList = entry.value.expand((element) => element).toList();
      tempList.asMap().entries.forEach((entryIn) {
        int index = entry.key * sqrt(sudokuGenerator.newSudoku.length).toInt() +
            (entryIn.key % 9).toInt() ~/ 3;

        if (boxInners.where((element) => element.index == index).isEmpty) {
          boxInners.add(BoxInner(index, []));
        }
        BoxInner boxInner =
            boxInners.where((element) => element.index == index).first;

        boxInner.blokChars.add(BlokChar(
          entryIn.value == 0 ? "" : entryIn.value.toString(),
          index: boxInner.blokChars.length,
          isDefault: entryIn.value != 0,
          isCorrect: entryIn.value != 0,
          correctText: tempListConpletes[entryIn.key].toString(),
        ));
      });
    });
    print(boxInners);
  }

  void checkFinish() {}
}

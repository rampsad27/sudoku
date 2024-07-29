import 'package:sudoku/ui/widgets/cellCharacter.dart';

class BoxInner {
  late int index;
  List<CellCharacter> cellChars = List<CellCharacter>.from([]);

  BoxInner(this.index, this.cellChars);

  // declare method used

  setFocus(int index, Direction direction) {
    //! blue color focus on row and column
    List<CellCharacter> temp;

    if (direction == Direction.Horizontal) {
      temp = cellChars
          .where((element) => element.index! ~/ 3 == index ~/ 3)
          .toList();
    } else {
      temp = cellChars
          .where((element) => element.index! % 3 == index % 3)
          .toList();
    }

    for (var element in temp) {
      element.isFocus = true;
    }
  }

  setExistValue(
      int index, int indexBox, String textInput, Direction direction) {
    List<CellCharacter> temp;
//! check is nu value exist in row and column and cell
    if (direction == Direction.Horizontal) {
      temp = cellChars
          .where((element) => element.index! ~/ 3 == index ~/ 3)
          .toList();
    } else {
      temp = cellChars
          .where((element) => element.index! % 3 == index % 3)
          .toList();
    }

    temp.where((element) => element.text == textInput).forEach((element) {
      element.isExist = true;
    });
  }

  clearFocus() {
    //!remove existing dark blue color from cell
    for (var element in cellChars) {
      element.isFocus = false;
    }
  }

  clearExist() {
    //! remove existing blue color from row/column
    for (var element in cellChars) {
      element.isExist = false;
    }
  }
}

enum Direction { Horizontal, Vertical }

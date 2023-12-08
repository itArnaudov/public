# Chess Game in C++

This is a simple console-based Chess Game implemented in C++. The program allows players to make moves on the chessboard and includes basic move validation rules for pawns, rooks, knights, bishops, queens, and kings.

## Table of Contents

- [Features](#features)
- [How to Run](#how-to-run)
- [Game Rules](#game-rules)
- [Example Moves](#example-moves)
- [Contributing](#contributing)
- [License](#license)

## Features

- Console-based chess game.
- Support for moves by pawns, rooks, knights, bishops, queens, and kings.
- Basic move validation rules for each piece type.

## How to Run

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/itArnaudov/public.git
    cd chess-game-cpp
    ```

2. **Compile and Run:**

    ```bash
    g++ chess_game.cpp -o chess_game
    ./chess_game
    ```

3. **Follow On-Screen Instructions:**

    The program will prompt you to make moves on the chessboard. Enter the source and destination positions as instructed.

## Game Rules

- Pawns move forward one square, capturing diagonally.
- Rooks move horizontally or vertically.
- Knights move in an L-shape: two squares in one direction and one square perpendicular.
- Bishops move diagonally.
- Queens can move horizontally, vertically, or diagonally.
- Kings move one square in any direction.

## Example Moves

Here are some example moves to get you started:

1. Move a black pawn forward:

    ```cpp
    chessBoard.makeMove(6, 0, 4, 0);
    ```

2. Move a white pawn forward:

    ```cpp
    chessBoard.makeMove(1, 0, 3, 0);
    ```

3. Move a black knight:

    ```cpp
    chessBoard.makeMove(7, 1, 5, 2);
    ```

## Contributing

Contributions are welcome! If you'd like to improve this Chess Game or add new features, feel free to submit a pull request.

## License

This Chess Game is open-source software licensed under the [MIT License](LICENSE).
#
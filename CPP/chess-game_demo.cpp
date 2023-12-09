#include <iostream>
#include <vector>

// Enumerations for different types of chess pieces and their colors
enum class PieceType {
    Pawn,
    Rook,
    Knight,
    Bishop,
    Queen,
    King
};

enum class PieceColor {
    White,
    Black
};

// Structure representing a chess piece
struct ChessPiece {
    PieceType type;
    PieceColor color;
};

// Class representing the chessboard
class ChessBoard {
private:
    std::vector<std::vector<ChessPiece>> board;

public:
    // Constructor to initialize the chessboard
    ChessBoard() : board(8, std::vector<ChessPiece>(8)) {
        initializeBoard();
    }

    // Function to set up the initial configuration of the chessboard
    void initializeBoard() {
        for (int i = 0; i < 8; ++i) {
            board[1][i] = {PieceType::Pawn, PieceColor::White};
            board[6][i] = {PieceType::Pawn, PieceColor::Black};
        }

        initializePieces(0, PieceColor::White);
        initializePieces(7, PieceColor::Black);
    }

    // Function to set up the initial configuration of pieces for a given row and color
    void initializePieces(int row, PieceColor color) {
        board[row][0] = {PieceType::Rook, color};
        board[row][1] = {PieceType::Knight, color};
        board[row][2] = {PieceType::Bishop, color};
        board[row][3] = {PieceType::Queen, color};
        board[row][4] = {PieceType::King, color};
        board[row][5] = {PieceType::Bishop, color};
        board[row][6] = {PieceType::Knight, color};
        board[row][7] = {PieceType::Rook, color};
    }

    // Function to display the current state of the chessboard
    void displayBoard() {
        for (int i = 0; i < 8; ++i) {
            for (int j = 0; j < 8; ++j) {
                if (board[i][j].type == PieceType::Pawn) {
                    std::cout << (board[i][j].color == PieceColor::White ? "P" : "p") << " ";
                } else if (board[i][j].type == PieceType::Rook) {
                    std::cout << (board[i][j].color == PieceColor::White ? "R" : "r") << " ";
                } else if (board[i][j].type == PieceType::Knight) {
                    std::cout << (board[i][j].color == PieceColor::White ? "N" : "n") << " ";
                } else if (board[i][j].type == PieceType::Bishop) {
                    std::cout << (board[i][j].color == PieceColor::White ? "B" : "b") << " ";
                } else if (board[i][j].type == PieceType::Queen) {
                    std::cout << (board[i][j].color == PieceColor::White ? "Q" : "q") << " ";
                } else if (board[i][j].type == PieceType::King) {
                    std::cout << (board[i][j].color == PieceColor::White ? "K" : "k") << " ";
                } else {
                    std::cout << ". ";
                }
            }
            std::cout << std::endl;
        }
    }

    // Function to check if a position is within the board's bounds
    bool isValidPosition(int x, int y) const {
        return x >= 0 && x < 8 && y >= 0 && y < 8;
    }

    // Function to check if a position is occupied by a piece
    bool isOccupied(int x, int y) const {
        return isValidPosition(x, y) && board[x][y].type != PieceType::Pawn;
    }

    // Function to check if a move from one position to another is valid for a given piece
    bool isValidMove(int fromX, int fromY, int toX, int toY) const {
        // Check if positions are valid
        if (!isValidPosition(fromX, fromY) || !isValidPosition(toX, toY)) {
            return false;
        }

        // Check if there is a piece at the starting position
        if (!isOccupied(fromX, fromY)) {
            return false;
        }

        // Check specific move rules based on piece type
        ChessPiece piece = board[fromX][fromY];

        switch (piece.type) {
            case PieceType::Pawn:
                return isValidPawnMove(fromX, fromY, toX, toY);
            case PieceType::Rook:
                return isValidRookMove(fromX, fromY, toX, toY);
            case PieceType::Knight:
                return isValidKnightMove(fromX, fromY, toX, toY);
            case PieceType::Bishop:
                return isValidBishopMove(fromX, fromY, toX, toY);
            case PieceType::Queen:
                return isValidQueenMove(fromX, fromY, toX, toY);
            case PieceType::King:
                return isValidKingMove(fromX, fromY, toX, toY);
            default:
                return false;
        }
    }

    // Function to check if a pawn move from one position to another is valid
    bool isValidPawnMove(int fromX, int fromY, int toX, int toY) const {
        // Pawn can move one square forward (if not occupied)
        if (board[fromX][fromY].color == PieceColor::White) {
            return toX == fromX - 1 && toY == fromY && !isOccupied(toX, toY);
        } else {
            return toX == fromX + 1 && toY == fromY && !isOccupied(toX, toY);
        }
    }

    // Function to check if a rook move from one position to another is valid
    bool isValidRookMove(int fromX, int fromY, int toX, int toY) const {
        // Rook can move horizontally or vertically
        return (fromX == toX || fromY == toY) && !isOccupied(toX, toY);
    }

    // Function to check if a knight move from one position to another is valid
    bool isValidKnightMove(int fromX, int fromY, int toX, int toY) const {
        // Knight moves in an L-shape: two squares in one direction and one square perpendicular
        int dx = abs(toX - fromX);
        int dy = abs(toY - fromY);
        return (dx == 2 && dy == 1) || (dx == 1 && dy == 2);
    }

    // Function to check if a bishop move from one position to another is valid
    bool isValidBishopMove(int fromX, int fromY, int toX, int toY) const {
        // Bishop moves diagonally
        return abs(toX - fromX) == abs(toY - fromY) && !isOccupied(toX, toY);
    }

    // Function to check if a queen move from one position to another is valid
    bool isValidQueenMove(int fromX, int fromY, int toX, int toY) const {
        // Queen can move horizontally, vertically, or diagonally
        return (fromX == toX || fromY == toY || abs(toX - fromX) == abs(toY - fromY)) && !isOccupied(toX, toY);
    }

    // Function to check if a king move from one position to another is valid
    bool isValidKingMove(int fromX, int fromY, int toX, int toY) const {
        // King can move one square in any direction
        int dx = abs(toX - fromX);
        int dy = abs(toY - fromY);
        return (dx == 1 || dx == 0) && (dy == 1 || dy == 0) && !isOccupied(toX, toY);
    }

    // Function to make a move on the chessboard
    void makeMove(int fromX, int fromY, int toX, int toY) {
        // Check if the move is valid
        if (!isValidMove(fromX, fromY, toX, toY)) {
            std::cout << "Invalid move. Please enter a valid move." << std::endl;
            return;
        }

        // Perform the move
        board[toX][toY] = board[fromX][fromY];
        board[fromX][fromY] = {}; // Empty the starting position

        std::cout << "Move successful!" << std::endl;
    }
};

// Main function
int main() {
    // Create a chessboard
    ChessBoard chessBoard;
    chessBoard.displayBoard();

    // Example moves
    chessBoard.makeMove(6, 0, 4, 0); // Black pawn moves forward
    chessBoard.displayBoard();

    chessBoard.makeMove(1, 0, 3, 0); // White pawn moves forward
    chessBoard.displayBoard();

    chessBoard.makeMove(7, 1, 5, 2); // Black knight moves
    chessBoard.displayBoard();

    return 0;
}
//
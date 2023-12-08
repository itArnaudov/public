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

//
int main() {
    ChessBoard chessBoard;
    chessBoard.displayBoard();

    return 0;
}
//
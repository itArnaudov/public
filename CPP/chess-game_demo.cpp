#include <iostream>
#include <vector>

// Define chess piece types
enum class PieceType {
    Pawn,
    Rook,
    Knight,
    Bishop,
    Queen,
    King
};

// Define chess piece colors
enum class PieceColor {
    White,
    Black
};

// Define a chess piece
struct ChessPiece {
    PieceType type;
    PieceColor color;
};

// Define a chess board
class ChessBoard {
private:
    std::vector<std::vector<ChessPiece>> board;

public:
    ChessBoard() : board(8, std::vector<ChessPiece>(8)) {
        initializeBoard();
    }

    // Function to initialize the chess board with pieces
    void initializeBoard() {
        // Initialize pawns
        for (int i = 0; i < 8; ++i) {
            board[1][i] = {PieceType::Pawn, PieceColor::White};
            board[6][i] = {PieceType::Pawn, PieceColor::Black};
        }

        // Initialize other pieces
        initializePieces(0, PieceColor::White);
        initializePieces(7, PieceColor::Black);
    }

    // Function to initialize non-pawn pieces on a row
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

    // Function to display the chess board
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
};
//
int main() {
    ChessBoard chessBoard;
    chessBoard.displayBoard();

    return 0;
}
//
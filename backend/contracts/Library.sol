// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//signer :  0x6b91318da72D33CaD5f71502101bCD7563068dFe
// deployed at : 0x612721395Dcf3A14B5535C3617f89929864E76aB

contract Library {
    struct Book {
        uint256 id;
        string title;
        address borrower;
        bool checkedOut;
    }

    struct User {
        address id;
        string name;
        uint256[] borrowedBooks;
    }

    mapping(uint256 => Book) public books;
    mapping(address => User) public users;
    uint256 public totalBooks;
    uint256 public totalUsers;

    event BookAdded(uint256 indexed bookId, string title);
    event BookCheckedOut(uint256 indexed bookId, address indexed borrower);
    event BookReturned(uint256 indexed bookId);
    event UserAdded(address indexed userId, string name);

    constructor() {
        totalBooks = 0;
        totalUsers = 0;
    }

    function addBook(string memory _title) external {
        totalBooks++;
        books[totalBooks] = Book(totalBooks, _title, address(0), false);
        emit BookAdded(totalBooks, _title);
    }

    function addUser(string memory _name) external {
        totalUsers++;
        users[msg.sender] = User(msg.sender, _name, new uint256[](0));
        emit UserAdded(msg.sender, _name);
    }

    function checkOut(uint256 _bookId) external {
        require(_bookId <= totalBooks && _bookId > 0, "Invalid book ID");
        require(!books[_bookId].checkedOut, "Book already checked out");
        require(users[msg.sender].id != address(0), "User does not exist");

        books[_bookId].borrower = msg.sender;
        books[_bookId].checkedOut = true;
        users[msg.sender].borrowedBooks.push(_bookId);

        emit BookCheckedOut(_bookId, msg.sender);
    }

    function returnBook(uint256 _bookId) external {
        require(_bookId <= totalBooks && _bookId > 0, "Invalid book ID");
        require(books[_bookId].checkedOut, "Book is not checked out");
        require(books[_bookId].borrower == msg.sender, "You are not the borrower");

        books[_bookId].borrower = address(0);
        books[_bookId].checkedOut = false;

        // Remove the book from the borrower's borrowedBooks array
        uint256[] storage borrowedBooks = users[msg.sender].borrowedBooks;
        for (uint256 i = 0; i < borrowedBooks.length; i++) {
            if (borrowedBooks[i] == _bookId) {
                borrowedBooks[i] = borrowedBooks[borrowedBooks.length - 1];
                borrowedBooks.pop();
                break;
            }
        }

        emit BookReturned(_bookId);
    }

    function getUserBorrowedBooks(address _userId) external view returns (uint256[] memory) {
        return users[_userId].borrowedBooks;
    }

    function getBookInfo(uint256 _bookId) external view returns (uint256, string memory, address, bool) {
        require(_bookId <= totalBooks && _bookId > 0, "Invalid book ID");
        Book memory book = books[_bookId];
        return (book.id, book.title, book.borrower, book.checkedOut);
    }
}

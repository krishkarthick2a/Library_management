// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//token address :  0xB7e2038753547602893c9a4c7C9D5CCE358b93b3
// deployed at : 0x6d92Cf4bD6205cFd7C1309D6EBA65A11D8c49ce7
contract Library {
    struct Book {
        uint256 id;
        string title;
        uint256 price;
        address borrower;
        bool checkedOut;
    }

    struct User {
        address id;
        string name;
        uint256 balance;
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
    address public token;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    constructor(address _ERC20_ContractAddress) {
        owner = msg.sender;
        token = _ERC20_ContractAddress;
            totalBooks = 0;
            totalUsers = 0;
    }
    

    function addBook(string memory _title, uint256 _price) external onlyOwner {
        totalBooks++;
        books[totalBooks] = Book(totalBooks, _title, _price, address(0), false);
        emit BookAdded(totalBooks, _title);
    }

    function addUser(string memory _name,address _Id, uint256 _tokens ) external onlyOwner returns(bool){
        totalUsers++;
        IERC20(token).transferFrom(owner,_Id, _tokens);
        users[_Id] = User(_Id, _name,_tokens,  new uint256[](0));
        emit UserAdded(msg.sender, _name);
        return true;
    }

    function BookIssue(uint256 _bookId) external {
        require(_bookId <= totalBooks && _bookId > 0, "Invalid book ID");
        require(!books[_bookId].checkedOut, "Book already checked out");
        require(users[msg.sender].id != address(0), "User does not exist");
        address _Id = users[msg.sender].id;
        uint256 bookFee = books[_bookId].price;
         IERC20(token).transferFrom(_Id, owner, bookFee);
        books[_bookId].borrower = msg.sender;
        books[_bookId].checkedOut = true;
        users[msg.sender].balance-= bookFee;
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
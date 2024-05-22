// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyBookStore {
    //address of the owner of the contract
    address public owner;
    //cost for having a premium membership
    uint256 public premiumPrice;

    //struct containing the details of a book and if its a premium book or not
    struct Book {
        string author;
        string title;
        uint256 id;
        bool isPremium;
    }
    //array of structs that allows the owner of the contract store books
    Book[] public books;
    //a mapping of address to boolean showing whether the owner of the address has a premium plan or not
    mapping(address => bool) public premiumMembers;

    //constructor that allows the owner of the contract set a price for the premium plan and sets the owner to the person that deploys the contract
    constructor(uint256 _premiumPrice) {
        owner = msg.sender;
        premiumPrice = _premiumPrice;
    }

    //a modifier that restricts some functions to be called by only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    //a modifier that restricts some functions to be called by only users with premium plan
    modifier onlyPremium() {
        require(premiumMembers[msg.sender], "Only premium members can perform this action");
        _;
    }

    //function that allows the owner of the contract add books to the array whether premiuim books or not
    function addBook(string memory _author, string memory _title, uint256 _id, bool _isPremium) public onlyOwner {
        books.push(Book(_author, _title, _id, _isPremium));
    }

    //function that allows users purchase a premium membership by sending the amount of money specified as the premiumPrice
    function buyPremium() public payable {
        require(msg.value == premiumPrice, "Incorrect payment amount");
        premiumMembers[msg.sender] = true;
    }

    //an event that lets the front end know the address of the user that called the getBook function, the details of the book they want to access and if they are premium users or not
    event bookAccessed(address indexed user, string author, string title, bool isPremium, uint256 id);

    //allows user access the details of a book
    function getBook(uint256 _index) public payable returns (string memory author, string memory title, uint256 id, bool isPremium) {
        Book storage book = books[_index];
        emit bookAccessed(msg.sender, book.author, book.title, book.isPremium, book.id);
        if (book.isPremium) {
            require(premiumMembers[msg.sender], "This book is only available for premium members");
        }
        return (book.author, book.title, book.id, book.isPremium);
      
    }
   
    //allows the owner of the contract to withdraw the money paid by premium users
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    //allows the owner of the contract to change the premium price
    function setNewPremiumPrice(uint256 _newPrice) public onlyOwner {
        premiumPrice = _newPrice;
    }
}

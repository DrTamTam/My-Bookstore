// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract MyBookStore{
    //a state variable of the address of the owner
    address public owner;
    //a state variable of the premium price
    uint256 public premiumPrice;

    //a struct that stores information about the book
    struct Book{
        string author;
        string title;
        uint256 id;
        bool isPremium;
    }

    //an array of struct for the books to be stored in
    Book[] public books;

    //a mapping that shows if a user is a premium member
    mapping(address => bool) public premiumUser;

    //a constructor that allows the owner of the contract to set the premium price
    constructor(uint256 _premiumPrice){
        owner = msg.sender;
        premiumPrice = _premiumPrice;
    }

    //a function modifier that requires only the owner to perform some actions
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    //a function modifier that allows only premium users perform an action
    modifier onlyPremium(){
        require(premiumUser[msg.sender], "Only premium users can perform this action, buy premium plan");
        _;
    }

    //a function that allows the owner of the contract push books to the array
    function addBooks(string memory _author, string memory _title, uint256 _id, bool _isPremium) public onlyOwner{
        books.push(Book(_author, _title, _id, _isPremium));
    }

    //a function that allows users purchase a premium membership
    function buyPremium() public payable{
        require(msg.value == premiumPrice, "Incorrect price");
        premiumUser[msg.sender] = true;
    }

    //an event that lets the front end know the address of the person getting the book and the details of the book
    //indexed is used in events and it allows parameters to be included in the ethereum logs topic
    event bookAccessed(address indexed user, string author, string title, uint256 id, bool isPremium);

    //a function that allows the user buy a book and allows only premium members buy premium books, also allows user view the book they are buying
    function getBook(uint _index) public payable returns(string memory author, string memory title, uint256 id, bool isPremium){
        //a new variable that will contain the details of the book and that will be stored in storage
        Book storage book = books[_index];
        //emit the event
        emit bookAccessed(msg.sender, book.author, book.title, book.id, book.isPremium);
        //allow only premium users access premium books
        if(book.isPremium){
            require(premiumUser[msg.sender], "Only premium users have access to this book, buy premium plan");
        }
        return(book.author, book.title, book.id, book.isPremium);
    }

    //a function that allows the owner of the contract set a new premium price
    function newPremiumPrice(uint256 _newPrice) public onlyOwner{
        premiumPrice = _newPrice;
    }

    //function that allows owner of contract withdraw all the money paid by premium users
    function withdraw() public onlyOwner{
        payable(owner).transfer(address(this).balance);
    }
}

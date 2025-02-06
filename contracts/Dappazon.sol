// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;
    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint256 cost, uint256 quantity);

    modifier onlyOwner() {
        require((msg.sender == owner), "Only the owner can list products");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //List Products
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        //create the item struct
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        //save the item to the blockchain
        items[_id] = item;
        //Emit an event
        emit List(_name, _cost, _stock);
    }

    // Buy Products

    function buy(uint256 _id) public payable {
        Item memory item = items[_id];

        require(msg.value >= item.cost,"Insufficient funds");
        require(item.stock > 0,"Out of stock");
        


        //create an order
        Order memory order = Order(block.timestamp, item);

        //save the order to chain
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        //Subtract stock
        items[_id].stock = item.stock - 1;
        //emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    //Withdraw funds
    function withdraw() public onlyOwner{
        (bool success,) = owner.call{value:address(this).balance}("");
        require(success);
    }
}

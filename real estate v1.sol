// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Main {
    mapping(uint256 => House) houses;
    mapping(uint256 => Flat) flats;
    mapping(uint256 => Commercial) commercial;
    mapping(uint256 => Land) land;
    address payable public owner;
    uint private counter;
    
    
    constructor() {
        owner = payable(msg.sender);
        counter = 0;
    }
    
    function AddHouse (
        uint _bedrooms, 
        uint _bathrooms, 
        uint _sqrFootLand, 
        uint _floors, 
        string memory _country, 
        string memory _city, 
        bool _forSale, 
        uint _price) public {
            
        House house = new House(_bedrooms, _bathrooms, _sqrFootLand, _floors, _country, _city, _forSale, _price); // creates new House and returns contract address
        counter++;
        uint256 houseId = uint(keccak256(abi.encodePacked(msg.sender, keccak256(abi.encodePacked(counter))))); // creates a unique id for the house
        houses[houseId] = house;
        emit NewHouse(houseId, house, msg.sender);
    }
    
    function AddHouse (
        uint _bedrooms, 
        uint _bathrooms, 
        uint _floor, 
        string memory _country, 
        string memory _city, 
        bool _forSale, 
        uint _price) public {
            
        Flat flat = new Flat(_bedrooms, _bathrooms,  _floor, _country, _city, _forSale, _price); // creates new House and returns contract address
        counter++;
        uint256 flatId = uint(keccak256(abi.encodePacked(msg.sender, keccak256(abi.encodePacked(counter))))); // creates a unique id for the house
        flats[flatId] = flat;
        emit NewFlat(flatId, flat, msg.sender);
    }
    
    function buyHouse(uint houseId) public payable {
        House house = houses[houseId];
        house.changeOwner{value: msg.value}(msg.sender); 
    }
    
    function buyFlat(uint flatId) public payable {
        Flat flat = flats[flatId];
        flat.changeOwner{value: msg.value}(msg.sender); 
    }
    
    event NewHouse(uint256 houseId, House house, address owner);
    event NewFlat(uint256 flatId, Flat flat, address owner);
}

contract House{
    
    address payable private houseOwner;
    uint256 noOfBedrooms;
    uint256 noOfBathrooms;
    uint256 sqrFootLand;
    uint256 noOfFloors;
    string country;
    string city;
    
    bool forSale;
    uint256 sellingPrice;
    uint256 lastSoldPrice;
    address lastOwner;
    
    constructor (
        uint _bedrooms, 
        uint _bathrooms, 
        uint _sqrFootLand, 
        uint _floors, 
        string memory _country, 
        string memory _city, 
        bool _forSale, 
        uint _price){
            
        houseOwner = payable(msg.sender);
        noOfBedrooms = _bedrooms;
        noOfBathrooms = _bathrooms;
        sqrFootLand = _sqrFootLand;
        noOfFloors = _floors;
        country = _country;
        city = _city;
        forSale = _forSale;
        if(forSale = true){sellingPrice = _price;}
    }
    
    modifier onlyOwner (address _caller){
        require(_caller== houseOwner,"Only the owner can call this function");
        _;
    }
    
    modifier isForSale{
        require(forSale = true);
        _;
    }
    
    
    function getDetails() public view returns(uint,uint,uint,uint,string memory,string memory,bool,uint){
        return (noOfBedrooms, noOfBathrooms, noOfFloors, sqrFootLand, country, city, forSale, sellingPrice);
    }
    
    function setPrice(uint _newPrice, address _caller) external onlyOwner(_caller){
        sellingPrice = _newPrice;
    }
    
    function setSaleState(bool _state, address _caller) external onlyOwner(_caller) {
        forSale = _state;
    }
    
    function changeOwner (address _caller) isForSale public payable {
        if(msg.value < sellingPrice){
            payable(_caller).transfer(msg.value);
            revert("Not enough ether was sent");
        }
        houseOwner.transfer(msg.value);
        lastOwner = houseOwner;
        houseOwner = payable(_caller);
        forSale = false;
        lastSoldPrice = sellingPrice;
        sellingPrice = 0;
        emit ChangedOwner(lastOwner, lastSoldPrice);
    }
    event ChangedOwner(address lastOwner, uint soldPrice);
    
    
}

contract Flat {
    
    address payable private houseOwner;
    uint256 noOfBedrooms;
    uint256 noOfBathrooms;
    uint256 floor;
    string country;
    string city;
    
    bool forSale;
    uint256 sellingPrice;
    uint256 lastSoldPrice;
    address lastOwner;
    
     constructor (
        uint _bedrooms, 
        uint _bathrooms, 
        uint _floor, 
        string memory _country, 
        string memory _city, 
        bool _forSale, 
        uint _price){
            
        houseOwner = payable(msg.sender);
        noOfBedrooms = _bedrooms;
        noOfBathrooms = _bathrooms;
        floor = _floor;
        country = _country;
        city = _city;
        forSale = _forSale;
        if(forSale = true){sellingPrice = _price;}
    }
    
    
    
      modifier onlyOwner (address _caller){
        require(_caller== houseOwner,"Only the owner can call this function");
        _;
    }
    
    modifier isForSale{
        require(forSale = true);
        _;
    }
    
    
    function getDetails() public view returns(uint,uint,uint,string memory,string memory,bool,uint){
        return (noOfBedrooms, noOfBathrooms, floor, country, city, forSale, sellingPrice);
    }
    
    function setPrice(uint _newPrice, address _caller) external onlyOwner(_caller){
        sellingPrice = _newPrice;
    }
    
    function setSaleState(bool _state, address _caller) external onlyOwner(_caller) {
        forSale = _state;
    }
    
    function changeOwner (address _caller) isForSale public payable {
        if(msg.value < sellingPrice){
            payable(_caller).transfer(msg.value);
            revert("Not enough ether was sent");
        }
        houseOwner.transfer(msg.value);
        lastOwner = houseOwner;
        houseOwner = payable(_caller);
        forSale = false;
        lastSoldPrice = sellingPrice;
        sellingPrice = 0;
        emit ChangedOwner(lastOwner, lastSoldPrice);
    }
    event ChangedOwner(address lastOwner, uint soldPrice);
}


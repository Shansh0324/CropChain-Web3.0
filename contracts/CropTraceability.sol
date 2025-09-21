// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CropTraceability {
    struct Crop {
        uint256 cropTypeId;        // The crop type (1=Rice, 2=Wheat, etc.)
        string name;               // Crop name
        string manufacturer;       // Farmer/Producer name
        string batchNumber;        // Unique batch number
        address owner;             // Current owner
        uint256 registrationTime;  // Timestamp of registration
        uint256 quantity;          // Quantity in kg/units
        uint256 price;             // Price per unit
    }

    // Mapping from unique batch number to crop details
    mapping(string => Crop) public crops;
    
    // Array to store all registered batch numbers
    string[] public allBatchNumbers;
    
    // Mapping from crop type ID to array of batch numbers
    mapping(uint256 => string[]) public cropTypeToBatches;
    
    // Counter for total registrations
    uint256 public totalRegistrations;
    
    // Events
    event CropRegistered(
        string indexed batchNumber,
        uint256 indexed cropTypeId,
        string name,
        string manufacturer,
        address owner,
        uint256 quantity,
        uint256 price
    );
    
    event OwnershipTransferred(
        string indexed batchNumber,
        address indexed previousOwner,
        address indexed newOwner
    );

    // Register a new crop with unique batch number
    function registerCrop(
        uint256 _cropTypeId,
        string memory _name,
        string memory _manufacturer,
        string memory _batchNumber,
        uint256 _quantity,
        uint256 _price
    ) public {
        // Check if batch number already exists
        require(bytes(crops[_batchNumber].batchNumber).length == 0, "Batch number already exists");
        
        // Create new crop
        Crop memory newCrop = Crop({
            cropTypeId: _cropTypeId,
            name: _name,
            manufacturer: _manufacturer,
            batchNumber: _batchNumber,
            owner: msg.sender,
            registrationTime: block.timestamp,
            quantity: _quantity,
            price: _price
        });
        
        // Store the crop
        crops[_batchNumber] = newCrop;
        
        // Add to arrays
        allBatchNumbers.push(_batchNumber);
        cropTypeToBatches[_cropTypeId].push(_batchNumber);
        
        // Increment counter
        totalRegistrations++;
        
        // Emit event
        emit CropRegistered(
            _batchNumber,
            _cropTypeId,
            _name,
            _manufacturer,
            msg.sender,
            _quantity,
            _price
        );
    }

    // Get crop details by batch number
    function getCropByBatch(string memory _batchNumber) public view returns (
        uint256 cropTypeId,
        string memory name,
        string memory manufacturer,
        string memory batchNumber,
        address owner,
        uint256 registrationTime,
        uint256 quantity,
        uint256 price
    ) {
        require(bytes(crops[_batchNumber].batchNumber).length > 0, "Crop not found");
        Crop memory crop = crops[_batchNumber];
        return (
            crop.cropTypeId,
            crop.name,
            crop.manufacturer,
            crop.batchNumber,
            crop.owner,
            crop.registrationTime,
            crop.quantity,
            crop.price
        );
    }

    // Get all batch numbers for a specific crop type
    function getBatchesByCropType(uint256 _cropTypeId) public view returns (string[] memory) {
        return cropTypeToBatches[_cropTypeId];
    }

    // Get all registered batch numbers
    function getAllBatchNumbers() public view returns (string[] memory) {
        return allBatchNumbers;
    }

    // Get total number of registrations
    function getTotalRegistrations() public view returns (uint256) {
        return totalRegistrations;
    }

    // Transfer ownership of a crop
    function transferOwnership(string memory _batchNumber, address _newOwner) public {
        require(bytes(crops[_batchNumber].batchNumber).length > 0, "Crop not found");
        require(crops[_batchNumber].owner == msg.sender, "You are not the owner");
        
        address previousOwner = crops[_batchNumber].owner;
        crops[_batchNumber].owner = _newOwner;
        
        emit OwnershipTransferred(_batchNumber, previousOwner, _newOwner);
    }

    // Transfer ownership and update manufacturer name
    function transferOwnershipWithName(
        string memory _batchNumber, 
        address _newOwner, 
        string memory _newManufacturer
    ) public {
        require(bytes(crops[_batchNumber].batchNumber).length > 0, "Crop not found");
        require(crops[_batchNumber].owner == msg.sender, "You are not the owner");
        
        address previousOwner = crops[_batchNumber].owner;
        crops[_batchNumber].owner = _newOwner;
        crops[_batchNumber].manufacturer = _newManufacturer;
        
        emit OwnershipTransferred(_batchNumber, previousOwner, _newOwner);
    }

    // Update manufacturer name (only current owner can do this)
    function updateManufacturer(string memory _batchNumber, string memory _newManufacturer) public {
        require(bytes(crops[_batchNumber].batchNumber).length > 0, "Crop not found");
        require(crops[_batchNumber].owner == msg.sender, "You are not the owner");
        
        crops[_batchNumber].manufacturer = _newManufacturer;
    }

    // Update price (only current owner can do this)
    function updatePrice(string memory _batchNumber, uint256 _newPrice) public {
        require(bytes(crops[_batchNumber].batchNumber).length > 0, "Crop not found");
        require(crops[_batchNumber].owner == msg.sender, "You are not the owner");
        
        crops[_batchNumber].price = _newPrice;
    }

    // Check if batch number exists
    function batchExists(string memory _batchNumber) public view returns (bool) {
        return bytes(crops[_batchNumber].batchNumber).length > 0;
    }

    // Get crop count by type
    function getCropCountByType(uint256 _cropTypeId) public view returns (uint256) {
        return cropTypeToBatches[_cropTypeId].length;
    }
}

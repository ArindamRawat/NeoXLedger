// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PropertyManager {

    struct Property {
        string title;
        string description;
        uint256 price;
    }

    struct Properties {
        Property[] userProperties;
    }

    mapping(address => Properties) private userProperties;

    event PropertyCreated(address indexed user, string title);
    event PropertyPriceUpdated(address indexed user, string title, uint256 newPrice);
    event PropertyRemoved(address indexed user, string title);

    modifier onlyOwner(address user) {
        require(msg.sender == user, "You are not the owner of this account.");
        _;
    }

    /// Create a new property for the user's account
    function createProperty(
        string memory title,
        string memory description,
        uint256 price
    ) public {
        address user = msg.sender;

        // Create a new property and add it to the user's property list
        Properties storage properties = userProperties[user];
        properties.userProperties.push(Property(title, description, price));

        emit PropertyCreated(user, title);
    }

    /// Update the price of a property with the given title
    function updatePropertyPrice(
        address user,
        string memory title,
        uint256 newPrice
    ) public onlyOwner(user) {
        Properties storage properties = userProperties[user];
        bool propertyFound = false;

        for (uint256 i = 0; i < properties.userProperties.length; i++) {
            if (keccak256(abi.encodePacked(properties.userProperties[i].title)) == keccak256(abi.encodePacked(title))) {
                properties.userProperties[i].price = newPrice;
                propertyFound = true;
                emit PropertyPriceUpdated(user, title, newPrice);
                break;
            }
        }

        require(propertyFound, "Property with the given title not found.");
    }

    /// Remove a property with the given title
    function removeProperty(address user, string memory title) public onlyOwner(user) {
        Properties storage properties = userProperties[user];
        bool propertyFound = false;

        for (uint256 i = 0; i < properties.userProperties.length; i++) {
            if (keccak256(abi.encodePacked(properties.userProperties[i].title)) == keccak256(abi.encodePacked(title))) {
                properties.userProperties[i] = properties.userProperties[properties.userProperties.length - 1];
                properties.userProperties.pop();
                propertyFound = true;
                emit PropertyRemoved(user, title);
                break;
            }
        }

        require(propertyFound, "Property with the given title not found.");
    }

    /// Retrieve all properties associated with the user's account
    function getProperties(address user) public view returns (Property[] memory) {
        return userProperties[user].userProperties;
    }
}

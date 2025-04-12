pragma solidity ^0.8.19;
//TODO: add ownable
import "hardhat/console.sol";

contract AddressStorage{
    mapping(bytes32 => address) private addresses;

    function getAddress(bytes32 _key) public view returns (address) {
        require(
            addresses[_key] != address(0),
            "AddressStorage: Address not found"
        );
        return addresses[_key];
    }

    function _setAddress(bytes32 _key, address _value) internal {
        console.log("The address is:", _value);
        addresses[_key] = _value;
    }

}
interface IAddressProvider {
    // function getAddress(bytes32 _key) external view returns (address);
    function getCrowdfundingManager() external view returns (address);
    function getTokenManager() external view returns (address);
    function getProjectVotingManager() external view returns (address);
    
    function setCrowdfundingManager(address _address) external;
    function setTokenManager(address _address) external;
    function setProjectVotingManager(address _address) external;
}
contract AddressProvider is IAddressProvider, AddressStorage {
    AddressStorage private addressStorage;
    bytes32 private constant CROWDFUNDING_MANAGER = "CROWDFUNDING_MANAGER";
    bytes32 private constant TOKEN_MANAGER = "TOKEN_MANAGER";
    bytes32 private constant PROJECT_VOTING_MANAGER = "PROJECT_VOTING_MANAGER";



    function getCrowdfundingManager() external view returns (address) {
        return getAddress(CROWDFUNDING_MANAGER);
    }
    function getTokenManager() external view returns (address) {
        return getAddress(TOKEN_MANAGER);
    }
    function getProjectVotingManager() external view returns (address) {
        return getAddress(PROJECT_VOTING_MANAGER);
    }
    function setCrowdfundingManager(address _address) external {
        _setAddress(CROWDFUNDING_MANAGER, _address);
    }
    function setTokenManager(address _address) external {
        _setAddress(TOKEN_MANAGER, _address);
    }
    function setProjectVotingManager(address _address) external {
        _setAddress(PROJECT_VOTING_MANAGER, _address);
    }
}

pragma solidity ^0.5.0;

contract ExerciseC6A {

  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/
  
  struct UserProfile {
    bool isRegistered;
    bool isAdmin;
  }

  address private contractOwner;                  // Account used to deploy contract
  mapping(address => UserProfile) userProfiles;   // Mapping for storing user profiles
  
  bool private operational = true;

  uint constant M = 3;
  address[] votedAddresses = new address[](0);

  /********************************************************************************************/
  /*                                       EVENT DEFINITIONS                                  */
  /********************************************************************************************/

  // No events

  /**
  * @dev Constructor   
  */
  constructor() public {
    contractOwner = msg.sender; // The deploying account becomes contractOwner
  }

  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/

  // Modifiers help avoid duplication of code. They are typically used to validate something
  // before a function is allowed to be executed.

  /**
  * @dev Modifier that requires the "ContractOwner" account to be the function caller
  */
  modifier requireContractOwner() {
    require(msg.sender == contractOwner, "Caller is not contract owner");
    _;
  }

  modifier requireIsOperational() {
    require(operational, "Contract is not operational");
    _;
  }

  /********************************************************************************************/
  /*                                       UTILITY FUNCTIONS                                  */
  /********************************************************************************************/

  /**
  * @dev Check if a user is registered
  * @return A bool that indicates if the user is registered
  */   
  function isUserRegistered(address account) external view returns(bool) {
    require(account != address(0), "'account' must be a valid address.");
    return userProfiles[account].isRegistered;
  }

  function isOperational() public view returns(bool) {
    return operational;
  }

  /********************************************************************************************/
  /*                                     SMART CONTRACT FUNCTIONS                             */
  /********************************************************************************************/

  function registerUser(address account, bool isAdmin) external requireContractOwner requireIsOperational {
    require(!userProfiles[account].isRegistered, "User is already registered.");

    userProfiles[account] = UserProfile({
      isRegistered: true,
      isAdmin: isAdmin
    });
  }

  // Lesson 2.2 - Pausing a Smart Contract
  // function setOperatingStatus(bool status) external requireContractOwner {
  //   operational = status;
  // }

  // Lesson 2.3 - Multi-Party Consensus
  function setOperatingStatus(bool status) external {
    require(status != operational, "New status must be different from existing status");
    require(userProfiles[msg.sender].isAdmin, "Caller is not an admin");

    bool isDuplicate = false;
    for(uint i = 0; i < votedAddresses.length; i++) {
      if (votedAddresses[i] == msg.sender) {
        isDuplicate = true;
        break;
      }
    }
    require(!isDuplicate, "Caller has already called this function");

    votedAddresses.push(msg.sender);
    if (votedAddresses.length >= M) {
      operational = status;
      votedAddresses = new address[](0);
    }
  }

}


pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ExerciseC6B {
  using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/

  address private contractOwner;                  // Account used to deploy contract
  mapping (address => uint256) private sales;      // Lesson 3.6 - Checks-Effects-Iteractions
  uint256 private enabled = block.timestamp;      // Lesson 3.7 - Rate Limiting
  uint256 private counter = 1;                    // Lesson 3.8 - Re-Entrancy Guard

  constructor() public {
    contractOwner = msg.sender;
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

  // Lesson 3.7 - Rate Limiting
  modifier rateLimit(uint time) {
    require(block.timestamp >= enabled, "Rate limiting in effect");
    enabled = enabled.add(time);
    _;
  }

  // Lesson 3.8 - Re-Entrancy Guard
  modifier entrancyGuard() {
    counter = counter.add(1);
    uint256 guard = counter;
    _;
    require(guard == counter, "That is not allowed"); // If a function was called repeatedly, counter would be greater than guard
  }

  /********************************************************************************************/
  /*                                     SMART CONTRACT FUNCTIONS                             */
  /********************************************************************************************/

  // Lesson 3.6 - Checks-Effects-Iteractions
  // Write a function safeWithdraw(uint256) that protects against re-entrancy attacks using
  // the Checks-Effects-Interactions pattern
  function safeWithdraw(uint256 amount) external entrancyGuard() {
    // Checks - Verify caller is an externally owned account
    require(msg.sender == tx.origin, "Contracts not allowed");
    //Checks - Verify caller has adequate funds to withdraw
    require(sales[msg.sender] >= amount, "Insufficient funds");

    uint256 balance = sales[msg.sender];
    // Effects - Reset sales for caller address to zero
    sales[msg.sender] = sales[msg.sender].sub(balance);

    // Interaction - Transfer value of sales for caller to caller address
    msg.sender.transfer(balance);
  }
  
}


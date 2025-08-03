pragma solidity ^0.8.24;
contract RandaCore {
    string public message = "Hello from RandaCore!";
    function setMessage(string calldata newMessage) public {
        message = newMessage;
    }
}

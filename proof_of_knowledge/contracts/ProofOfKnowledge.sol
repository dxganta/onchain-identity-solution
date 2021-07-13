// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;
pragma experimental ABIEncoderV2;

import "../deps/AddressUpgradeable.sol";
import "../deps/SafeMathUpgradeable.sol";
import "../deps/Ownable.sol";

/// @dev This will be a multiple choice question test
contract ProofOfKnowledge is Ownable{
    using SafeMathUpgradeable for uint;
    using AddressUpgradeable for address;

    struct Test {
        uint id;
        uint startingTime;
        uint endingTime;
        string[q] questions;
    }

    uint public currentTestId = 0;
    uint16 public constant q = 2;  // t being the total number of questions for current Test
    Test public currentTest;
    uint8[q] private answers; // answers for the last finished test

    mapping(bytes32=>uint8[q]) userToAnswers; // mapping of a user to their answers for the current test
    mapping(bytes32=>uint8) userLimits; // mapping for limiting users to answer tests & update score only once per test

    modifier testOver() {
        require(now > currentTest.endingTime, "Wait! Test is still not over");
        _;
    }

    // @info use this function to add a new test for the upcoming week
    // @dev remove the last test & add a new test
    function addTest(string[q] memory _questions, uint _startingTime, uint _endingTime) external onlyOwner {
        currentTestId = currentTestId.add(1);
        currentTest = Test(currentTestId, _startingTime, _endingTime, _questions);
    }

    function testAddTest() external {
        currentTestId = currentTestId.add(1);
        currentTest = Test(currentTestId, now, now.add(now), ['a','a']);
    }

    // @info update the answers for the last finished test
    // so that the users' scores can be calculated
    function updateAnswers(uint8[q] memory _answers) external onlyOwner testOver {
        answers = _answers;
    }

    // @dev using this function to calculate scores of all users who gave the test
    // @params the answers for the last for which to give scores test
    function giveScores() external onlyOwner {

    }


    // @dev used by the user to give the answers for current test
    function answerTest(uint8[q] memory _answers) external {
        // user must be able to call this function only once for each test
        require(userLimits[_encodeAddress(_msgSender())] == 0, "Already attempted test");
        userToAnswers[_encodeAddress(_msgSender())] = _answers;
        userLimits[_encodeAddress(_msgSender())] = 1;
    }

    // @dev used by user to update his/her score for the current test after the answers are updated
    function updateMyScore() external testOver returns (uint) {
        require(userLimits[_encodeAddress(_msgSender())] == 1, "Already updated score");
        // user must be only able to call this function only once after test is over
        //TODO: Calculate score here
        userLimits[_encodeAddress(_msgSender())] = 2;
    }

    // @info outputs all the questions for the current test
    function getQuestions() external view returns (string[q] memory){
        return currentTest.questions;
    }

    function getAnswersForUser(address _user) public view returns (uint8[q] memory) {
        return userToAnswers[_encodeAddress(_user)];
    } 

    function _encodeAddress(address _user) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(currentTestId, _user));
    }

    function getUserLimit(address _u) public view returns (uint8) {
        return userLimits[_encodeAddress(_u)];
    }
}
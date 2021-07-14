// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;
pragma experimental ABIEncoderV2;

import "../deps/SafeMathUpgradeable.sol";
import "./Board.sol";

/// @dev This will be a multiple choice question test
contract ProofOfKnowledge is Board{
    using SafeMathUpgradeable for uint;
    using SafeMathUpgradeable for uint8;

    event TestAdded(uint id, uint startingTime, uint endingTime, string[q] questions);
    event AnswersUpdated(uint testId, uint8[q] answers);

    struct Test {
        uint id;
        uint startingTime;
        uint endingTime;
        string[q] questions;
    }

    uint8 public constant decimals = 18;
    uint public currentTestId = 0;
    uint16 public constant q = 10;  // t being the total number of questions for current Test
    Test public currentTest;
    uint8[q] public answers; // answers for the last finished test
    bool public answersUpdated = false;

    mapping(bytes32=>uint8[q]) public userToAnswers; // mapping of a user to their answers for the current test
    mapping(bytes32=>uint8) public userLimits; // mapping for limiting users to answer tests & update score only once per test
    mapping(address=>uint) public userToScore; // current score of user (score is in 10**6 decimals)

    // will be divided by 1000 (so 700 means 70%)
    uint public alpha = 700; // percentage of previous score
    uint public beta = 300; // percentage of new score


    constructor(address[] memory _boardMembers) public
    Board(_boardMembers)
     {

    }

    // @info use this function to add a new test for the upcoming week
    // @dev remove the last test & add a new test
    function addTest(string[q] memory _questions, uint _startingTime, uint _endingTime) public onlyOwner {
        currentTestId = currentTestId.add(1);
        currentTest = Test(currentTestId, _startingTime, _endingTime, _questions);
        answersUpdated = false;
        emit TestAdded(currentTest.id, currentTest.startingTime, currentTest.endingTime, currentTest.questions);
    }

    // @info update the answers for the last finished test
    // so that the users' scores can be calculated
    function updateAnswers(uint8[q] memory _answers) external onlyOwner {
        require(now > currentTest.endingTime, "Test not over");
        answers = _answers;
        answersUpdated = true;
        _setNewOwner();
        emit AnswersUpdated(currentTest.id, answers);
    }


    // @dev used by the user to give the answers for current test
    function answerTest(uint8[q] memory _answers) external {
        // user must be able to call this function only once for each test
        require(userLimits[encodeAddress(msg.sender)] == 0, "Already attempted test");
        require(now > currentTest.startingTime && now < currentTest.endingTime, "Not Test Time");
        userToAnswers[encodeAddress(msg.sender)] = _answers;
        userLimits[encodeAddress(msg.sender)] = 1;
    }

    // @dev used by user to update his/her score for the current test after the answers are updated
    function updateMyScore() external returns (uint) {
        require(answersUpdated, "Wait till answers updated");
        require(userLimits[encodeAddress(msg.sender)] == 1, "Already updated score");
        // get score 
        uint score = _calculateScore(msg.sender);
        // update user score 
        userToScore[msg.sender] = score;
        userLimits[encodeAddress(msg.sender)] = 2;
        return score;
    }

    function _calculateScore(address _user) internal view returns (uint) {
        uint score = userToScore[_user];
        uint8[q] memory userAnswers = getUserAnswers(_user);

        // first calculate the number of correct answers of the user in this test
        uint m = 0;
        for (uint i =0; i < q; i++) {
            if (userAnswers[i] == answers[i]) {
                m++;
            }
        }

        if (currentTestId == 1) {
            // for the first test the score is 100% of what a user scores
             score = m.mul(uint(10)**decimals).div(q);
             return score;
        }

        // alpha% of previous score plus beta% of new score
        score = score.mul(alpha).div(1000) + m.mul(beta).mul(uint(10)**decimals).div(1000).div(q);
        return score;
    }

    // @info outputs all the values for the current test
    function getCurrentTest() external view returns (uint testId, string[q] memory questions, uint startingTime, uint endindTime){
        return (currentTest.id, currentTest.questions, currentTest.startingTime, currentTest.endingTime);
    }

    function getUserAnswers(address _user) public view returns (uint8[q] memory) {
        return userToAnswers[encodeAddress(_user)];
    } 

    function encodeAddress(address _user) public view returns (bytes32) {
        return keccak256(abi.encodePacked(currentTestId, _user));
    }

    /// @dev set the alpha% & beta%, used in calculation of user score
    function setAlphaBeta(uint _alpha, uint _beta) external onlyOwner {
        require (_alpha + beta == 1000);
        alpha = _alpha;
        beta = _beta;
    }
}
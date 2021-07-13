// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;
pragma experimental ABIEncoderV2;

import "../deps/AddressUpgradeable.sol";
import "../deps/SafeMathUpgradeable.sol";
import "../deps/Ownable.sol";

/// @dev This will be a multiple choice question test
contract ProofOfKnowledge is Ownable{
    using SafeMathUpgradeable for uint;
    using SafeMathUpgradeable for uint8;
    using AddressUpgradeable for address;

    event TestAdded(uint id, uint startingTime, uint endingTime, string[q] questions);
    event AnswersUpdated(uint testId, uint8[q] answers);

    struct Test {
        uint id;
        uint startingTime;
        uint endingTime;
        string[q] questions;
    }

    uint8 public constant decimals = 6;
    uint public currentTestId = 0;
    uint16 public constant q = 2;  // t being the total number of questions for current Test
    Test public currentTest;
    uint8[q] private answers; // answers for the last finished test
    bool public answersUpdated = false;

    mapping(bytes32=>uint8[q]) public userToAnswers; // mapping of a user to their answers for the current test
    mapping(bytes32=>uint8) public userLimits; // mapping for limiting users to answer tests & update score only once per test
    mapping(address=>uint) public userToScore; // current score of user (score is in 10**6 decimals)

    // will be divided by 1000 (so 700 means 70%)
    uint public alpha = 700; // percentage of previous score
    uint public beta = 300; // percentage of new score

    modifier testOver() {
        require(now > currentTest.endingTime, "Wait! Test is still not over");
        _;
    }

    // @info use this function to add a new test for the upcoming week
    // @dev remove the last test & add a new test
    function addTest(string[q] memory _questions, uint _startingTime, uint _endingTime) public onlyOwner {
        currentTestId = currentTestId.add(1);
        currentTest = Test(currentTestId, _startingTime, _endingTime, _questions);
        answersUpdated = false;
        emit TestAdded(currentTest.id, currentTest.startingTime, currentTest.endingTime, currentTest.questions);
    }

    function testAddTest() external {
        addTest(['a','a'], now, now.add(now));
    }

    // @info update the answers for the last finished test
    // so that the users' scores can be calculated
    function updateAnswers(uint8[q] memory _answers) external onlyOwner testOver {
        answers = _answers;
        answersUpdated = true;
        emit AnswersUpdated(currentTest.id, _answers);
    }


    // @dev used by the user to give the answers for current test
    function answerTest(uint8[q] memory _answers) external {
        // user must be able to call this function only once for each test
        require(userLimits[_encodeAddress(_msgSender())] == 0, "Already attempted test");
        userToAnswers[_encodeAddress(_msgSender())] = _answers;
        userLimits[_encodeAddress(_msgSender())] = 1;
    }

    // @dev used by user to update his/her score for the current test after the answers are updated
    function updateMyScore() external returns (uint) {
        require(answersUpdated, "Wait till answers updated");
        require(userLimits[_encodeAddress(_msgSender())] == 1, "Already updated score");
        //TODO: Calculate score here
        uint score = _calculateScore(_msgSender());
        // update user score 
        userToScore[_msgSender()] = score;
        userLimits[_encodeAddress(_msgSender())] = 2;
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
        score = alpha.mul(score).div(1000) + beta.mul(m).div(1000).mul(uint(10)**decimals).div(q);
        return score;
    }

    // @info outputs all the questions for the current test
    function getQuestions() external view returns (string[q] memory){
        return currentTest.questions;
    }

    function getUserAnswers(address _user) public view returns (uint8[q] memory) {
        return userToAnswers[_encodeAddress(_user)];
    } 

    function _encodeAddress(address _user) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(currentTestId, _user));
    }

    function setAlphaBeta(uint _alpha, uint _beta) external onlyOwner {
        require (_alpha + beta == 1000);
        alpha = _alpha;
        beta = _beta;
    }
}
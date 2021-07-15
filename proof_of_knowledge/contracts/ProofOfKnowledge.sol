// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;
pragma experimental ABIEncoderV2;

import "../deps/SafeMathUpgradeable.sol";
import "./Board.sol";

/// @dev This will be a multiple choice question test
contract ProofOfKnowledge is Board{
    using SafeMathUpgradeable for uint;
    using SafeMathUpgradeable for uint8;

    event DelegatorAdded(address delegator, uint time);
    event TestAdded(uint id, uint startingTime, uint endingTime);
    event TestQuestionsAdded(uint id, string[q] questions);
    event AnswersUpdated(uint testId, uint8[q] answers);

    struct Test {
        uint id;
        uint startingTime;
        uint endingTime;
    }

    uint8 public constant decimals = 18;
    uint8 public constant x = 5; // number of minutes before the test starting time, before which owner cannot update the questions
    uint16 public constant q = 10;  // q being the total number of questions for each Test

    uint public currentTestId = 0;

    Test private _currentTest;
    string[q] private _questions; // questions for the upcoming test
    bool public questionsUpdated = false;

    address[] private _delegators;
    mapping(address=>bool) public isDelegator;
    mapping(bytes32=>uint8[q]) public userToAnswers; // mapping of a delegator to their answers for the current test
    mapping(bytes32=>bool) public testAttempted; // mapping for limiting users to answer tests only once per test
    mapping(address=>uint) public userToScore; // current score of delegator (score is in 10**18 decimals)

    // will be divided by 1000 (so 600 means 60%)
    uint public alpha = 600; // percentage of previous score
    uint public beta = 400; // percentage of new score

    constructor(address[] memory _boardMembers) public
    Board(_boardMembers)
     {

    }

    // @dev adds the msg.sender to the delegator
    // this is a very important function to call for the delegators
    // because without this the delegator wont be able to attempt tests
    function addDelegator() public {
        require(!isDelegator[msg.sender], "Already a delegator");
        _delegators.push(msg.sender);
        isDelegator[msg.sender] = true;
        emit DelegatorAdded(msg.sender, now);
    }

    // @info use this function to add the new upcoming test
    // @dev remove the last test & add a new test
    function addTest(uint _startingTime, uint _endingTime) public onlyOwner {
        currentTestId = currentTestId.add(1);
        _currentTest = Test(currentTestId, _startingTime, _endingTime);
        emit TestAdded(_currentTest.id, _currentTest.startingTime, _currentTest.endingTime);
    }

    // @info add questions for the upcoming test
    // @dev you cannot update the questions more than 5 mins before the test starts
    function addQuestions(string[q] memory _newQuestions) public onlyOwner {
        require(now + uint(x) *  1 minutes >= _currentTest.startingTime, "Too Early");
        _questions = _newQuestions;
        questionsUpdated = true;
        emit TestQuestionsAdded(_currentTest.id, _questions);
    }

    // @dev update the answers for the last finished test
    // @dev also use the answers to update the scores of all the users
    function finishTest(uint8[q] memory _answers) public onlyOwner {
        require(now > _currentTest.endingTime, "Test not over");
        _updatedAllScores(_answers);
        questionsUpdated = false;
        emit AnswersUpdated(_currentTest.id, _answers);
    }


    // @dev used by the delegator to submit the answers for current test
    function submitAnswers(uint8[q] memory _answers) public {
        // delegator must be able to call this function only once for each test
        require(isDelegator[msg.sender], "Not a delegator");
        require(!testAttempted[encodeAddress(msg.sender)], "Already attempted test");
        require(now > _currentTest.startingTime && now < _currentTest.endingTime, "Not Test Time");
        require(questionsUpdated, "Questions not updated");
        userToAnswers[encodeAddress(msg.sender)] = _answers;
        testAttempted[encodeAddress(msg.sender)] = true;
    }

    // @dev similarly to a teacher checking the answers of all students
    // update the score for all the delegators
    // also sets a new random owner from the members list 
    function _updatedAllScores(uint8[q] memory _answers) internal {
        for (uint i =0; i < _delegators.length; i++) {
            _updateDelegatorScore(_delegators[i], _answers);
        }
        _setNewOwner();
    }

    // @dev update a particular delgator's score for the current test after the answers are updated
    function _updateDelegatorScore(address _delegator, uint8[q] memory _answers) internal {
        // get score 
        uint score = _calculateScore(_delegator, _answers);
        // update delegator score 
        userToScore[_delegator] = score;
    }

    function _calculateScore(address _user, uint8[q] memory _answers) internal view returns (uint) {
        uint score = userToScore[_user];
        uint8[q] memory userAnswers = getUserAnswers(_user);

        // first calculate the number of correct answers of the delegator in this test
        uint m = 0;
        for (uint i =0; i < q; i++) {
            if (userAnswers[i] == _answers[i]) {
                m = m.add(1);
            }
        }

        if (currentTestId == 1) {
            // for the first test the score is 100% of what a delegator scores
             score = m.mul(uint(10)**decimals).div(q);
             return score;
        }

        // alpha% of previous score plus beta% of new score
        score = score.mul(alpha).div(1000) + m.mul(beta).mul(uint(10)**decimals).div(1000).div(q);
        return score;
    }

    // @info outputs all the values for the current test
    function getCurrentTestData() external view returns (uint testId, uint startingTime, uint endindTime){
        return (_currentTest.id,_currentTest.startingTime, _currentTest.endingTime);
    }

    // @info outputs currentTest questions
    function getCurrentTestQuestions() external view returns (string[q] memory questions) {
        require (now >= _currentTest.startingTime);
        require(questionsUpdated);
        return _questions;
    }

    // @info outputs the answers of a particular delegator given the address
    function getUserAnswers(address _user) public view returns (uint8[q] memory) {
        return userToAnswers[encodeAddress(_user)];
    } 


    // encodes the address with the current Test Id
    function encodeAddress(address _user) public view returns (bytes32) {
        return keccak256(abi.encodePacked(currentTestId, _user));
    }

    /// @dev set the alpha% & beta%, used in calculation of delegator score
    function setAlphaBeta(uint _alpha, uint _beta) external onlyOwner {
        require (_alpha + beta == 1000);
        alpha = _alpha;
        beta = _beta;
    }
}
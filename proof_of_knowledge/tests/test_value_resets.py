from brownie import *


def test_value_resets(deployer, contract):
    user = accounts[4]  # random account

    q = contract.q()
    questions = ['Ethereum or Bitcoin?' for x in range(q)]
    correct_answers = [1 for x in range(10)]
    starting_time = chain.time()
    ending_time = starting_time + 3600  # ends after one hour

    user_answers = [1, 1, 1, 1, 1, 3, 3, 3, 3, 3]

    # do the whole POF test workflow once
    contract.addTest(questions, starting_time, ending_time, {"from": deployer})
    chain.sleep(10)
    chain.mine()
    contract.answerTest(user_answers, {"from": user})
    chain.sleep(3600)
    chain.mine()
    contract.updateAnswers(correct_answers, {"from": deployer})
    contract.updateMyScore({"from": user})

    assert (contract.answersUpdated() == True)

    testId = contract.currentTestId()

    # add a second test
    new_questions = ['Messi or Ronaldo?' for x in range(q)]
    new_starting_time = chain.time()
    new_ending_time = new_starting_time + 3600
    contract.addTest(new_questions, new_starting_time,
                     new_ending_time, {"from": deployer})

    # assert that the values are updated properly after adding new test
    assert (contract.currentTestId() - testId == 1)
    (new_testId, _questions, _starting_time,
     _ending_time) = contract.getCurrentTest()

    assert (new_testId == 2)  # since this is the 2nd test
    assert (new_questions == _questions)
    assert (new_starting_time == _starting_time)
    assert (new_ending_time == _ending_time)

    # assert all the previous userAnswers were reset
    assert (contract.getUserAnswers(user) == (0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    # assert the user limits were reset
    assert (contract.userLimits(contract.encodeAddress(user)) == 0)

    assert (contract.answersUpdated() == False)

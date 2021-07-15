from brownie import *


def test_value_resets(deployer, contract):
    user = accounts[4]  # random account

    q = contract.q()
    questions = ['Ethereum or Bitcoin?' for x in range(q)]
    correct_answers = [1 for x in range(10)]
    starting_time = chain.time()
    ending_time = starting_time + 3600  # ends after one hour

    user_answers = [1, 1, 1, 1, 1, 3, 3, 3, 3, 3]

    # do the whole POK test workflow once
    contract.addTest(starting_time, ending_time, {"from": deployer})
    contract.addQuestions(questions, {"from": deployer})
    chain.sleep(10)
    chain.mine()
    contract.addDelegator({"from": user})
    contract.submitAnswers(user_answers, {"from": user})
    assert (contract.testAttempted(contract.encodeAddress(user)) == True)
    chain.sleep(3600)
    chain.mine()
    contract.finishTest(correct_answers, {"from": deployer})

    testId = contract.currentTestId()

    # add a second test
    new_questions = ['Messi or Ronaldo?' for x in range(q)]
    new_starting_time = chain.time()
    new_ending_time = new_starting_time + 3600
    contract.addTest(new_starting_time,
                     new_ending_time, {"from": contract.owner()})
    contract.addQuestions(questions, {"from": contract.owner()})

    # assert that the values are updated properly after adding new test
    assert (contract.currentTestId() - testId == 1)
    (new_testId, _starting_time,
     _ending_time) = contract.getCurrentTestData()

    assert (new_testId == 2)  # since this is the 2nd test
    assert (new_starting_time == _starting_time)
    assert (new_ending_time == _ending_time)

    # assert all the previous userAnswers were reset
    assert (contract.getUserAnswers(user) == (0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    # assert the user limits were reset
    assert (contract.testAttempted(contract.encodeAddress(user)) == False)

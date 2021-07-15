from brownie import *


def test_workflow(deployer, contract):

    user = accounts[4]  # random account

    q = contract.q()
    questions = [
        'Ethereum or Bitcoin? 0)Ethereum 1)Bitcoin 2)None' for x in range(q)]
    correct_answers = [1 for x in range(q)]
    starting_time = chain.time() + 10
    ending_time = chain.time() + 3600  # ends after one hour

    # add POK test
    tx = contract.addTest(starting_time,
                          ending_time, {"from": deployer})

    # assert emission of TestAdded event
    assert(tx.events["TestAdded"])

    # make sure that new test is updated correctly
    (testId, _starting_time, _ending_time) = contract.getCurrentTestData()

    assert (testId == 1)  # since this is the first test
    assert (starting_time == _starting_time)
    assert (ending_time == _ending_time)

    chain.sleep(5)
    chain.mine()

    # add questions for the test
    contract.addQuestions(questions)

    # test starts
    chain.sleep(10)
    chain.mine()

    _questions = contract.getCurrentTestQuestions()
    assert(_questions == questions)

    # add user as delegator
    contract.addDelegator({"from": user})

    # user updates answers
    user_answers = [1, 1, 1, 1, 1, 0, 0, 0, 0, 0]
    contract.submitAnswers(user_answers, {"from": user})

    # make sure answer gets updated properly
    a = contract.getUserAnswers(user)
    assert(a == user_answers)

    chain.sleep(3600)
    chain.mine()

    # test time over
    # finish test and update user scores
    tx1 = contract.finishTest(correct_answers, {"from": deployer})

    # assert that the answers were updated properly
    assert (tx1.events["AnswersUpdated"]['answers'] == correct_answers)

    # since the user answered 50% questions correctly & this is the first test, her score must be 0.5 multiplied by 10**decimals
    decimals = contract.decimals()
    assert(contract.userToScore(user) == 0.5*10**decimals)

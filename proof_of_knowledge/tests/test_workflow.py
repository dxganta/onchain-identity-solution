from brownie import *


def test_workflow(deployer, contract):

    user = accounts[4]  # random account

    q = contract.q()
    questions = ['Ethereum or Bitcoin?' for x in range(q)]
    correct_answers = [1 for x in range(10)]
    starting_time = chain.time()
    ending_time = chain.time() + 3600  # ends after one hour

    # add POF test
    tx = contract.addTest(questions, starting_time,
                          ending_time, {"from": deployer})

    # assert emission of TestAdded event
    assert(tx.events["TestAdded"])

    # make sure that new test is updated correctly
    (testId, _questions, _starting_time, _ending_time) = contract.getCurrentTest()

    assert (testId == 1)  # since this is the first test
    assert (questions == _questions)
    assert (starting_time == _starting_time)
    assert (ending_time == _ending_time)

    # also make sure the answers are not updated before the test is over
    assert (contract.answersUpdated() == False)

    chain.sleep(10)
    chain.mine()

    # user updates answers
    user_answers = [1, 1, 1, 1, 1, 0, 0, 0, 0, 0]
    contract.answerTest(user_answers, {"from": user})

    # make sure answer gets updated properly
    a = contract.getUserAnswers(user)
    assert(a == user_answers)

    chain.sleep(3600)
    chain.mine()

    # test time over
    # update the answers
    tx1 = contract.updateAnswers(correct_answers, {"from": deployer})

    # assert that the answers were updated properly
    assert (contract.answersUpdated() == True)
    assert (tx1.events["AnswersUpdated"]['answers'] == correct_answers)

    # test user score gets updated properly
    tx2 = contract.updateMyScore({"from": user})

    # since the user answered 50% questions correctly & this is the first test, her score must be 0.5 multiplied by 10**decimals
    decimals = contract.decimals()
    assert(tx2.return_value == 0.5*10**decimals)

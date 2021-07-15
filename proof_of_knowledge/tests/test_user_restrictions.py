from brownie import *
import brownie


def test_user_restrictions(deployer, contract):
    user = accounts[4]  # random account

    q = contract.q()
    questions = ['Ethereum or Bitcoin?' for x in range(q)]
    correct_answers = [1 for x in range(10)]
    starting_time = chain.time() + 6*60
    ending_time = starting_time + 3600  # ends after one hour

    user_answers = [1, 1, 1, 1, 1, 3, 3, 3, 3, 3]

    #  only admin is allowed to add new POK tests
    with brownie.reverts("Ownable: caller is not the owner"):
        contract.addTest(starting_time, ending_time, {"from": user})

    # add POK test
    contract.addTest(starting_time, ending_time, {"from": deployer})

    # owner must not be able to add questions 5 mins before test starting time
    with brownie.reverts("Too Early"):
        contract.addQuestions(questions, {"from": deployer})

    chain.sleep(120)
    chain.mine()

    contract.addQuestions(questions, {"from": deployer})

    # user should not be able to check POK questions before test starts
    with brownie.reverts():
        contract.getCurrentTestQuestions({"from": user})

    # user should not be able to answer questions without being added as delegator
    with brownie.reverts("Not a delegator"):
        contract.submitAnswers(user_answers, {"from": user})

    # add user as delegator
    contract.addDelegator({"from": user})

    # user should not be able to add himself/herself as delegator twice
    with brownie.reverts("Already a delegator"):
        contract.addDelegator({"from": user})

    #  user should not be able to answer POK Test before test starts
    with brownie.reverts("Not Test Time"):
        contract.submitAnswers(user_answers, {"from": user})

    chain.sleep(6*60)
    chain.mine()

    # should be able to get questions now
    contract.getCurrentTestQuestions({"from": user})

    contract.submitAnswers(user_answers, {"from": user})

    #  user should not be able to answer the same POK test twice
    with brownie.reverts("Already attempted test"):
        contract.submitAnswers(user_answers, {"from": user})

    #  admin should not be able to update Answers before POK test is finished
    with brownie.reverts("Test not over"):
        contract.finishTest(correct_answers, {"from": deployer})

    # POK test finished
    chain.sleep(4000)
    chain.mine()

    # admin updates the answers
    contract.finishTest(correct_answers, {"from": deployer})

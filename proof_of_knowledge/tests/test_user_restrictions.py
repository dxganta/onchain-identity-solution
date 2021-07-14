from brownie import *
import brownie


def test_user_restrictions(deployer, contract):
    user = accounts[4]  # random account

    q = contract.q()
    questions = ['Ethereum or Bitcoin?' for x in range(q)]
    correct_answers = [1 for x in range(10)]
    starting_time = chain.time() + 10
    ending_time = starting_time + 3600  # ends after one hour

    user_answers = [1, 1, 1, 1, 1, 3, 3, 3, 3, 3]

    #  only admin is allowed to add new POF tests
    with brownie.reverts("Ownable: caller is not the owner"):
        contract.addTest(questions, starting_time, ending_time, {"from": user})

    # add POF test
    contract.addTest(questions, starting_time, ending_time, {"from": deployer})

    #  user should not be able to answer POF Test before test starts
    with brownie.reverts("Not Test Time"):
        contract.answerTest(user_answers, {"from": user})

    #  admin should not be able to update answers before POF test starts
    with brownie.reverts("Test not over"):
        contract.updateAnswers(correct_answers, {"from": deployer})

    chain.sleep(20)
    chain.mine()

    contract.answerTest(user_answers, {"from": user})

    #  user should not be able to answer the same POF test twice
    with brownie.reverts("Already attempted test"):
        contract.answerTest(user_answers, {"from": user})

    #  admin should not be able to update Answers before POF test is finished
    with brownie.reverts("Test not over"):
        contract.updateAnswers(correct_answers, {"from": deployer})

    # user should not be able to update score before POF test is finished
    with brownie.reverts("Wait till answers updated"):
        contract.updateMyScore({"from": user})

    # POF test finished
    chain.sleep(4000)
    chain.mine()

    # user should not be able to update score before admin updates the answers
    with brownie.reverts("Wait till answers updated"):
        contract.updateMyScore({"from": user})

    # admin updates the answers
    contract.updateAnswers(correct_answers, {"from": deployer})

    # user gets his score
    tx = contract.updateMyScore({"from": user})

    score = tx.return_value
    print("User Score")
    print(score)

    # user should not be able to update score more than once for each POF test
    with brownie.reverts("Already updated score"):
        contract.updateMyScore({"from": user})

    # user should not be able again put answers for the same test after updating the score
    with brownie.reverts("Already attempted test"):
        contract.answerTest(user_answers, {"from": user})

from brownie import *


def test_score_calculation(contract, deployer):
    # random accounts
    user1 = accounts[4]
    user2 = accounts[5]
    user3 = accounts[7]

    q = contract.q()
    questions = ['Ethereum or Bitcoin?' for x in range(q)]
    correct_answers = [1 for x in range(10)]
    starting_time = chain.time()
    ending_time = starting_time + 3600  # ends after one hour

    user1_answers = [1, 1, 1, 1, 1, 1, 1, 3, 3, 3]
    user2_answers = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
    user3_answers = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    # do the whole POF test workflow once
    contract.addTest(questions, starting_time, ending_time, {"from": deployer})
    chain.sleep(10)
    chain.mine()

    contract.answerTest(user1_answers, {"from": user1})
    contract.answerTest(user2_answers, {"from": user2})
    contract.answerTest(user3_answers, {"from": user3})

    chain.sleep(3600)
    chain.mine()
    contract.updateAnswers(correct_answers, {"from": deployer})

    contract.updateMyScore({"from": user1})
    contract.updateMyScore({"from": user2})
    contract.updateMyScore({"from": user3})

    expected_score_1 = get_expected_score_1st_test(
        correct_answers, user1_answers)
    expected_score_2 = get_expected_score_1st_test(
        correct_answers, user2_answers)
    expected_score_3 = get_expected_score_1st_test(
        correct_answers, user3_answers)

    # assert POF score is correct for 1st POF test
    assert(contract.userToScore(user1) == expected_score_1)
    assert(contract.userToScore(user2) == expected_score_2)
    assert(contract.userToScore(user3) == expected_score_3)

    # add a second test
    new_questions = ['Messi or Ronaldo?' for x in range(q)]
    new_starting_time = chain.time()
    new_ending_time = new_starting_time + 3600
    contract.addTest(new_questions, new_starting_time,
                     new_ending_time, {"from": deployer})

    chain.sleep(10)
    chain.mine()

    user1_answers = [1, 1, 3, 1, 1, 1, 1, 1, 1, 3]
    user2_answers = [3, 3, 1, 3, 1, 3, 3, 1, 3, 3]
    user3_answers = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    contract.answerTest(user1_answers, {"from": user1})
    contract.answerTest(user2_answers, {"from": user2})
    contract.answerTest(user3_answers, {"from": user3})

    chain.sleep(3600)
    chain.mine()

    contract.updateAnswers(correct_answers, {"from": deployer})

    contract.updateMyScore({"from": user1})
    contract.updateMyScore({"from": user2})
    contract.updateMyScore({"from": user3})

    expected_score_1 = get_expected_score_other_tests(
        expected_score_1, correct_answers, user1_answers)
    expected_score_2 = get_expected_score_other_tests(
        expected_score_2, correct_answers, user2_answers)
    expected_score_3 = get_expected_score_other_tests(
        expected_score_3, correct_answers, user3_answers)

    # assert POF score is correct for 2nd POF test
    assert(contract.userToScore(user1) == expected_score_1)
    assert(contract.userToScore(user2) == expected_score_2)
    assert(contract.userToScore(user3) == expected_score_3)


def get_expected_score_1st_test(correct_answers, user_answers, decimals=18):
    q = len(correct_answers)
    score = 0
    for i in range(q):
        if user_answers[i] == correct_answers[i]:
            score += 1

    return (score/q) * 10**decimals


def get_expected_score_other_tests(prev_score, correct_answers, user_answers, alpha=0.7, beta=0.3, decimals=18):
    q = len(correct_answers)
    score = 0
    for i in range(q):
        if user_answers[i] == correct_answers[i]:
            score += 1

    return alpha * prev_score + beta*(score/q)*10**decimals

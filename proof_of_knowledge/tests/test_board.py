from brownie import *
import brownie

# test a new member can be added as member only when voted true by all


def test_board(contract, members):

    new_member = accounts[6]

    # try to add new_member with zero votes
    contract.addNewMember(new_member, {"from": members[0]})
    assert(new_member not in contract.members())

    # only 2 votes
    for i in range(2):
        tx = contract.voteNewMember(new_member, {"from": members[i]})
        assert(tx.events["MemberVote"])

    contract.addNewMember(new_member, {"from": members[0]})
    assert(new_member not in contract.members())

    # with all 4 votes
    # this time member should get added
    for i in range(2, 4):
        tx = contract.voteNewMember(new_member, {"from": members[i]})
        assert(tx.events["MemberVote"])

    tx = contract.addNewMember(new_member, {"from": members[0]})
    assert(new_member in contract.members())
    assert(tx.events["NewMemberAdded"])

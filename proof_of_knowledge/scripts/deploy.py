from brownie import *
from dotmap import DotMap


def main():
    return deploy()


def deploy():
    deployer = accounts[0]

    boardMembers = [deployer, accounts[1], accounts[2], accounts[3]]

    contract = ProofOfKnowledge.deploy(boardMembers, {'from': deployer})

    return DotMap(
        deployer=deployer,
        contract=contract,
        boardMembers=boardMembers
    )

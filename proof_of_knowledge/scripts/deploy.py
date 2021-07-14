from brownie import *
from dotmap import DotMap


def main():
    return deploy()


def deploy():
    deployer = accounts[0]

    boardMembers = [deployer]

    contract = ProofOfKnowledge.deploy(boardMembers, {'from': deployer})

    return DotMap(
        deployer=deployer,
        contract=contract
    )

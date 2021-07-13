from brownie import *
from dotmap import DotMap


def main():
    return deploy()


def deploy():
    deployer = accounts[0]

    contract = ProofOfKnowledge.deploy({'from': deployer})

    return DotMap(
        deployer=deployer,
        contract=contract
    )

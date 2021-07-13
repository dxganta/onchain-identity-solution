from brownie import *
from dotmap import DotMap
from scripts.deploy import deploy
import pytest


@pytest.fixture
def deployed():
    return deploy()


@pytest.fixture
def contract(deployed):
    return deployed.contract


@pytest.fixture
def deployer(deployed):
    return deployed.deployer.address

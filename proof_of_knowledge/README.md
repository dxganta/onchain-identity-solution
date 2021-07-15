# Installation and Setup

1. Install Brownie & Ganache-CLI, if you haven't already.


Install the dependencies in the package
```
## Python Dependencies
pip install -r requirements.txt
```

## Basic Use

1. Compile the contracts 
```
  brownie compile
```

2. Run Scripts for Deployment. You can have a look at the deployment script at [proof_of_knowledge/scripts/deploy.py](https://github.com/realdiganta/onchain-identity-solution/blob/main/proof_of_knowledge/scripts/deploy.py)
```
  brownie run deploy
```

3. Testing. To run all the tests in the tests folder 
``` 
brownie test
```
<img src="https://user-images.githubusercontent.com/47485188/125804817-91f653e6-c17b-43bd-b70f-28f1d581f5f2.png"> </img>

4. Run the test deployment in the console and interact with it
```python
  brownie console
  >>> deployed = run("deploy")

  Running 'scripts/deploy.py::main'...
  Transaction sent: 0x952d779187b04d1b197b3b22288dd54b5acc42799c3205dcdc706fd0303b0920
  Gas price: 0.0 gwei   Gas limit: 12000000   Nonce: 0
  ProofOfKnowledge.constructor confirmed - Block: 1   Gas used: 1606012 (13.38%)
  ProofOfKnowledge deployed at: 0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87

  ## Now you can interact with the contracts via the console
  >>> deployed
  {
      'boardMembers': [0x66aB6D9362d4F35596279692F0251Db635165871, 0x33A4622B82D4c04a53e170c638B944ce27cffce3, 0x0063046686E46Dc6F15918b61AE2B121458534a5, 0x21b42413bA931038f35e7A5224FaDb065d297Ba3],
    'contract': 0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87,
    'deployer': 0x66aB6D9362d4F35596279692F0251Db635165871
  }
  >>> deployed.contract.getCurrentTestData()
    (0, 0, 0)
  >>>  

```
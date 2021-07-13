# Onchain Identity

## Concepts
1. Ideana On Chain Indentity
2. Zero Knowledge Proofs
3. 


## If I was a staker in the Sovryn Protocol, then why would I make someone a delegator?
1. If he has a record of always voting on the side that wins (i.e always making the correct choice)
    I want to know what are the SIPs he voted on previously. How many of them he got right. How many were wrong.
2. If he has created SIPs in the past that has got majority of yes votes
3. Periodic proof of knowledge test for the delegators
4. If he has passed a lot of proof of knowledge tests (Has a high POF Score)



## Proof of Knowledge
1. can only give the test once
2. POF Score = Sum of the total number of questions for all tests in all periods divided by the answers that you got right till now
    So if someone doesn't give a test during a period, then by default he gets zero in all the questions on that test
3. But there is a loophole here. So suppose the total questions till now are 20, then on the next test, losing all 10 of them will
    reduce your score significantly. But if there are like 1500 total tests till now, then getting 10 wrong on the next test
    wont matter shit. So a good fix will be weighted testing, with more recent tests having a higher weight and older tests having a lower one.


# POF Tests
1. On every test there will be 10 questions
2. You must have staked SOV to participate in the test (optional)
3. You can attempt the test only once on test day
4. Tests will be held periodically with questions to be decided by the admin team
5. A test will have a fixed time interval (starting time & ending time) between which a user has to do it.
6. A list of addresses need to be set as admins at contract inception, and every week a person among them will be chosen to figure out the questions for the upcoming test



## Setup
//TODO: Launch the frontend dapp on heroku
Replace the cvKey in next.config.js with your covalent api key


## Tests
1. Is the userToAnswers mapping in the Test Struct reset, everytime a new test is added
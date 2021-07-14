# Onchain Identity

## Problem
To tackle this problem, I first asked myself a simple question:
### If I was a staker in the Sovryn Protocol, then what would convince me to make someone a delegator?
1. First I would want to know what are the SIPs that he voted for in the past. I would want to know what were his votes were for each SIP. This would give me an idea if his vision agrees with mine.
2. Next I would want to know if she has created any SIPs herself in the past. This would give me further information about her knowledge and vision of the Sovryn Protocol. 
3. Third, and most important I want to know how much this person knows about the Sovryn Protocol. I want to be sure specifically that this person knows more than me about the Sovryn Protocol. He might be a PHD in Quantum Mechanics, but if he doesn't know anything about Sovryn and its vision then I am not going to make him a delegate my precious voting power to him.

## Solutions
### For #1 & #2
The first 2 problems are easy. We can easily build a dapp which queries the blockchain for the "ProposalCreated" & "VoteCast" events emitted by the Sovryn's Governor contract and show them in a beautiful frontend. The user must be able to search by delegator address.

### For #3
But the 3rd problem is a little tricky. How do you figure out how knowledgable someone is about the Sovryn Protocol? <br>Well, back in school, how did our teachers figure out who is good in mathematics and who is bad?<br> Tests right!!!<br> And thats the path I took. Tests, But on the BLOCKCHAIN!<br> 
I created a protocol which I am calling (Ahhaahh) <strong>Proof Of Knowledge</strong>. More details below.


## 1. DAPP

<img src="https://user-images.githubusercontent.com/47485188/125639754-ecb44053-750c-408f-b39b-776e7e1253d9.png"></img>

You can test it here:
https://sovryn-delegator.vercel.app/

Just enter the address of any Sovryn staker in the search bar and click on the search button, and the dapp will output a list of the Proposals Created & the Proposals Voted by that address.

Note: The dapp is querying the events from this Sovryn governor address : 0xfF25f66b7D7F385503D70574AE0170b6B1622dAd

The Delegator Score is just static for now. 



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
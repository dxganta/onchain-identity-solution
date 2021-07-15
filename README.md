# Onchain Identity

## Problem
To tackle this problem, I first asked myself a simple question:
### If I was a staker in the Sovryn Protocol, then what would convince me to make someone a delegator?
1. First I would want to know what are the SIPs that he voted for in the past. I would want to know what were his votes were for each SIP. This would give me an idea if his vision agrees with mine.
2. Next I would want to know if she has created any SIPs herself in the past. This would give me further information about her knowledge and vision of the Sovryn Protocol. 
3. Third, and most important I want to know how much this person knows about the Sovryn Protocol & Blockchain technology in general. I want to be sure specifically that this person knows more than me about the Sovryn Protocol. He might be a PHD in Quantum Mechanics, but if he doesn't know anything about Sovryn and its vision then I am not going delegate my precious voting power to him.

## Solutions
### For #1 & #2
The first 2 problems are easy. We can easily build a dapp which queries the blockchain for the "ProposalCreated" & "VoteCast" events emitted by the Sovryn's Governor contract and show them in a beautiful frontend. The user must be able to search by delegator address.

### For #3
But the 3rd problem is a little tricky. How do you figure out how knowledgable someone is about the Sovryn Protocol? <br>Well, back in school, how did our teachers figure out who is good in mathematics and who is bad?<br> Tests right!!!<br> And thats the path I took. Tests, But on the BLOCKCHAIN!<br> 
I created a protocol which I am calling (Ahhaahh) <strong>Proof Of Knowledge</strong>. More details below.


## 1. [DAPP](https://sovryn-delegator.vercel.app/)

<img src="https://user-images.githubusercontent.com/47485188/125639754-ecb44053-750c-408f-b39b-776e7e1253d9.png"></img>

You can test it here:
https://sovryn-delegator.vercel.app/

Just enter the address of any Sovryn staker in the search bar and click on the search button, and the dapp will output a list of the Proposals Created & the Proposals Voted by that address.

Note: The dapp is querying the events from this Sovryn governor address : 0xfF25f66b7D7F385503D70574AE0170b6B1622dAd

The Delegator Score is just static for now. 

## 2. Proof Of Knowledge (Whitepaper)
### Introduction:
The main idea is to organize a series of periodic tests with each test containing a fixed number of multiple choice questions, which will be decided in advance by a single owner. The scoring will be based on a weighted formula, such that as time passes, the old test scores are given less weight and the most recent test scores are given more weight for the total score calculation of a user.

The questions are to be multiple choice questions. Because when the user submits the answers, he/she will be submitting an array of length q (q being the total number of questions) with each value being a number between 0 to n. (n being the total choices for each question)

### Process:
First the owner adds a test with parameters "starting time of the test" & "ending time of the test". Note that the questions for the test are not added directly while adding the test. <br>

<strong>addTest(uint startingTime, uint endingTime)</strong><br>
```
params: (startingTime) => starting time of the test , (endingTime) => ending time of the test (in epoch seconds)

info: automatically calculates the test id and adds the test to the contract as the upcoming test. 

events: emits event TestAdded(id, startingTime, endingTime)

access: only owner
```

Then just 5 mins before the starting time of the test, the owner adds the questions for the test. If the owner tries to add the questions anytime before that, then the smart contract will simply give an error and revert. This "5 mins" is constant and cannot be changed after the deployment of the contract (If you want to change it, you have to change the constant value before deploying contract). Since nothing on the blockchain is private, so the questions are to be added separately like this, just few mins before the test starting time to prevent leaking of questions before the test.

<strong>addQuestions(string[10] memory newQuestions)</strong>
```
params: (newQuestions) => array of strings with each string being the question with the answer choices. E.g ["Which sidechain is sovryn deployed to? 0)Polygon 1)RSK 2)Ethereum 3)Bitcoin", ...]

info: Adds these questions for the current upcoming test

events: emits event TestQuestionsAdded(testId, questions)

access: only owner
```

Before submitting answers, the user has to first add himself/herself as a delegator to the contract. This function has to be called just once (just like the approve function of an erc20 contract). Once done, the user will be able to participate in tests & the contract will track of his/her score.

<strong>addDelegator()</strong>
```
info: adds msg.sender as delegator

events: emits event DelegatorAddress(delegator, time)

access: public
```

Next the user has to wait till the test starts. The user first views the questions for the test (The user cannot view the questions before the test starting time).

<strong>getCurrentTestQuestions()</strong>
```
info: returns the questions for the current test

access: public
```

 Then the user submits his answers all at once, by sending an array of length q (q being the total number of questions) with each value being a digit between 0 to n (n being the total choices for each question).

 <strong>submitAnswers(uint8[10] answers)</strong>
 ```
 params: (answers) => array containing answers for all the questions of the current test. E.g => [0,1,1,2,3,1,0,1,0,1]

 info: submits the user's answers for the current test to the contract for later scoring

 access: public
 ```

Once done, the owner has to wait till the test is over to call one single function which will finish the test. This will update the scores of all the delegators. The owner will submit a similar array (of length q) to the one that the user submitted but with the correct values as parameter. This array will be used for score calculation of the users. 

<strong>finishTest(uint8[10] answers)</strong>
```
params: (answers) => array containing the correct answers for all the questions of the current test. E.g => [0,1,1,2,3,1,0,1,0,1]. The delegators will be scored bases on this array

info: updates the scores for all the delegators. also sets a new random owner from the board members. 

events: emits events AnswersUpdated(testId, answers), NewOwner(owner, time)

access: only owner
```

### Rules (coded into the smart contract):
1. A user must first add himself/herself as a delegator in the POK contract. 
2. Delegators can only submit answers after the test starting time & before the test ending time.
3. A delegator cannot attempt a test more than once.
4. Though the test can be added, much before the actual starting time of the test, the questions for the test can only be submitted 5 mins before the test starting time.
5. The owner cannot submit answers & update scores before the test ending time.
### Scoring Formula:

### The Board Contract:
### Notes: 
Talk about how the questions should be designed

### Events:


## Setup & Installation:

## Proof of Knowledge
1. can only give the test once
2. POK Score = Sum of the total number of questions for all tests in all periods divided by the answers that you got right till now
    So if someone doesn't give a test during a period, then by default he gets zero in all the questions on that test
3. But there is a loophole here. So suppose the total questions till now are 20, then on the next test, losing all 10 of them will
    reduce your score significantly. But if there are like 1500 total tests till now, then getting 10 wrong on the next test
    wont matter shit. So a good fix will be weighted testing, with more recent tests having a higher weight and older tests having a lower one.


# POK Tests
1. On every test there will be 10 questions
2. You must have staked SOV to participate in the test (optional)
3. You can attempt the test only once on test day
4. Tests will be held periodically with questions to be decided by the admin team
5. A test will have a fixed time interval (starting time & ending time) between which a user has to do it.
6. A list of addresses need to be set as admins at contract inception, and every week a person among them will be chosen to figure out the questions for the upcoming test



## Setup
//TODO: Launch the frontend dapp on heroku
Replace the cvKey in next.config.js with your covalent api key
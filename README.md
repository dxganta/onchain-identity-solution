# Onchain Identity

## Problem
To tackle this problem, I first asked myself a simple question:
### If I was a staker in the Sovryn Protocol, then what would convince me to make someone a delegator?
1. First I would want to know what are the SIPs that he voted for in the past. I would want to know what his votes were for each SIP. This would give me an idea if his vision agrees with mine.
2. Next I would want to know if she has created any SIPs herself in the past. This would give me further information about her knowledge and vision of the Sovryn Protocol. 
3. Third, and most important I want to know how much this person knows about the Sovryn Protocol & Blockchain technology in general. I want to be sure specifically that this person knows more than me about the Sovryn Protocol. He might be a PHD in Quantum Mechanics, but if he doesn't know anything about Sovryn and its vision then I am not going to delegate my precious voting power to him.

## Solutions
### For #1 & #2
For the first 2 problems, I built a dapp which queries the blockchain for the Proposals Created & the Votes Cast by a delegator and shows them in a simple frontend. The user is able to search by delegator address.

### For #3
But the 3rd problem is a little tricky. How do you figure out how knowledgable someone is about the Sovryn Protocol? <br>Well, back in school, how did our teachers figure out who is good in mathematics and who is bad?<br> Tests right!!!<br> And thats the path I took. Tests, But on the BLOCKCHAIN!<br> 
I created a protocol which I am calling (Ahhaahh) <strong>Proof Of Knowledge</strong>. More details below.


## 1. [DAPP](https://sovryn-delegator.vercel.app/)

<img src="https://user-images.githubusercontent.com/47485188/125639754-ecb44053-750c-408f-b39b-776e7e1253d9.png"></img>

You can test it here:
https://sovryn-delegator.vercel.app/

Just enter the address of any Sovryn staker in the search bar and click on the search button, and the dapp will output a list of the Proposals Created & the Proposals Voted by that address.

Note: The dapp is querying the events from this Sovryn governor address : 0xfF25f66b7D7F385503D70574AE0170b6B1622dAd

```
The Delegator Score is just static for now. This score needs to be calculated later from the Proof of Knowledge Protocol detailed below.
```

## 2. [Proof Of Knowledge](https://github.com/realdiganta/onchain-identity-solution/tree/main/proof_of_knowledge)
### Introduction:
The main idea is to organize a series of on-chain periodic tests with each test containing a fixed number of multiple choice questions, which will be decided in advance by a single owner. The scoring will be based on a weighted formula, such that as time passes, the old test scores are given less weight and the most recent test scores are given more weight for the total score calculation of a user.

The questions are to be multiple choice questions. Because when the user submits the answers, he/she will be submitting an array of length q (q being the total number of questions) with each value being a number between 0 to n. (n being the total choices for each question)

### Process:
First the owner adds a test with parameters "starting time of the test" & "ending time of the test". Note that the questions for the test are not added directly while adding the test. <br>

<strong>addTest(uint startingTime, uint endingTime)</strong><br>
```
params: (startingTime) => starting time of the test , (endingTime) => ending time of the test (in epoch seconds)

info: automatically assigns the test a test id  and adds the test to the contract as the upcoming test. 

events: emits event TestAdded(id, startingTime, endingTime)

access: only owner
```

Then just 5 mins before the starting time of the test, the owner adds the questions for the test. If the owner tries to add the questions anytime before that, then the smart contract will simply give an error and revert. This "5 mins" is constant and cannot be changed after the deployment of the contract (If you want to change it, you have to change the constant value before deploying contract). Since nothing on the blockchain is private, so the questions are to be added separately like this, just few mins before the test starting time to prevent leaking of questions before the test.

<strong>addQuestions(string[10] memory newQuestions)</strong>
```
params: (newQuestions) => array of strings with each string being the question with the answer choices. E.g ["Which sidechain is sovryn deployed to? 0)Polygon 1)RSK 2)Ethereum 3)Bitcoin", "How much leverage does Sovryn offer? 0)3x 1)2x 2)10x 3)5x "...]

info: Adds these questions for the current upcoming test

events: emits event TestQuestionsAdded(testId, questions)

access: only owner
```

Before submitting answers, the user has to first add himself/herself as a delegator to the contract. This function has to be called just once (just like the approve function of an erc20 contract). Once done, the user will be able to participate in tests & the contract will track his/her score.

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

 Then the user submits her answers all at once, by sending an array of length q (q being the total number of questions) with each value being a digit between 0 to n (n being the total choices for each question).

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
4. Though the test can be added much before the actual starting time of the test, the questions for the test can only be submitted 5 mins before the test starting time.
5. The owner cannot submit answers & update scores before the test ending time.
### Scoring Formula:
No doubt the most important part of Proof of Knowledge is the scoring. There are 2 main questions here: First how do you score delegators on each test? And second, how do you add that score to the previous scores of the delegator to get a net score?

Let 'q' be the total number of questions for each test<br>
<br>
Let 'm' be the number of questions that the delegator got correct on a particular test 'i'<br>
Then the score of the delegator on Test i will be<br><br>
<img src="https://user-images.githubusercontent.com/47485188/125774765-bde30d44-ceed-4db4-bf70-c05bc1d93f5e.png" align="centre"></img>

Now for the first test, the score of each delegator will be whatever comes from the above equation. 

But what about the next test? Do we just use the above formula again to calculate the delegator's score and then take the average of the previous score and the new score. And keep on doing this for every new test. Yes that can be a probable solution. But think about what will happen on the 100th test. Suppose the delegator has scored on average 80% on all previous tests. Now even if he scores 0 on the 100th test, it wont effect his score much. This corrupts the delegator score giving by giving a high delegator score to a delegator who may not deserve it. This also works oppposite. Suppose if a delegator has scored on average 50% for the past 99 tests. Getting even a 10 score on the 100th test will increase his score by only a very small amount. This disincentivizes delegators to keep themselves updated with the new advancements of the Sovryn protocol and of blockchain tech.<br>

So to fix this, and to incentivize users to keep scoring high numbers on new tests, a weighted scoring formula is being used, where instead of the average, a fixed percentage of the previous score will be added to a fixed percent of the new score.

Suppose for test 'n', the user gets 'm' questions correct out of total 'q' questions.

Let 'α' be the percentage for previous score of delegator.
Let 'β' be the percentage for new score of delegator.

So for test 'n' the net score of the user will be:<br><br>
<img src="https://user-images.githubusercontent.com/47485188/125777336-efa7528e-d8d7-4c5e-a382-b72a059e6ad6.png">

Currently in the contract, α has been set to 65% & β to 35%. But these values can be changed by the owner.

The higher the β, the higher the weight on your new scores, the higher is the cost for missing a test. So even if you have a perfect score of 100% on all your previous 999 tests, missing the 1000th test would reduce your score directly to 65%. This incentivizes delegators to keep giving tests to maintain a high score and keep themselves updated with the newest knowledge.

The higher the α, the higher is the weight on your previous scores, the higher the incentives for being giving tests for a long time. So if some delegator starts attempting tests from the 19th test, then even if she scores a full 10 on that test, her net score will only be 35%. She has to slowly work her way up to a higher score. This incentivizes delegators to keep giving tests from as early as possible.
```
Note: Only for the 1st test of POK, the delegator gets 100% of what she scores. So yeah,  giving the first test is a very good idea.
```

```
Note: The scores have been scaled up to 10**18 decimals. So on the frontend divide the score by 10**18 then multiply with 100 to get the score in percent.
```

```
The maximum score is 100% & minimum 0%.
```

### [The Board Contract](https://github.com/realdiganta/onchain-identity-solution/blob/main/proof_of_knowledge/contracts/Board.sol)
There is another very important question. 
<strong>Who makes the questions?</strong><br><br>
Firstly, the questions for a particular test needs to be made by only 1 person, so that there are less chances of question paper leakage. Secondly, won't that make the contract a bit centralized?

So to fix this problem, I have designed a new Board Contract which is a slight modification of the very famous Ownable Contract

At contract deployment, we have to supply an array of EOA addresses. These addresses will be the board members for the contract.

After every test finishes, a new owner will be chosen at random from these board members and it will be the job of that owner to organize the next test.<br>

New board members can be added only by the approval of all the current board members. First each board member has to vote the new member individually using the <strong>voteNewMember(address newMember)</strong> function.<br>
Then if all the board members have approved the new member, he/she can be added to the board members array using the <strong>addNewMember(address newMember)</strong> function.

## Future Improvement Plans
### For Dapp
1. Alongwith the proposals created by a delegator, it would not be a bad idea to also show the "yes" & "no" votes for that proposal.
2. For the votes cast by a delegator, it would be better to also show the final votes that the proposal got. This would give a user information about whether the delegator voted on the side that won or not.
3. Also, after (or if) integrating Proof of Knowledge into Sovryn Protocol, we can show the Delegator Score in the Dapp Frontend. Thus, the dapp frontend will be a one-stop destination for an <strong>ONCHAIN PSEUDONYMOUS IDENTITY</strong> for a delegator.
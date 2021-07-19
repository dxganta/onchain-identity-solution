import React, { useState } from 'react';
import 'font-awesome/css/font-awesome.min.css';
import ProposalCreatedCard from '../components/ProposalCreatedCard';
import ProposalVotedForCard from '../components/ProposalVotedForCard';
import {
  getProposalCreateObjects,
  getProposalVoteObjects,
} from '../repo/getData';
import config from '../config';
function Home({ proposalCreateObjects, proposalVoteObjects }) {
  const [address, setAddress] = useState('');
  const [showAddress, setShowAddress] = useState(config.demoDelegator);
  const [_proposalCreateObjects, setProposalCreateObjects] = useState(
    proposalCreateObjects
  );
  const [_proposalVoteObjects, setProposalVoteObjects] = useState(
    proposalVoteObjects
  );
  const [loading, setLoading] = useState(false);

  const filterProposalCreateCards = () => {
    let totalCards = [];
    for (var i = 0; i < _proposalCreateObjects.length; i++) {
      let p = _proposalCreateObjects[i];
      totalCards.push(
        <ProposalCreatedCard
          key={i}
          id={p.id}
          title={p.title}
          createdAt={p.createdAt}
          endsAt={p.endsAt}
        />
      );
    }
    return totalCards;
  };

  const filterProposalVotedCards = () => {
    let totalCards = [];
    for (var i = 0; i < _proposalVoteObjects.length; i++) {
      let p = _proposalVoteObjects[i];
      totalCards.push(
        <ProposalVotedForCard
          key={i}
          title={p.title}
          id={p.proposalId}
          votes={p.numOfVotes}
          vote={p.vote}
        />
      );
    }
    return totalCards;
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    const proposalCreateObjects = await getProposalCreateObjects(address);
    const proposalVoteObjects = await getProposalVoteObjects(address);

    setProposalCreateObjects(proposalCreateObjects);
    setProposalVoteObjects(proposalVoteObjects);
    setShowAddress(address);
    setAddress('');
    setLoading(false);
  };

  return (
    <div className='bg-gray-800 min-h-screen'>
      {/* top black bar */}
      <div className='bg-black h-20'></div>
      {/* delegate search bar & button  */}
      <div className='md:container md:mx-auto mx-7'>
        <form className='mt-8' onSubmit={onSubmit}>
          <input
            value={address}
            placeholder='Delegator address'
            className='h-9 rounded-md outline-none w-2/4 px-3'
            onChange={(e) => setAddress(e.target.value)}
          ></input>
          <button
            type='submit'
            className='ml-4 px-8 h-9 rounded-md font-bold text-white text-lg bg-tinty'
          >
            {loading ? (
              <i className='fa fa-lg fa-circle-o-notch fa-spin text-white'></i>
            ) : (
              <span>Search</span>
            )}
          </button>
        </form>
        <div className='mt-2 text-yellow-400 text-sm'>{showAddress}</div>
        <div className='mt-8 text-2xl text-white font-semibold'>
          Delegator Score:{' '}
          <span className='text-xl text-gray-300 font-normal'>TBD</span>
        </div>
        <div className='mt-8 text-2xl text-white font-semibold'>
          Proposals Created
        </div>
        <div className='grid grid-cols-1'>{filterProposalCreateCards()}</div>
        <div className='mt-8 text-2xl text-white font-semibold'>
          Proposals Voted For
        </div>
        <div className='grid grid-cols-1'>{filterProposalVotedCards()}</div>
        <div className='pb-20'></div>
      </div>
    </div>
  );
}

export async function getStaticProps(context) {
  const proposalCreateObjects = await getProposalCreateObjects(
    config.demoDelegator
  );
  const proposalVoteObjects = await getProposalVoteObjects(
    config.demoDelegator
  );

  console.log(proposalCreateObjects[0]);
  return {
    props: {
      proposalCreateObjects,
      proposalVoteObjects,
    },
  };
}

export default Home;

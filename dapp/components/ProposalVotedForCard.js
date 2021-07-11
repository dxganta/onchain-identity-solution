import React, { Component } from 'react';
import TitleValueCard from './TitleValueCard';

const ProposalVotedForCard = ({ title, id, votes, vote }) => {
  votes = Math.floor(votes / 10 ** 18);
  return (
    <div className='mt-4 bg-gray-700 rounded-lg px-3 py-3'>
      <TitleValueCard title='Proposal Id' value={id} />
      <TitleValueCard title='Title' value={title} />
      <TitleValueCard title='Votes' value={votes} />
      <div className='py-2'>
        <span className='text-base text-white font-bold pr-2'>
          Delegator's Vote :
        </span>
        {vote ? <YesCard /> : <NoCard />}
      </div>
    </div>
  );
};

const YesCard = () => {
  return <span className='px-2 py-1 bg-green-500 rounded-md'>Yes</span>;
};

const NoCard = () => {
  return <span className='px-2 py-1 bg-red-500 rounded-md'>No</span>;
};

export default ProposalVotedForCard;

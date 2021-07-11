import React, { Component } from 'react';
import TitleValueCard from './TitleValueCard';

const ProposalCreatedCard = ({ title, createdAt, endsAt }) => {
  return (
    <div className='mt-4 bg-gray-700 rounded-lg px-3 py-3'>
      <TitleValueCard title='Title' value={title} />
      <TitleValueCard title='Created At' value={`Block #${createdAt}`} />
      <TitleValueCard title='Voting Ends' value={`Block #${endsAt}`} />
    </div>
  );
};

export default ProposalCreatedCard;

import React, { Component } from 'react';
import TitleValueCard from './TitleValueCard';

class ProposalVotedForCard extends Component {
  render() {
    return (
      <div className='mt-4 w-80 bg-gray-700 rounded-lg px-3 py-3'>
        <TitleValueCard
          title='Title'
          value='SIP 00005 Appeal to withdraw SOV Assets.'
        />
        <TitleValueCard
          title='Description'
          value='lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsumlorem ipsum lorem ipsum lorem ipsum lorem ipsum'
        />
        <div className='py-2'>
          <span className='text-base text-white font-bold pr-2'>
            Delegator's Vote :
          </span>
          <span className='px-2 py-1 bg-green-500 rounded-md'>Yes</span>
        </div>
        <div>
          <span className='text-base text-white font-bold pr-1'>
            Final Vote :
          </span>
          <span className='px-2 py-1 bg-red-500 rounded-md'>No</span>
        </div>{' '}
      </div>
    );
  }
}

export default ProposalVotedForCard;

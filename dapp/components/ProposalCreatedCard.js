import React, { Component } from 'react';
import TitleValueCard from './TitleValueCard';

class ProposalCreatedCard extends Component {
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
        <TitleValueCard title='Created At' value='15 Jan 2021' />
        <TitleValueCard title='Voting Ends' value='1 Aug 2021' />
      </div>
    );
  }
}

export default ProposalCreatedCard;

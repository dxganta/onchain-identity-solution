import React, { Component } from 'react';
import ProposalCreatedCard from '../components/ProposalCreatedCard';
import ProposalVotedForCard from '../components/ProposalVotedForCard';

class Home extends Component {
  filterProposalCreateCards() {
    let totalCards = [];
    for (var i = 0; i < 2; i++) {
      totalCards.push(<ProposalCreatedCard />);
    }
    return totalCards;
  }

  filterProposalVotedCards() {
    let totalCards = [];
    for (var i = 0; i < 4; i++) {
      totalCards.push(<ProposalVotedForCard />);
    }
    return totalCards;
  }

  render() {
    return (
      <div className='bg-gray-800 min-h-screen'>
        {/* top black bar */}
        <div className='bg-black h-20'></div>
        {/* delegate search bar & button  */}
        <div className='container mx-auto'>
          <form className='mt-8'>
            <input
              placeholder='Delegate address'
              className='h-9 rounded-md outline-none w-2/4 px-3'
            ></input>
            <button className='ml-4 px-8 h-9 rounded-md font-bold text-white text-lg bg-tinty'>
              SEARCH
            </button>
          </form>
          <div className='mt-8 text-2xl text-white font-semibold'>
            Proposals Created
          </div>
          <div className='grid grid-cols-2 w-170'>
            {this.filterProposalCreateCards()}
          </div>
          <div className='mt-8 text-2xl text-white font-semibold'>
            Proposals Voted For
          </div>
          <div className='grid grid-cols-2 w-170'>
            {this.filterProposalVotedCards()}
          </div>
        </div>
      </div>
    );
  }
}

export default Home;

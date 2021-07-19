import React from 'react';

const TitleValueCard = ({ title, value }) => {
  return (
    <div className='py-1'>
      <span className='text-lg text-white font-bold pr-1'>{title} :</span>
      <span className='text-white text-md break-words'>{value}</span>
    </div>
  );
};

export default TitleValueCard;

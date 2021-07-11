import { cleanProposalCreateObjects, cleanProposalVoteObjects } from './clean';
import config from '../config';

const getProposalCreateObjects = async (delegatorAddress) => {
  const url = `${config.baseUrl}&match={ "decoded.name": "ProposalCreated", "decoded.params.1.value":"${delegatorAddress}"}`;
  var res = await fetch(url);
  const data = await res.json();
  const proposalCreateObjects = cleanProposalCreateObjects(data.data.items);

  return proposalCreateObjects;
};

const getProposalVoteObjects = async (delegatorAddress) => {
  var res = await fetch(
    `${config.baseUrl}&match={ "decoded.name": "VoteCast", "decoded.params.0.value" :${delegatorAddress}}`
  );

  const data = await res.json();
  const proposalVoteObjects = await cleanProposalVoteObjects(data.data.items);
  return proposalVoteObjects;
};

module.exports = {
  getProposalCreateObjects,
  getProposalVoteObjects,
};

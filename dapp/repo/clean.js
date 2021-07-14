import config from '../config';

const cleanProposalCreateObjects = (items) => {
  let objects = [];

  for (var i = 0; i < items.length; i++) {
    objects.push({
      id: items[i].decoded.params[0].value,
      title: items[i].decoded.params[8].value,
      createdAt: items[i].decoded.params[6].value,
      endsAt: items[i].decoded.params[7].value,
    });
  }

  return objects;
};

const cleanProposalVoteObjects = async (items) => {
  let objects = [];

  for (var i = 0; i < items.length; i++) {
    // proposal id to proposal description
    const proposalId = items[i].decoded.params[1].value.toString();

    var res = await fetch(
      `${config.baseUrl}&match={ "decoded.name": "ProposalCreated", "decoded.params.0.value":"${proposalId}"}`
    );
    const data = await res.json();
    const title = data.data.items[0].decoded.params[8].value;

    objects.push({
      numOfVotes: items[i].decoded.params[3].value,
      vote: items[i].decoded.params[2].value,
      proposalId,
      title,
    });
  }

  return objects;
};

module.exports = {
  cleanProposalCreateObjects,
  cleanProposalVoteObjects,
};

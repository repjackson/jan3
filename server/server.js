Meteor.methods({
  async agg2() {
  pipe = [
    {
      $match: {
        type: 'schema'
      }
    }, {
      $project: {
        tags: 1
      }
    }, {
      $unwind: "$tags"
    }, {
      $group: {
        _id: '$tags',
        count: {
          $sum: 1
        }
      }
    }, {
      $sort: {
        count: -1,
        _id: 1
      }
    }, {
      $limit: 20
    }, {
      $project: {
        _id: 0,
        name: '$_id',
        count: 1
      }
    }
  ];
    const options = { explain:false };
    return Docs.rawCollection().aggregate(pipe, options).forEach(function(doc) { console.dir(doc); });
  },
});

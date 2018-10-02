Meteor.publish 'facet', (
    selected_levels
    selected_timestamp_tags
    selected_customers
    selected_offices
    type
    )->

        self = @
        match = {}

        match.type = 'ticket'
        console.log selected_timestamp_tags

        if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags
        if selected_customers.length > 0 then match.customer_name = selected_customers[0]
        if selected_offices.length > 0 then match.ticket_office_name = selected_offices[0]

        # console.log 'match:', match

        # ancestor_ids_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: ancestor_array: 1 }
        #     { $unwind: "$ancestor_array" }
        #     { $group: _id: '$ancestor_array', count: $sum: 1 }
        #     { $match: _id: $nin: selected_ancestor_ids }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'theme ancestor_ids_cloud, ', ancestor_ids_cloud
        # ancestor_ids_cloud.forEach (ancestor_id, i) ->
        #     self.added 'ancestor_ids', Random.id(),
        #         name: ancestor_id.name
        #         count: ancestor_id.count
        #         index: i

        # theme_tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: tags: 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: '$tags', count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
        # theme_tag_cloud.forEach (tag, i) ->
        #     self.added 'tags', Random.id(),
        #         name: tag.name
        #         count: tag.count
        #         index: i




        timestamp_tags_cloud = Docs.aggregate [
            { $match: match }
            { $project: timestamp_tags: 1 }
            { $unwind: "$timestamp_tags" }
            { $group: _id: '$timestamp_tags', count: $sum: 1 }
            { $match: _id: $nin: selected_timestamp_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud
        timestamp_tags_cloud.forEach (timestamp_tag, i) ->
            self.added 'timestamp_tags', Random.id(),
                name: timestamp_tag.name
                count: timestamp_tag.count
                index: i

        level_cloud = Docs.aggregate [
            { $match: match }
            { $project: level: 1 }
            { $group: _id: '$level', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud
        level_cloud.forEach (level, i) ->
            self.added 'levels', Random.id(),
                name: level.name
                count: level.count
                index: i



        customer_cloud = Docs.aggregate [
            { $match: match }
            { $project: customer_name: 1 }
            { $group: _id: '$customer_name', count: $sum: 1 }
            { $match: _id: $nin: selected_customers }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud
        customer_cloud.forEach (customer, i) ->
            self.added 'customers', Random.id(),
                name: customer.name
                count: customer.count
                index: i



        office_cloud = Docs.aggregate [
            { $match: match }
            { $project: ticket_office_name: 1 }
            { $group: _id: '$ticket_office_name', count: $sum: 1 }
            { $match: _id: $nin: selected_offices }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud
        office_cloud.forEach (office, i) ->
            self.added 'offices', Random.id(),
                name: office.name
                count: office.count
                index: i


        # location_tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: location_tags: 1 }
        #     { $unwind: "$location_tags" }
        #     { $group: _id: '$location_tags', count: $sum: 1 }
        #     { $match: _id: $nin: selected_location_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'location location_tag_cloud, ', location_tag_cloud
        # location_tag_cloud.forEach (location_tag, i) ->
        #     self.added 'location_tags', Random.id(),
        #         name: location_tag.name
        #         count: location_tag.count
        #         index: i


        # author_match = match
        # # author_match.published = 1

        # author_tag_cloud = Docs.aggregate [
        #     { $match: author_match }
        #     { $project: author_id: 1 }
        #     { $group: _id: '$author_id', count: $sum: 1 }
        #     { $match: _id: $nin: selected_author_ids }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, text: '$_id', count: 1 }
        #     ]


        # # console.log author_tag_cloud

        # # author_objects = []
        # # Meteor.users.find _id: $in: author_tag_cloud.

        # author_tag_cloud.forEach (author_id) ->
        #     self.added 'author_ids', Random.id(),
        #         text: author_id.text
        #         count: author_id.count

        # found_docs = Docs.find(match).fetch()
        # console.log 'match', match
        # console.log 'found_docs', found_docs
        # found_docs.forEach (found_doc) ->
        #     self.added 'docs', doc._id, fields
        #         text: author_id.text
        #         count: author_id.count

        # doc_results = []
        subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
            added: (id, fields) ->
                # console.log 'added doc', id, fields
                # doc_results.push id
                self.added 'docs', id, fields
            changed: (id, fields) ->
                # console.log 'changed doc', id, fields
                self.changed 'docs', id, fields
            removed: (id) ->
                # console.log 'removed doc', id, fields
                # doc_results.pull id
                self.removed 'docs', id
        )

        # for doc_result in doc_results

        # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
        #     added: (id, fields) ->
        #         # console.log 'added doc', id, fields
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         # console.log 'changed doc', id, fields
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         # console.log 'removed doc', id, fields
        #         self.removed 'docs', id
        # )



        # console.log 'doc handle count', subHandle

        self.ready()

        self.onStop ()-> subHandle.stop()
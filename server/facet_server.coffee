Meteor.publish 'facet', (
    selected_levels
    selected_customers
    selected_franchisees
    selected_offices
    selected_timestamp_tags
    selected_status
    selected_ticket_types
    type
    )->

        self = @
        match = {}

        match.type = 'ticket'

        if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags
        if selected_customers.length > 0 then match.customer_name = selected_customers[0]
        if selected_franchisees.length > 0 then match.ticket_franchisee = selected_franchisees[0]
        if selected_offices.length > 0 then match.ticket_office_name = selected_offices[0]
        if selected_levels.length > 0 then match.level = selected_levels[0]
        if selected_status.length > 0 then match.open = selected_status[0]
        if selected_ticket_types.length > 0 then match.ticket_type = selected_ticket_types[0]


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
        timestamp_tags_cloud.forEach (timestamp_tag, i) ->
            self.added 'timestamp_tags', Random.id(),
                name: timestamp_tag.name
                count: timestamp_tag.count
                index: i


        ticket_types_cloud = Docs.aggregate [
            { $match: match }
            { $project: ticket_type: 1 }
            { $unwind: "$ticket_type" }
            { $group: _id: '$ticket_type', count: $sum: 1 }
            { $match: _id: $nin: selected_ticket_types }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        ticket_types_cloud.forEach (ticket_type, i) ->
            self.added 'ticket_types', Random.id(),
                name: ticket_type.name
                count: ticket_type.count
                index: i


        level_cloud = Docs.aggregate [
            { $match: match }
            { $project: level: 1 }
            { $group: _id: '$level', count: $sum: 1 }
            { $match: _id: $nin: selected_levels }
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

        status_cloud = Docs.aggregate [
            { $match: match }
            { $project: open: 1 }
            { $group: _id: '$open', count: $sum: 1 }
            { $match: _id: $nin: selected_status }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud
        status_cloud.forEach (status, i) ->
            self.added 'status', Random.id(),
                name: status.name
                count: status.count
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



        franchisee_cloud = Docs.aggregate [
            { $match: match }
            { $project: ticket_franchisee: 1 }
            { $group: _id: '$ticket_franchisee', count: $sum: 1 }
            { $match: _id: $nin: selected_franchisees }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        franchisee_cloud.forEach (franchisee, i) ->
            self.added 'franchisees', Random.id(),
                name: franchisee.name
                count: franchisee.count
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



        # # author_objects = []
        # # Meteor.users.find _id: $in: author_tag_cloud.

        # author_tag_cloud.forEach (author_id) ->
        #     self.added 'author_ids', Random.id(),
        #         text: author_id.text
        #         count: author_id.count

        # found_docs = Docs.find(match).fetch()
        # found_docs.forEach (found_doc) ->
        #     self.added 'docs', doc._id, fields
        #         text: author_id.text
        #         count: author_id.count

        # doc_results = []
        subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
            added: (id, fields) ->
                # doc_results.push id
                self.added 'docs', id, fields
            changed: (id, fields) ->
                self.changed 'docs', id, fields
            removed: (id) ->
                # doc_results.pull id
                self.removed 'docs', id
        )

        # for doc_result in doc_results

        # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
        #     added: (id, fields) ->
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         self.removed 'docs', id
        # )




        self.ready()

        self.onStop ()-> subHandle.stop()


Meteor.publish 'facet_doc', (facet_id)->
    # if facet_id
    #     Docs.find facet_id
    # else
    Docs.find type:'facet'

Meteor.methods
    fi: (args, facet_id)->
        facet = Docs.findOne facet_id
        query = {}

    fa:(arg, facet_id)->
        facet = Docs.findOne facet_id
        Docs.update facet_id,
            $addToSet:
                args: arg

    fo: (facet_id)->
        facet = Docs.findOne facet_id
        query = {}
        for arg in facet.args
            console.log 'arg', arg
            query["#{arg.key}"] = "#{arg.value}"
        console.log query
        count = Docs.find(query).count()
        Docs.update facet_id,
            $set:
                count:count
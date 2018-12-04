Docs.allow
    insert: (user_id, doc) -> true
    remove: (user_id, doc) -> true
    update: (user_id, doc) -> true


Meteor.publish 'delta', ->
    Docs.find({type:'delta'})


# facet macro to find documents
# facet micro to view into/manipulate docs



Meteor.methods
    keys: ->
        start = Date.now()
        console.log 'starting keys'
        cursor = Docs.find({keys:$exists:false}, {limit:10000}).fetch()
        for doc in cursor
            keys = _.keys doc
            # console.log doc
            Docs.update doc._id,
                $set:keys:keys
            
            console.log "updated keys for doc #{doc._id}"
        stop = Date.now()
        
        diff = stop - start
        # console.log diff
        console.log moment(diff).format("HH:mm:ss:SS")
        
    fo: ->
        delta = Docs.findOne
            type:'delta'

        built_query = { keys: {$exists:true} }

        filter_keys = []
        
        facets = [
            {
                key:'keys'
                primitive:'array'
            }
        ]

        
        # include existing filter selections
        if delta.active_facets
            for key in delta.active_facets
                filter_list = delta["filter_#{key}"]
                if filter_list
                    built_query["#{key}"] = $all: filter_list
    
        # need to normalize list of existing filters
        # so normalizing keys in the fo method, ~abstracting my own server code
        
        # for filter in facets
        #     unless filter.key in filter_keys
        #         filter_keys.push filter.key

        # call
        for key in facets
            filter_list = delta["filter_#{key}"]
            if filter_list and filter_list.length > 0
                if facet.primitive is 'array'
                    # need auto discovery, even for user_ids, thats the intelligence, not just primitive detection.  so this section will evolve.
                    built_query["#{key}"] = $all: filter_list
                else
                    built_query["#{key}"] = $in: filter_list
            else
                Docs.update delta._id,
                    $set: "filter_#{key}":[]


        total = Docs.find(built_query).count()
        # maybe this references keys_return?
        # hard code 'keys', then grow out
        
        # response, i think
        
        for key in facets
            values = []
            local_return = []
            
            # field type detection 
            example_doc = Docs.findOne({"#{key}":$exists:true})
            example_value = example_doc?["#{key}"]
            primitive = typeof example_value
            test_calc = Meteor.call 'agg', built_query, primitive, key

            Docs.update {_id:delta._id},
                { $set:"#{key}_return":test_calc }
                , ->

        results_cursor = Docs.find {built_query}, limit:10

        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Docs.update {_id:delta._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true


    agg: (query, type, key)->
        console.log query
        console.log type
        options = {
            explain:false
            }
            
        # intelligence
        if type in ['array','multiref']
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $unwind: "$#{key}" }
                { $group: _id: "$#{key}", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ]
        else
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $group: _id: "$#{key}", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ]

        agg = Docs.rawCollection().aggregate(pipe,options)

        res = {}
        if agg
            agg.toArray()
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
        cursor = Docs.find({keys:$exists:false}, {limit:1000}).fetch()
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
        delta = Docs.findOne type:'delta'

        built_query = { }
        
        for facet in delta.facets
            console.log facet
            if facet.filters and facet.filters.length > 0
                built_query["#{facet.key}"] = $all: facet.filters
            # else
            #     Docs.update delta._id,
            #         $addToSet:
            #             filters" 
            #             "filter_#{key}":[]

        console.log 'built query', built_query

        total = Docs.find(built_query).count()
        
        # response
        for facet in delta.facets
            values = []
            local_return = []
            
            # field type detection 
            example_doc = Docs.findOne({"#{facet.key}":$exists:true})
            example_value = example_doc?["#{facet.key}"]

            # js arrays typeof is object
            array_test = Array.isArray example_value
            if array_test
                prim = 'array'
            else
                prim = typeof example_value
            
            agg_res = Meteor.call 'agg', built_query, prim, facet.key, facet.filters

            Docs.update {_id:delta._id, "facets.key":facet.key},
                { $set: "facets.$.res": agg_res }


        results_cursor = Docs.find built_query, limit:10

        # result_ids = []
        # for result in results_cursor.fetch()
        #     result_ids.push result._id

        results = results_cursor.fetch()

        Docs.update {_id:delta._id},
            {$set:
                total: total
                results:results
            }, ->
        return true


    agg: (query, type, key, filters)->
        # console.log 'query agg', query
        # console.log 'type', type
        # console.log 'key', key
        options = { explain:false }
            
        # intelligence
        if type in ['array','multiref']
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $unwind: "$#{key}" }
                { $group: _id: "$#{key}", count: $sum: 1 }
                # { $match: _id: $nin: filters }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ]
        else
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $group: _id: "$#{key}", count: $sum: 1 }
                # { $match: _id: $nin: filters }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ]

        agg = Docs.rawCollection().aggregate(pipe,options)

        res = {}
        if agg
            agg.toArray()
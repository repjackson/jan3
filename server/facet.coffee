Meteor.publish 'delta', ->
    Docs.find {
        type:'delta'
        author_id: Meteor.userId()
    }, {limit:1}


# facet macro to find documents
# facet micro to view into/manipulate docs



Meteor.methods
    fo: ->
        delta = Docs.findOne
            type:'delta'
            author_id: Meteor.userId()

        built_query = { keys: {$exists:true} }

        filter_keys = []
        
        facets = [
            {
                key:'keys'
                type:'array'
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

        for facet in facets
            filter_list = delta["filter_#{facet.key}"]
            if filter_list and filter_list.length > 0
                if facet.primitive is 'array'
                    # need auto discovery, even for user_ids, thats the intelligence, not just primitive detection.  so this section will evolve.
                    built_query["#{facet.key}"] = $all: filter_list
                else
                    built_query["#{facet.key}"] = $in: filter_list
            else
                Docs.update delta._id,
                    $set: "filter_#{facet.key}":[]


        total = Docs.find(built_query).count()
        # maybe this references keys_return?
        for key in delta.keys_return
            values = []
            local_return = []
            
            # field type detection 
            example_doc = Docs.findOne({"#{facet.key}":$exists:true})
            example_value = example_doc?["#{facet.key}"]
            primitive = typeof example_value

            if primitive
                test_calc = Meteor.call 'agg', built_query, primitive, key
            else
                console.log 'no primitive', facet, 'key:', key
            Docs.update {_id:delta._id},
                { $set:"#{facet.key}_return":test_calc }
                , ->



        final_sort_key = if delta.sort_key then delta.sort_key else 'timestamp'
        final_sort_direction = if delta.sort_direction then delta.sort_direction else -1

        results_cursor =
            Docs.find( built_query,
                {
                    blocks:_id:1
                    limit:calc_page_size
                    sort:"#{final_sort_key}":final_sort_direction
                    skip:skip_amount
                }
            )

        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id



        Docs.update {_id:delta._id},
            {$set:
                page_size:calc_page_size
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
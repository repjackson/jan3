Meteor.publish 'delta', ->
    Docs.find {
        type:'delta'
        author_id: Meteor.userId()
    }, {limit:1}

Meteor.publish 'my_schemas', ->
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles
            Docs.find(
                type:'schema'
                # view_roles:$in:Meteor.user().roles
            )
        else
            Docs.find(
                type:'schema'
                view_roles:$in:Meteor.user().roles
            )


Meteor.publish 'schema_blocks', ->
    delta = Docs.findOne
        type:'delta'
        author_id: Meteor.userId()
    if delta and delta.filter_type
        current_type = delta.filter_type[0]
        schema_doc =
            Docs.findOne
                type:'schema'
                slug:current_type
        if schema_doc
            Docs.find {
                type:'block'
                archive:$ne:true
                slug: $in: schema_doc.attached_blocks
            }, limit:100

Meteor.publish 'schema', ->
    delta = Docs.findOne
        type:'delta'
        author_id: Meteor.userId()
    if delta and delta.filter_type
        current_type = delta.filter_type?[0]
        Docs.find
            type:'schema'
            slug: current_type


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
                key:'type'
                type:'string'
                primitive:'string'
            }
            {
                key:'tags'
                type:'array'
                primitive:'array'
            }
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
        
        for filter in facets
            unless filter.key in filter_keys
                filter_keys.push filter.key

        for facet in facets
            filter_list = delta["filter_#{facet.key}"]
            if filter_list and filter_list.length > 0
                if facet.primitive is 'array'
                    built_query["#{facet.key}"] = $all: filter_list
                else
                    built_query["#{facet.key}"] = $in: filter_list
            else
                Docs.update delta._id,
                    $set: "filter_#{facet.key}":[]


        total = Docs.find(built_query).count()

        for facet in facets
            values = []
            key_return = []
            # example_doc = Docs.findOne({"#{facet.key}":$exists:true})
            # example_value = example_doc?["#{facet.key}"]
            # primitive = typeof example_value

            if facet.primitive
                test_calc = Meteor.call 'agg', built_query, facet.primitive, facet.key
            else
                console.log 'no primitive', facet
            if facet.key
                Docs.update {_id:delta._id},
                    { $set:"#{facet.key}_return":test_calc }
                    , ->
            else
                console.log 'no delta block key', facet


        # calc_page_size = if delta.page_size then delta.page_size else 10
        calc_page_size = 10

        page_amount = Math.ceil(total/calc_page_size)

        current_page = if delta.current_page then delta.current_page else 1

        skip_amount = current_page*calc_page_size-calc_page_size

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
                current_page:current_page
                page_amount:page_amount
                skip_amount:skip_amount
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
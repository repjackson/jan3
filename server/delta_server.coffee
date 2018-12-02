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


Meteor.methods
    fo: ->
        delta = Docs.findOne
            type:'delta'
            author_id: Meteor.userId()

        current_type = delta.filter_type?[0]

        delta_blocks = []

        if delta.filter_type and delta.filter_type.length > 0
            schema =
                Docs.findOne
                    type:'schema'
                    slug:current_type
            if schema
                delta_blocks = Docs.find({
                    type:'block'
                    slug: $in: schema.attached_blocks
                    # faceted:true
                }, {sort:{rank:1}}).fetch()
        else
            return

        built_query = {}

        delta_blocks.push
            key:'type'
            primitive:'string'

        filter_keys = []
        for filter in delta_blocks
            unless filter.key in filter_keys
                filter_keys.push filter.key

        for delta_block in delta_blocks
            filter_list = delta["filter_#{delta_block.key}"]
            if filter_list and filter_list.length > 0
                if delta_block.primitive is 'array'
                    built_query["#{delta_block.key}"] = $all: filter_list
                else
                    built_query["#{delta_block.key}"] = $in: filter_list
            else
                Docs.update delta._id,
                    $set: "filter_#{delta_block.key}":[]



        # if Meteor.user().roles
        #     if 'office' in Meteor.user().roles
        #         if current_type is 'ticket'
        #             built_query['office_jpid'] = Meteor.user().office_jpid
        #     if 'customer' in Meteor.user().roles
        #         if current_type is 'ticket'
        #             built_query['customer_jpid'] = Meteor.user().customer_jpid
        if current_type is 'schema'
            unless 'dev' in Meteor.user().roles
                built_query['view_roles'] = $in:Meteor.user().roles
        # if current_type is 'customer'
        #     if Meteor.user().office_jpid
        #         my_office =
        #             Docs.findOne
        #                 type:'office'
        #                 office_jpid:Meteor.user().office_jpid
        #         built_query['office_name'] = my_office.office_name

        # if current_type is 'franchisee'
        #     if Meteor.user().office_jpid
        #         my_office =
        #             Docs.findOne
        #                 type:'office'
        #                 office_jpid:Meteor.user().office_jpid
        #         built_query['office_name'] = my_office.office_name


        total = Docs.find(built_query).count()

        for delta_block in delta_blocks
            values = []
            key_return = []
            example_doc = Docs.findOne({"#{delta_block.key}":$exists:true})
            example_value = example_doc?["#{delta_block.key}"]
            primitive = typeof example_value

            if delta_block.primitive
                test_calc = Meteor.call 'agg', built_query, delta_block.primitive, delta_block.key
            else
                console.log 'no primitive', delta_block
            if delta_block.key
                Docs.update {_id:delta._id},
                    { $set:"#{delta_block.key}_return":test_calc }
                    , ->
            else
                console.log 'no delta block key', delta_block


        # calc_page_size = if delta.page_size then delta.page_size else 10
        calc_page_size = 1

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
        # console.log query
        # console.log type
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
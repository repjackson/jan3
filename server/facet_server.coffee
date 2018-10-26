Meteor.publish 'facet', ->
    Docs.find {
            type:'facet'
            author_id: Meteor.userId()
    }, {limit:1}


Meteor.methods
    fo: ->
        facet = Docs.findOne
            type:'facet'
            author_id: Meteor.userId()

        current_type = facet.filter_type?[0]

        if facet.filter_type and facet.filter_type.length > 0
            schema =
                Docs.findOne
                    type:'schema'
                    slug:current_type
            if schema
                facet_fields =
                    Docs.find(
                        type:'field'
                        schema_slugs:$in:[current_type]
                        faceted:true
                        ).fetch()
        else
            return

        built_query = {}

        facet_fields.push
            key:'type'
            field_type:'string'

        filter_keys = []
        for filter in facet_fields
            unless filter.key in filter_keys
                filter_keys.push filter.key

        # _.values facet_fields, 'key'

        for facet_field in facet_fields
            filter_list = facet["filter_#{facet_field.key}"]
            if filter_list and filter_list.length > 0
                if facet_field.field_type is 'array'
                    built_query["#{facet_field.key}"] = $all: filter_list
                else
                    built_query["#{facet_field.key}"] = $in: filter_list
            else
                Docs.update facet._id,
                    $set: "filter_#{facet_field.key}":[]


        total = Docs.find(built_query).count()

        if Meteor.user().roles
            if current_type in ['customer', 'office']
                if 'office' in Meteor.user().roles
                    built_query['office_jpid'] = Meteor.user().office_jpid
                if 'customer' in Meteor.user().roles
                    built_query['customer_jpid'] = Meteor.user().customer_jpid


        # results = Docs.find(built_query, {limit:limit_val}).fetch()

        raw = Docs.rawCollection()
        dis = Meteor.wrapAsync raw.distinct, raw


        for facet_field in facet_fields
            values = []
            key_return = []

            # console.log 'built query', built_query
            test_count = Docs.find(built_query).count()
            # console.log 'test count', test_count

            distincts = dis(facet_field.key, built_query)
            example_doc = Docs.findOne({"#{facet_field.key}":$exists:true})
            example_value = example_doc?["#{facet_field.key}"]
            field_type = typeof example_value

            for value in distincts
                filtered_built_query = _.clone built_query
                filtered_built_query["#{facet_field.key}"] = value

                count = Docs.find(filtered_built_query).count()
                # console.log facet_field.key, count, value

                switch field_type
                    when 'number'
                        int_value = parseInt value
                        key_return.push({ value:int_value, count:count })
                    when 'boolean'
                        bool_value = if value is true then true else false
                        key_return.push({ value:bool_value, count:count })
                    when 'array'
                        key_return.push({ value:value, count:count })
                    else
                        key_return.push({ value:value, count:count })

            sorted = _.sortBy(key_return, 'count')
            reversed = sorted.reverse()

            Docs.update {_id:facet._id},
                {$set:"#{facet_field.key}_return":reversed}
                , ->

        calc_page_size = if facet.page_size then facet.page_size else 10

        page_amount = Math.ceil(total/calc_page_size)

        current_page = if facet.current_page then facet.current_page else 1

        skip_amount = current_page*calc_page_size-calc_page_size


        test_calc = Meteor.call 'agg'

        console.log test_calc


        results_cursor =
            Docs.find( built_query,
                {
                    limit:calc_page_size
                    sort:"#{facet.sort_key}":facet.sort_direction
                    skip:skip_amount
                }
                )
        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Docs.update {_id:facet._id},
            {$set:
                current_page:current_page
                page_amount:page_amount
                skip_amount:skip_amount
                page_size:calc_page_size
                total: total
                result_ids:result_ids
            }, ->
        return true


    agg: ->
        # pipeline = []
        options = {
            explain:false
            # cursor:{}
            }

        pipe =  [
            { $match: {type:'schema'} }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            # { $match: _id: $nin: selected_theme_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            # { $output: 'results' }
        ]
        # # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
        # theme_tag_cloud.forEach (tag, i) ->
        #     self.added 'tags', Random.id(),
        #         name: tag.name
        #         count: tag.count
        #         index: i
        # console.log pipe

        agg = Docs.rawCollection().aggregate(pipe,options)

        res = {}

        agg.toArray()


        # agg.forEach (doc)=>
        #     res["#{doc.name}"] = doc.count
        #     console.log 'in', res
        # console.log 'out', res

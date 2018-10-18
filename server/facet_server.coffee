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

        filter_keys = []

        if facet.filter_type and facet.filter_type.length > 0
            schema =
                Docs.findOne
                    type:'schema'
                    slug:current_type
            if schema
                fields =
                    Docs.find
                        type:'field'
                        schema_slugs:$in:[current_type]
                filter_keys = []
                for field in fields.fetch()
                    if field.faceted is true
                        filter_keys.push field.key
        else
            return
        built_query = {}

        filter_keys.push 'type'


        for filter_key in filter_keys
            filter_list = facet["filter_#{filter_key}"]
            if filter_list and filter_list.length > 0
                built_query["#{filter_key}"] = $in: filter_list
            else
                Docs.update facet._id,
                    $set: "filter_#{filter_key}":[]


        total = Docs.find(built_query).count()

        if Meteor.isDevelopment
            limit_val = 100
        if Meteor.isProduction
            limit_val = 1000

        if Meteor.user().roles
            unless 'dev' in Meteor.user().roles
                if 'office' in Meteor.user().roles
                    built_query['office_jpid'] = Meteor.user().office_jpid
                if 'customer' in Meteor.user().roles
                    built_query['customer_jpid'] = Meteor.user().customer_jpid

        results = Docs.find(built_query, {limit:limit_val})


        for filter_key in filter_keys
            values = []
            key_return = []

            example_doc = Docs.findOne({"#{filter_key}":$exists:true})
            if example_doc
                example_value = example_doc["#{filter_key}"]
            if example_value
                filter_primitive = typeof example_value
            for result in results.fetch()
                result_value = result["#{filter_key}"]
                if result_value
                    if typeof result_value is 'string'
                        if result_value.length>0
                            values.push result_value
                    else
                        values.push result_value

            counted = _.countBy(values)

            for value,count of counted
                if filter_primitive is 'number'
                    int_value = parseInt value
                    key_return.push({ value:int_value, count:count })
                else if filter_primitive is 'boolean'
                    bool_value = if value is 'true' then true else false
                    key_return.push({ value:bool_value, count:count })
                else if filter_primitive is 'string'
                    key_return.push({ value:value, count:count })

            sorted = _.sortBy(key_return, 'count')
            reversed = sorted.reverse()


            Docs.update {_id:facet._id},
                {$set:"#{filter_key}_return":reversed}
                , ->

        calc_page_size = if facet.page_size then facet.page_size else 10

        page_amount = Math.ceil(total/calc_page_size)

        current_page = if facet.current_page then facet.current_page else 1

        skip_amount = current_page*calc_page_size-calc_page_size


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

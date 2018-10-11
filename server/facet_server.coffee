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

        # console.log 'facet', facet

        if facet.filter_type and facet.filter_type.length > 0
            schema =
                Docs.findOne
                    type:'schema'
                    slug:facet.filter_type[0]
            # console.log 'schema', schema
            if schema
                filter_keys = []
                for field in schema.fields
                    if field.faceted is true
                        filter_keys.push field.slug
                # console.log 'filter_keys', filter_keys
            # return
        else
            Docs.update facet._id,
                $set:
                    total: 0
                    result_ids:[]
                    filter_type: []
                    type_return:
                        [
                            { value:'ticket' }
                            { value:'office' }
                            { value:'customer' }
                            { value:'franchisee' }
                        ]
            return true


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

        # console.log 'total', total
        # console.log 'built query', built_query
        results = Docs.find(built_query, {limit:400}).fetch()

        console.log 'filter keys', filter_keys

        for filter_key in filter_keys
            values = []
            key_return = []

            example_value = Docs.findOne({"#{filter_key}":$exists:true})

            filter_primitive = typeof example_value["#{filter_key}"]
            for result in results
                if result["#{filter_key}"]?
                    values.push result["#{filter_key}"]

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


            Docs.update facet._id,
                $set:
                    "#{filter_key}_return":reversed

        calc_page_size = if facet.page_size then facet.page_size else 10

        results_cursor =
            Docs.find( built_query,
                {
                    limit:calc_page_size
                    sort:"#{facet.sort_key}":facet.sort_direction
                }
                )
        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Docs.update facet._id,
            $set:
                total: total
                result_ids:result_ids[..10]
        return true

Meteor.publish 'facet', ->
    Docs.find
        author_id: Meteor.userId()
        type:'facet'

Meteor.methods
    fo: ->
        facet = Docs.findOne
            type:'facet'
            author_id: Meteor.userId()

        if facet.filter_type and facet.filter_type.length > 0
            if 'ticket' in facet.filter_type
                filter_keys =
                    [ 'ticket_type',
                      'ticket_franchisee',
                      'level',
                      'open',
                      'type',
                      'ticket_office_name',
                      'customer_name' ]
            else if 'event' in facet.filter_type
                filter_keys =
                    [
                        'author_id'
                        # 'text'
                        # 'timestamp'
                    ]
            else
                filter_keys = ['type']
                # return true
        else
            Docs.update facet._id,
                $set:
                    count: 0
                    result_ids:[]
                    filter_type: []
                    type_return:
                        [
                            { value:'ticket' }
                            # { value:'event' }
                        ]
            return true
                # filter_keys = ['type']


        built_query = {}


        for filter_key in filter_keys
            filter_list = facet["filter_#{filter_key}"]
            if filter_list and filter_list.length > 0
                built_query["#{filter_key}"] = $in: filter_list
            else
                Docs.update facet._id,
                    $set: "filter_#{filter_key}":[]


        count = Docs.find(built_query).count()

        results = Docs.find(built_query, {limit:300}).fetch()

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


            Docs.update facet._id,
                $set:
                    "#{filter_key}_return":key_return

        page_size = if facet.page_size then facet.page_size else 10

        results_cursor = Docs.find(built_query, limit:page_size)
        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Docs.update facet._id,
            $set:
                count: count
                result_ids:result_ids
        return true

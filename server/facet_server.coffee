Meteor.publish 'filters', (facet_id)->
    # if facet_id
    #     Docs.find facet_id
    # else
    Docs.find
        type:'filter'
        # facet_id:facet_id

Meteor.publish 'my_facets', ->
    Facets.find
        author_id: Meteor.userId()

Meteor.publish 'results', (facet_id)->
    facet = Facets.findOne facet_id

    Docs.find
        _id:$in:facet.result_ids





Meteor.methods
    fi: (args, facet_id)->
        facet = Facets.findOne facet_id
        query = {}

    fa:(arg, facet_id)->
        facet = Facets.findOne facet_id
        Facets.update facet_id,
            $addToSet:
                args: arg

    fo: (facet_id)->
        facet = Facets.findOne facet_id
        built_query = {}
        for arg in facet.args
            # query["#{arg.key}"] = "#{arg.value}"
            if arg.type is 'in'
                built_query["#{arg.key}"] = "$in":["#{arg.value}"]
            else
                built_query["#{arg.key}"] = "#{arg.value}"

        # if facet.query
            # fo_query = facet.query
        # else
            # fo_query = {}
        count = Docs.find(built_query).count()

        doc_results = Docs.find(built_query, limit:10).fetch()
        Facets.update facet_id,
            $set:
                # query:built_query
                results:doc_results
                count:count

    fum: (facet_id)->
        facet = Facets.findOne facet_id

        filters = Docs.find(
            type:'filter'
            # facet_id:facet_id
            ).fetch()
        filter_keys = []
        for filter in filters
            filter_keys.push filter.key


        for filter_key in filter_keys
            unless facet["filter_#{filter_key}"]
                Facets.update facet_id,
                    $set: "filter_#{filter_key}":[]
        query = if facet.query then facet.query else {}
        built_query = {}
        for arg in facet.args
            if arg.type is 'in'
                # built_query["#{arg.key}"] = "$in":["#{arg.value}"]
                built_query["#{arg.key}"] = "$in":[arg.value]
            else
                built_query["#{arg.key}"] = "#{arg.value}"

        for filter_key in filter_keys
            filter_list = facet["filter_#{filter_key}"]
            if filter_list and filter_list.length > 0
                built_query["#{filter_key}"] = $in: filter_list

        count = Docs.find(built_query).count()

        results = Docs.find(built_query, {limit:1000}).fetch()
        method_return = []

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

            Facets.update facet_id,
                $set:
                    "#{filter_key}":key_return

        page_size = if facet.page_size then facet.page_size else 10

        results_cursor = Docs.find(built_query, limit:page_size)
        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Facets.update facet_id,
            $set:
                count: count
                result_ids:result_ids

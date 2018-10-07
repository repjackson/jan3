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
    built_query = {}
    for arg in facet.args
        # console.log 'arg', arg
        if arg.type is 'in'
            built_query["#{arg.key}"] = "$in":["#{arg.value}"]
        else
            built_query["#{arg.key}"] = "#{arg.value}"
    # console.log 'built_query',built_query

    Docs.find built_query,
        {limit:20}





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
            # console.log 'arg', arg
            # query["#{arg.key}"] = "#{arg.value}"
            if arg.type is 'in'
                built_query["#{arg.key}"] = "$in":["#{arg.value}"]
            else
                built_query["#{arg.key}"] = "#{arg.value}"
        # console.log 'built_query',built_query

        # console.log query
        # if facet.query
            # console.log 'facet.query', facet.query
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

        console.log 'filter keys', filter_keys

        for filter_key in filter_keys
            unless facet["filter_#{filter_key}"]
                Facets.update facet_id,
                    $set: "filter_#{filter_key}":[]
        query = if facet.query then facet.query else {}
        built_query = {}
        for arg in facet.args
            console.log 'arg', arg
            if arg.type is 'in'
                # built_query["#{arg.key}"] = "$in":["#{arg.value}"]
                built_query["#{arg.key}"] = "$in":[arg.value]
            else
                built_query["#{arg.key}"] = "#{arg.value}"

        for filter_key in filter_keys
            console.log facet["filter_#{filter_key}"]
            filter_list = facet["filter_#{filter_key}"]
            if filter_list and filter_list.length > 0
                built_query["#{filter_key}"] = $in: filter_list
        console.log 'built_query', built_query

        count = Docs.find(built_query).count()

        results = Docs.find(built_query, {limit:100}).fetch()
        method_return = []

        for filter_key in filter_keys
            values = []
            key_return = []
            for result in results
                if result["#{filter_key}"]?
                    values.push result["#{filter_key}"]

            counted = _.countBy(values)

            for value,count of counted
                key_return.push({ value:value, count:count })

            Facets.update facet_id,
                $set:
                    "#{filter_key}":key_return
        Facets.update facet_id,
            $set:
                count: count
                results:results[0..10]

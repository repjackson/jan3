Meteor.publish 'filters', (facet_id)->
    # if facet_id
    #     Docs.find facet_id
    # else
    Docs.find
        type:'filter'
        facet_id:facet_id

Meteor.publish 'facets', ->
    Facets.find()

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
        # console.log 'count', count
        # self = @
        # myJSON = JSON.stringify(built_query);
        # console.log myJSON
        # String documentAsString = myJSON.replaceAll("_\\$", "\\$").replaceAll("#", ".");
        # Object q = JSON.parse(documentAsString);

        # console.log 'documentAsString', documentAsString
        # console.log 'q', q



        doc_results = Docs.find(built_query, limit:10).fetch()
        Facets.update facet_id,
            $set:
                # query:built_query
                results:doc_results
                count:count

    fum: (facet_id, key)->
        facet = Facets.findOne facet_id
        console.log 'key', key
        console.log 'facet filter', facet["filter_#{key}"]

        filters = Docs.find(
            type:'filter'
            facet_id:facet_id
            ).fetch()
        filter_keys = []
        for filter in filters
            filter_keys.push filter.key

        console.log 'filter keys', filter_keys


        unless facet["filter_#{key}"]
            Facets.update facet_id,
                $set: "filter_#{key}":[]
        query = if facet.query then facet.query else {}
        built_query = {}
        for arg in facet.args
            console.log 'arg', arg
            if arg.type is 'in'
                # built_query["#{arg.key}"] = "$in":["#{arg.value}"]
                built_query["#{arg.key}"] = "$in":[arg.value]
            else
                built_query["#{arg.key}"] = "#{arg.value}"
        if facet["filter_#{key}"].length > 0
            built_query["#{key}"] = $in: facet["filter_#{key}"]
        console.log 'built_query', built_query

        count = Docs.find(built_query).count()

        results = Docs.find(built_query, {limit:100}).fetch()
        # console.log results[1..5]
        names = []
        return_array = []
        for result in results
            if result["#{key}"]
                names.push result["#{key}"]

        counted = _.countBy(names)

        for name,count of counted
            return_array.push({ name:name, count:count })

        Facets.update facet_id,
            $set:
                "#{key}":return_array
                results:results[1..10]

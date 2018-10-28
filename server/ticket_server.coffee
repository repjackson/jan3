Meteor.publish 'session', ->
    Docs.find {
        type:'session'
        author_id: Meteor.userId()
    }, {limit:1}

Meteor.publish 'ticket_schema', ->
    Docs.find {
        type:'schema'
        slug:'ticket'
    }, {limit:1}


Meteor.publish 'ticket_fields', ->
    Docs.find({
        type:'field'
        schema_slugs: $in: ['ticket']
    }, {sort:{rank:1}})



Meteor.methods
    fe: ->
        session = Docs.findOne
            type:'session'
            author_id: Meteor.userId()

        ticket_schema =
            Docs.findOne
                type:'schema'
                slug:'ticket'
        if ticket_schema
            facet_fields =
                Docs.find(
                    type:'field'
                    schema_slugs:$in:['ticket']
                    faceted:true
                ).fetch()

        built_query = {type:'ticket'}

        filter_keys = []
        for filter in facet_fields
            unless filter.key in filter_keys
                filter_keys.push filter.key

        for facet_field in facet_fields
            filter_list = session["filter_#{facet_field.key}"]
            if filter_list and filter_list.length > 0
                if facet_field.field_type is 'array'
                    built_query["#{facet_field.key}"] = $all: filter_list
                else
                    built_query["#{facet_field.key}"] = $in: filter_list
            else
                Docs.update session._id,
                    $set: "filter_#{facet_field.key}":[]


        total = Docs.find(built_query).count()

        if Meteor.user().roles
            if 'office' in Meteor.user().roles
                built_query['office_jpid'] = Meteor.user().office_jpid
            if 'customer' in Meteor.user().roles
                built_query['customer_jpid'] = Meteor.user().customer_jpid


        facet_fields.push
            key:'type'
            field_type:'string'


        for facet_field in facet_fields
            values = []
            key_return = []

            example_doc = Docs.findOne({"#{facet_field.key}":$exists:true})
            example_value = example_doc?["#{facet_field.key}"]
            field_type = typeof example_value

            test_calc = Meteor.call 'agg', built_query, 'ticket', facet_field.key

            # console.log test_calc

            Docs.update {_id:session._id},
                { $set:"#{facet_field.key}_return":test_calc }
                , ->

        calc_page_size = if session.page_size then session.page_size else 10

        page_amount = Math.ceil(total/calc_page_size)

        current_page = if session.current_page then session.current_page else 1

        skip_amount = current_page*calc_page_size-calc_page_size

        results_cursor =
            Docs.find( built_query,
                {
                    limit:calc_page_size
                    sort:"#{session.sort_key}":session.sort_direction
                    skip:skip_amount
                }
            )

        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Docs.update {_id:session._id},
            {$set:
                current_page:current_page
                page_amount:page_amount
                skip_amount:skip_amount
                page_size:calc_page_size
                total: total
                result_ids:result_ids
            }, ->
        return true
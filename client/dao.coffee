Template.dao.onCreated ->
    @autorun -> Meteor.subscribe 'facets'
    @autorun => Meteor.subscribe 'results', FlowRouter.getQueryParam('doc_id')
    @autorun => Meteor.subscribe 'facet_doc', FlowRouter.getQueryParam('doc_id')
    @autorun => Meteor.subscribe 'type', 'ticket_type'


Template.dao.events
    'click .create_facet': (e,t)->
        new_facet_id = Facets.insert {}
        console.log new_facet_id
        Session.set 'facet_id', new_facet_id

    'click .remove_arg': (e,t)->
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $pull:args:@

    'click .call':(e,t)->
        Meteor.call 'fo', FlowRouter.getQueryParam('doc_id')

    'click .clear_results': ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        Facets.update facet._id,
            $set: docs: []

    'keyup .arg_key, keyup .arg_value': (e,t)->
        e.preventDefault()
        if e.which is 13 #enter
            facet_id = FlowRouter.getQueryParam('doc_id')
            arg_key_val = $('.arg_key').val().trim()
            arg_val_val = $('.arg_value').val().trim()
            arg = {
                key:arg_key_val
                value:arg_val_val
            }
            Meteor.call 'fa', arg, facet_id
            $('.arg_key').val('')
            $('.arg_value').val('')



Template.dao.helpers
    facet_doc: ->
        Facets.findOne FlowRouter.getQueryParam('doc_id')
    facets: -> Facets.find {}

    ticket_types: ->
        Docs.find
            type:'ticket_type'

    results: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        console.log 'count', Docs.find(facet.query).count()
        Docs.find(facet.query, limit:20)
    view_segments: -> Session.equals 'view_mode', 'segments'
    view_cards: -> Session.equals 'view_mode', 'cards'
    view_table: -> Session.equals 'view_mode', 'table'

Template.set_facet_key.helpers
    set_facet_key_class: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        if facet.query["#{@key}"] is @value then 'primary' else ''

Template.set_facet_key.events
    'click .set_facet_key': ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')

        query_key = "query.#{@key}"
        Facets.update facet._id,
            $set:"#{query_key}":@value
        Meteor.call 'fo', FlowRouter.getQueryParam('doc_id')





Template.facet.helpers
    values: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        facet["#{@key}"]

    set_facet_key_class: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        if facet.query["#{@key}"] is @value then 'primary' else ''

Template.facet.events
    # 'click .set_facet_key': ->
    #     facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
    'click .recalc': ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        Meteor.call 'fum', facet._id, @key

    'click .select_value': ->
        console.log @
        filter = Template.currentData()
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        # query = facet.query
        # query["#{filter.key}"] = "$all":["#{@label}"]
        # console.log 'query',query
        arg = {
            key:filter.key
            type: 'in'
            value:@label
            }
        # query = {
        #     customer_name:$all: ["Harlem Hookah"]
        #     ticket_type: "team_member_infraction"
        # }
        Facets.update facet._id,
            $addToSet: args:arg
        Meteor.call 'fum', facet._id, filter.key

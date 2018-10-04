Template.dao.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'facet'
    @autorun => Meteor.subscribe 'results', FlowRouter.getQueryParam('doc_id')
    @autorun => Meteor.subscribe 'facet_doc', FlowRouter.getQueryParam('doc_id')
    # Session.setDefault 'view_mode', 'cards'
    # @autorun =>
    #     Meteor.subscribe('facet',
    #         selected_levels.array()
    #         selected_customers.array()
    #         selected_franchisees.array()
    #         selected_offices.array()
    #         selected_timestamp_tags.array()
    #         selected_status.array()
    #         selected_ticket_types.array()
    #         type='ticket'
    #         )
    #     Meteor.subscribe 'usernames'

Template.dao.events
    'click .create_facet': (e,t)->
        new_facet_id = Docs.insert type:'facet'
        console.log new_facet_id
        Session.set 'facet_id', new_facet_id

    'click .remove_arg': (e,t)->
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $pull:args:@

    'click .call':(e,t)->
        Meteor.call 'fo', FlowRouter.getQueryParam('doc_id')

    'click .clear_results': ->
        Meteor.call 'clear_results'

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
    facet: ->
        Docs.findOne FlowRouter.getQueryParam('doc_id')
    facets: ->
        Docs.find
            type:'facet'

    results: -> Results.find({}, limit:20)
    view_segments: -> Session.equals 'view_mode', 'segments'
    view_cards: -> Session.equals 'view_mode', 'cards'
    view_table: -> Session.equals 'view_mode', 'table'

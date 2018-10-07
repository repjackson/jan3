Template.dao.onCreated ->
    @autorun -> Meteor.subscribe 'my_facets'
    # @autorun => Meteor.subscribe 'results', FlowRouter.getQueryParam('doc_id')
    @autorun => Meteor.subscribe 'filters', FlowRouter.getQueryParam('doc_id')
    @autorun => Meteor.subscribe 'type', 'ticket_type'


Template.dao.events
    'click .create_facet': (e,t)->
        new_facet_id =
            Facets.insert
                author_id: Meteor.userId()
                timestamp: Date.now()
                args: [
                    key:'type'
                    value:'ticket'
                    ]
        FlowRouter.go("/p/dao?doc_id=#{new_facet_id}")
        Meteor.call 'fum', new_facet_id

    'click #add_filter': (e,t)->
        Docs.insert
            type:'filter'
            facet_id: FlowRouter.getQueryParam('doc_id')

    'click .remove_arg': (e,t)->
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $pull:args:@

    'click .call':(e,t)->
        Meteor.call 'fum', FlowRouter.getQueryParam('doc_id')

    'click .clear_results': ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        Facets.update facet._id,
            $set: results: []

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
    facets: ->
        Facets.find
            author_id:Meteor.userId()

    ticket_types: ->
        Docs.find
            type:'ticket_type'

    view_segments: -> Session.equals 'view_mode', 'segments'
    view_cards: -> Session.equals 'view_mode', 'cards'
    view_table: -> Session.equals 'view_mode', 'table'

    filters: ->
        Docs.find
            type:'filter'
            # facet_id: FlowRouter.getQueryParam('doc_id')



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





Template.filter.helpers
    values: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        facet["#{@key}"][..7]

    set_facet_key_class: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        if facet.query["#{@key}"] is @value then 'primary' else ''

    toggle_value_class: ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        filter = Template.parentData()
        filter_list = facet["filter_#{filter.key}"]
        if filter_list and @value in filter_list then 'primary' else ''

Template.filter.events
    # 'click .set_facet_key': ->
    #     facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
    'click .recalc': ->
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        Meteor.call 'fum', facet._id, @key

    'click .toggle_value': ->
        # console.log @
        filter = Template.currentData()
        facet = Facets.findOne FlowRouter.getQueryParam('doc_id')
        filter_list = facet["filter_#{filter.key}"]

        if filter_list and @value in filter_list
            Facets.update facet._id,
                $pull: "filter_#{filter.key}": @value
        else
            Facets.update facet._id,
                $addToSet: "filter_#{filter.key}": @value

        Meteor.call 'fum', facet._id, filter.key


Template.edit_filter_field.events
    'change .text_val': (e,t)->
        text_value = e.currentTarget.value
        # console.log @filter_id
        Docs.update @filter_id,
            { $set: "#{@key}": text_value }

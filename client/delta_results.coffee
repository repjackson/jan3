Template.delta_results.onCreated ->
    @autorun => Meteor.subscribe 'schema_actions'
    @autorun => Meteor.subscribe 'type', 'action'
    Session.setDefault 'is_calculating', false


Template.delta_results.helpers
    is_calculating: -> Session.get('is_calculating')

    grid_view_class: ->
        delta = Docs.findOne type:'delta'
        if delta.view_mode is 'grid' then 'delta_selected' else 'delta_selector'
    list_view_class: ->
        delta = Docs.findOne type:'delta'
        if delta.view_mode is 'list' then 'delta_selected' else 'delta_selector'
    table_view_class: ->
        delta = Docs.findOne type:'delta'
        if delta.view_mode is 'table' then 'delta_selected' else 'delta_selector'

    results_class: ->
        delta = Docs.findOne type:'delta'
        if delta.viewing_detail
            if delta.viewing_rightbar then 'twelve wide' else 'sixteen wide'
        else
        #     if delta.viewing_rightbar then 'nine wide' else 'twelve wide'
            'twelve wide'

    multiple_pages: ->
        delta = Docs.findOne type:'delta'
        delta.page_amount > 1

    show_page_down: ->
        delta = Docs.findOne type:'delta'
        delta.current_page > 1

    show_page_up: ->
        delta = Docs.findOne type:'delta'
        delta.current_page < delta.page_amount

    field_fields: ->
        Docs.find({
            type:'field'
            schema_slugs: $in: ['field']
        }, {sort:{rank:1}}).fetch()


    schema_fields: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        fields = Docs.find({
            type:'field'
            schema_slugs: $in: [current_type]
        }, {sort:{rank:1}}).fetch()
        fields

    schema_actions: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        actions = Docs.find({
            type:'action'
            schema_slugs: $in: [current_type]
        }, {sort:{rank:1}}).fetch()
        actions


    current_type: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        Docs.findOne
            type:'schema'
            slug:type_key



Template.delta_results.events
    'click .close_details': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: viewing_detail: false



    'click .set_grid_view': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: view_mode: 'grid'

    'click .set_list_view': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: view_mode: 'list'

    'click .set_table_view': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: view_mode: 'table'




    'click .page_up': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $inc: current_page:1
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false

    'click .page_down': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $inc: current_page:-1
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false



    'click .add_field': (e,t)->
        delta = Docs.findOne type:'delta'
        type = delta.filter_type[0]
        Docs.insert
            type:'field'
            schema_slugs:[type]
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


Template.delta_results.onCreated ->
    @autorun => Meteor.subscribe 'schema_parts'
    @autorun => Meteor.subscribe 'type', 'part'
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

    cards_class: ->
        delta = Docs.findOne type:'delta'
        switch delta.total
            when 2 then 'two'
            when 1 then 'one'
            else 'three'


    multiple_pages: ->
        delta = Docs.findOne type:'delta'
        delta.page_amount > 1

    show_page_down: ->
        delta = Docs.findOne type:'delta'
        delta.current_page > 1

    show_page_up: ->
        delta = Docs.findOne type:'delta'
        delta.current_page < delta.page_amount

    block_blocks: ->
        Docs.find({
            type:'block'
            schema_slugs: $in: ['block']
        }, {sort:{rank:1}}).fetch()


    schema_blocks: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        blocks = Docs.find({
            type:'block'
            schema_slugs: $in: [current_type]
        }, {sort:{rank:1}}).fetch()
        blocks

    schema_parts: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        parts = Docs.find({
            type:'part'
            schema_slugs: $in: [current_type]
        }, {sort:{rank:1}}).fetch()
        parts


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



    'click .add_block': (e,t)->
        delta = Docs.findOne type:'delta'
        type = delta.filter_type[0]
        Docs.insert
            type:'block'
            schema_slugs:[type]
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


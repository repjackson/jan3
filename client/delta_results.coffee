Template.delta_results.onCreated ->
    @autorun => Meteor.subscribe 'schema_blocks'
    @autorun => Meteor.subscribe 'block_blocks'
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
        if delta.doc_view
            if delta.view_rightbar then 'twelve wide' else 'sixteen wide'
        else
        #     if delta.view_rightbar then 'nine wide' else 'twelve wide'
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
        blocks_schema =
            Docs.findOne
                type:'schema'
                slug:'block'

        Docs.find({
            type:'block'
            slug: $in: blocks_schema.attached_blocks
        }, {sort:{rank:1}}).fetch()


    child_sets: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        blocks = Docs.find({
            type:'schema'
            parent_sets: $in: [current_type]
        }, {sort:{rank:1}}).fetch()
        blocks


    schema_blocks: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]

        schema_doc =
            Docs.findOne
                type:'schema'
                slug:current_type
        if schema_doc
            blocks = Docs.find({
                type:'block'
                slug: $in: schema_doc.attached_blocks
            }, {sort:{rank:1}}).fetch()
            blocks


    current_type: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        Docs.findOne
            type:'schema'
            slug:type_key



Template.delta_results.events
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



    'click .add_part': (e,t)->
        delta = Docs.findOne type:'delta'
        type = delta.filter_type[0]
        # Meteor.call 'edit_schema', type
        schema = Docs.findOne
            type:'schema'
            slug:type
        Docs.update delta._id,
            $set:
                filter_type:['schema']
                editing:true
                doc_view: true
                doc_id: schema._id
        location.reload()

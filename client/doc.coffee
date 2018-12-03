Template.doc.onCreated ->
    delta = Docs.findOne type:'delta'
    @autorun => Meteor.subscribe 'schema_blocks'
    if delta.doc_id
        @autorun => Meteor.subscribe 'doc', delta.doc_id
        @autorun => Meteor.subscribe 'children', delta.doc_id

Template.delta.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
    Meteor.setTimeout ->
        $('.ui.button').popup()
    , 1000



Template.doc.events
    'click .remove_doc': ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.doc_id
        if confirm "Delete #{target_doc.title}?"
            Docs.remove target_doc._id
            Docs.update delta._id,
                $set:
                    doc_id:null
                    editing:false
                    doc_view:false
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


    'click .add_grandchild': ->
        delta = Docs.findOne type:'delta'
        Docs.insert
            parent_id:delta.doc_id
            type:@slug

    'click .enable_editing': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing:true

    'click .disable_editing': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing:false


Template.doc.helpers
    detail_doc: ->
        delta = Docs.findOne type:'delta'
        Docs.findOne delta.doc_id

    delta_doc: -> Docs.findOne type:'delta'

    blocks: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.doc_id
        current_type = delta.filter_type[0]
        current_schema =
            Docs.findOne
                type:'schema'
                slug:current_type
        blocks_schema =
            Docs.findOne
                type:'schema'
                slug:'block'
        if current_schema
            if delta.config_mode is true
                Docs.find({
                    type:'block'
                    slug: $in: blocks_schema.attached_blocks
                }, {sort:{rank:1}}).fetch()
            else if detail_doc?.type is 'block'
                Docs.find({
                    type:'block'
                    slug: $in: blocks_schema.attached_blocks
                }, {sort:{rank:1}}).fetch()
            else
                Docs.find({
                    type:'block'
                    # view_roles: $in: Meteor.user().roles
                    slug: $in: current_schema.attached_blocks
                }, {sort:{rank:1}}).fetch()


    delta_card_class: ->
        delta = Docs.findOne type:'delta'
        if delta.doc_view then 'fluid blue raised' else ''
        # if delta.view_mode is 'grid'
        #     'six wide column'
        # else
        #     'sixteen wide column'

    local_doc: ->
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()


    value: ->
        delta = Docs.findOne type:'delta'
        schema = Docs.findOne
            type:'schema'
            slug:delta.filter_type[0]
        parent = Template.parentData()
        parent["#{@key}"]

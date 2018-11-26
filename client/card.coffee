Template.delta_card.onCreated ->
    delta = Docs.findOne type:'delta'
    @autorun => Meteor.subscribe 'schema_blocks'
    if delta.detail_id
        @autorun => Meteor.subscribe 'doc', delta.detail_id
        @autorun => Meteor.subscribe 'children', delta.detail_id

Template.delta.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
    Meteor.setTimeout ->
        $('.ui.button').popup()
    , 1000



Template.delta_card.events
    'click .remove_doc': ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        if confirm "Delete #{target_doc.title}?"
            Docs.remove target_doc._id
            Docs.update delta._id,
                $set:
                    detail_id:null
                    editing:false
                    viewing_detail:false
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


    'click .add_grandchild': ->
        delta = Docs.findOne type:'delta'
        Docs.insert
            parent_id:delta.detail_id
            type:@slug

    'click .enable_editing': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing:true

    'click .disable_editing': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing:false


Template.delta_card.helpers
    detail_doc: ->
        delta = Docs.findOne type:'delta'
        Docs.findOne delta.detail_id

    delta_doc: -> Docs.findOne type:'delta'

    current_type: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        Docs.findOne
            type:'schema'
            slug:type_key

    can_edit: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        schema = Docs.findOne
            type:'schema'
            slug:type_key
        my_role = Meteor.user()?.roles?[0]

        if my_role
            if 'dev' in Meteor.user().roles
                true
            else
                if schema.edit_roles
                    if my_role in schema.edit_roles
                        true
                    else
                        false
                else
                    false

    children_sets: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        current_type = delta.filter_type[0]
        Docs.find({
            type:'schema'
            parent_sets: $in: [current_type]
        }, {sort:{rank:1}}).fetch()

    set_children: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        current_type = delta.filter_type[0]
        Docs.find({
            type:@slug
            parent_id:detail_doc._id
        }, {sort:{rank:1}}).fetch()

    blocks: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
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

    edit_blocks: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        current_type = delta.filter_type[0]
        schema_doc =
            Docs.findOne
                type:'schema'
                slug:current_type
        blocks_schema =
            Docs.findOne
                type:'schema'
                slug:'block'

        if schema_doc
            if detail_doc?.type is 'block'
                Docs.find({
                    type:'block'
                    slug: $in: blocks_schema.attached_blocks
                }, {sort:{rank:1}}).fetch()
            else
                if 'dev' in Meteor.user().roles
                    Docs.find({
                        type:'block'
                        slug: $in: schema_doc.attached_blocks
                    }, {sort:{rank:1}}).fetch()
                else
                    Docs.find({
                        type:'block'
                        # edit_roles: $in: Meteor.user().roles
                        slug: $in: schema_doc.attached_blocks
                    }, {sort:{rank:1}}).fetch()


    child_schema_blocks: ->
        console.log @



Template.delta_card.helpers
    delta_card_class: ->
        delta = Docs.findOne type:'delta'
        if delta.viewing_detail then 'fluid blue raised' else ''
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


    doc_header_blocks: ->
        delta = Docs.findOne type:'delta'
        local_doc =
            if @data
                Docs.findOne @data.valueOf()
            else
                Docs.findOne @valueOf()
        blocks_schema =
            Docs.findOne
                type:'schema'
                slug:'block'

        if local_doc?.type is 'block'
            Docs.find({
                type:'block'
                # axon:$ne:true
                header:true
                slug: $in: blocks_schema.attached_blocks
            }, {sort:{rank:1}}).fetch()
        else if detail_doc?.type is 'block'
            Docs.find({
                type:'block'
                header:true
                slug: $in: blocks_schema.attached_blocks
            }, {sort:{rank:1}}).fetch()
        else
            schema = Docs.findOne
                type:'schema'
                slug:delta.filter_type[0]
            linked_blocks = Docs.find({
                type:'block'
                slug: $in: blocks_schema.attached_blocks
                header:true
                # axon:$ne:true
            }, {sort:{rank:1}}).fetch()


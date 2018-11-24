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
        console.log @
        Docs.find({
            type:@slug
            parent_id:detail_doc._id
        }, {sort:{rank:1}}).fetch()



    blocks: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        if delta.config_mode is true
            Docs.find({
                type:'block'
                schema_slugs: $in: ['block']
            }, {sort:{rank:1}}).fetch()
        else if detail_doc?.type is 'block'
            Docs.find({
                type:'block'
                schema_slugs: $in: ['block']
            }, {sort:{rank:1}}).fetch()
        else
            current_type = delta.filter_type[0]
            Docs.find({
                type:'block'
                view_roles: $in: Meteor.user().roles
                schema_slugs: $in: [current_type]
            }, {sort:{rank:1}}).fetch()

    edit_blocks: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        if detail_doc?.type is 'block'
            Docs.find({
                type:'block'
                schema_slugs: $in: ['block']
            }, {sort:{rank:1}}).fetch()
        else
            current_type = delta.filter_type[0]
            if 'dev' in Meteor.user().roles
                Docs.find({
                    type:'block'
                    schema_slugs: $in: [current_type]
                }, {sort:{rank:1}}).fetch()
            else
                Docs.find({
                    type:'block'
                    # edit_roles: $in: Meteor.user().roles
                    schema_slugs: $in: [current_type]
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


    # block_docs: ->
    #     delta = Docs.findOne type:'delta'
    #     local_doc =
    #         if @data
    #             Docs.findOne @data.valueOf()
    #         else
    #             Docs.findOne @valueOf()
    #     if local_doc?.type is 'block'
    #         Docs.find({
    #             type:'block'
    #             schema_slugs: $in: ['block']
    #         }, {sort:{rank:1}}).fetch()
    #     else
    #         schema = Docs.findOne
    #             type:'schema'
    #             slug:delta.filter_type[0]
    #         Docs.find({
    #             type:'block'
    #             schema_slugs: $in: [schema.slug]
    #             # view_roles: $in: Meteor.user().roles
    #         }, {sort:{rank:1}}).fetch()

    value: ->
        delta = Docs.findOne type:'delta'
        schema = Docs.findOne
            type:'schema'
            slug:delta.filter_type[0]
        parent = Template.parentData()
        block_doc = Docs.findOne
            type:'block'
            schema_slugs:$in:[schema.slug]
        parent["#{@key}"]


    doc_header_blocks: ->
        delta = Docs.findOne type:'delta'
        local_doc =
            if @data
                Docs.findOne @data.valueOf()
            else
                Docs.findOne @valueOf()
        if local_doc?.type is 'block'
            Docs.find({
                type:'block'
                # axon:$ne:true
                header:true
                schema_slugs: $in: ['block']
            }, {sort:{rank:1}}).fetch()
        else if detail_doc?.type is 'block'
            Docs.find({
                type:'block'
                header:true
                schema_slugs: $in: ['block']
            }, {sort:{rank:1}}).fetch()
        else
            schema = Docs.findOne
                type:'schema'
                slug:delta.filter_type[0]
            linked_blocks = Docs.find({
                type:'block'
                schema_slugs: $in: [schema.slug]
                header:true
                # axon:$ne:true
            }, {sort:{rank:1}}).fetch()


FlowRouter.route '/data',
    name:'data'
    action: ->
        BlazeLayout.render 'layout',
            main: 'delta'

Template.delta_results.onCreated ->
    @autorun => Meteor.subscribe 'schema_fields'
    Session.setDefault 'is_calculating', false

Template.delta.onCreated ->
    @autorun -> Meteor.subscribe 'delta'
    # @autorun => Meteor.subscribe 'delta_schema'


Template.detail_pane.onCreated ->
    delta = Docs.findOne type:'delta'
    @autorun => Meteor.subscribe 'schema_fields'
    if delta
        @autorun => Meteor.subscribe 'doc', delta.detail_id

Template.delta_card.onCreated ->
    @autorun => Meteor.subscribe 'doc', @data

Template.delta_card.events
    'click .delta_card': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_detail: true
                detail_id: @_id


Template.delta_card.helpers
    local_doc: ->
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()

    # delta_doc: -> Docs.findOne type:'delta'

    is_array: -> @primative is 'array'

    delta_card_class: ->
        delta = Docs.findOne type:'delta'
        if delta.detail_id and delta.detail_id is @_id then 'raised blue' else 'secondary'

    field_docs: ->
        delta = Docs.findOne type:'delta'
        local_doc =
            if @data
                Docs.findOne @data.valueOf()
            else
                Docs.findOne @valueOf()
        if local_doc?.type is 'field'
            Docs.find({
                type:'field'
                schema_slugs: $in: ['field']
            }, {sort:{rank:1}}).fetch()
        else
            schema = Docs.findOne
                type:'schema'
                slug:delta.filter_type[0]
            linked_fields = Docs.find({
                type:'field'
                schema_slugs: $in: [schema.slug]
                visible:true
            }, {sort:{rank:1}}).fetch()


    value: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        schema = Docs.findOne
            type:'schema'
            slug:delta.filter_type[0]
        parent = Template.parentData()
        field_doc = Docs.findOne
            type:'field'
            schema_slugs:$in:[schema.slug]
        # console.log 'field doc', field_doc
        parent["#{@key}"]

    doc_header_fields: ->
        delta = Docs.findOne type:'delta'
        local_doc =
            if @data
                Docs.findOne @data.valueOf()
            else
                Docs.findOne @valueOf()
        if local_doc?.type is 'field'
            Docs.find({
                type:'field'
                axon:$ne:true
                header:true
                schema_slugs: $in: ['field']
            }, {sort:{rank:1}}).fetch()
        else
            schema = Docs.findOne
                type:'schema'
                slug:delta.filter_type[0]
            linked_fields = Docs.find({
                type:'field'
                schema_slugs: $in: [schema.slug]
                header:true
                axon:$ne:true
            }, {sort:{rank:1}}).fetch()



Template.delta.onRendered ->
    Meteor.setTimeout ->
        $('.dropdown').dropdown()
    , 700



Template.toggle_delta_config.helpers
    boolean_true: ->
        delta = Docs.findOne type:'delta'
        if delta then delta["#{@key}"]

Template.toggle_delta_config.events
    'click .enable_key': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:"#{@key}":true

    'click .disable_key': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:"#{@key}":false


Template.delta.events
    'click .clear_current_type': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: filter_type: []

    'click .delete_delta': ->
        if confirm 'Clear Session?'
            delta = Docs.findOne type:'delta'
            Docs.remove delta._id

    'click .run_fo': ->
        delta = Docs.findOne type:'delta'
        Meteor.call 'fo', delta._id

    'click .create_delta': (e,t)->
        new_delta_id =
            Docs.insert
                type:'delta'
                result_ids:[]
                current_page:1
                page_size:10
                skip_amount:0
                view_full:true
        Meteor.call 'fo', new_delta_id


Template.delta_results.events
    'click .close_details': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: viewing_detail: false


    'click .page_up': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $inc: current_page:1
        Meteor.call 'fo'

    'click .page_down': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $inc: current_page:-1
        Meteor.call 'fo'

    'click .add_doc': (e,t)->
        delta = Docs.findOne type:'delta'
        type = delta.filter_type[0]
        user = Meteor.user()
        new_doc = {}
        if type
            new_doc['type'] = type
        new_id = Docs.insert(new_doc)

        Docs.update delta._id,
            $set:
                viewing_detail:true
                detail_id:new_id
                editing_mode:true

    'click .add_field': (e,t)->
        delta = Docs.findOne type:'delta'
        type = delta.filter_type[0]
        Docs.insert
            type:'field'
            schema_slugs:[type]
        Meteor.call 'fo'

    'click .show_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        console.log delta


Template.set_page_size.helpers
    page_size_class: ->
        delta = Docs.findOne type:'delta'
        if @value is delta.page_size then 'active' else ''


Template.set_page_size.events
    'click .set_page_size': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                current_page:0
                skip_amount:0
                page_size:@value
        Meteor.call 'fo'


Template.selector.helpers
    selector_value: ->
        switch typeof @name
            when 'string' then @name
            when 'boolean'
                # console.log @name
                if @name is true then 'True'
                else if @name is false then 'False'
            when 'number' then @name


Template.type_filter.helpers
    delta_types: ->
        if Meteor.user() and Meteor.user().roles
            if 'dev' in Meteor.user().roles
                Docs.find(
                    type:'schema'
                    # view_roles:$in:Meteor.user().roles
                ).fetch()
            else
                Docs.find(
                    type:'schema'
                    view_roles:$in:Meteor.user().roles
                ).fetch()

    set_type_class: ->
        delta = Docs.findOne type:'delta'
        # console.log @
        if delta.filter_type and @slug in delta.filter_type then 'active'

Template.type_filter.events
    'click .set_type': ->
        delta = Docs.findOne type:'delta'

        Docs.update delta._id,
            $set:
                "filter_type": [@slug]
                current_page: 0
                detail_id:null
                viewing_children:false
                viewing_detail:false
                editing_mode:false
                config_mode:false
        Session.set 'is_calculating', true
        # console.log 'hi call'
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else if res
                # console.log 'return', res
                Session.set 'is_calculating', false


# Template.detail_pane.onCreated ->
#     Meteor.setTimeout ->
#         $('.accordion').accordion();
#     , 500


Template.detail_pane.events
    'click .remove_doc': ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        if confirm "Delete #{target_doc.title}?"
            Docs.remove target_doc._id
            Docs.update delta._id,
                $set:
                    detail_id:null
                    editing_mode:false
                    viewing_detail:false

    'click .enable_editing': ->
        delta=Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing_mode:true
    'click .disable_editing': ->
        delta=Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing_mode:false


Template.detail_pane.helpers
    detail_doc: ->
        delta = Docs.findOne type:'delta'
        Docs.findOne delta.detail_id

    delta_doc: -> Docs.findOne type:'delta'


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


    fields: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        if detail_doc?.type is 'field'
            Docs.find({
                type:'field'
                schema_slugs: $in: ['field']
            }, {sort:{rank:1}}).fetch()
        else
            current_type = delta.filter_type[0]
            Docs.find({
                type:'field'
                schema_slugs: $in: [current_type]
            }, {sort:{rank:1}}).fetch()

    edit_fields: ->
        delta = Docs.findOne type:'delta'
        detail_doc = Docs.findOne delta.detail_id
        if detail_doc?.type is 'field'
            Docs.find({
                type:'field'
                schema_slugs: $in: ['field']
            }, {sort:{rank:1}}).fetch()
        else
            current_type = delta.filter_type[0]
            Docs.find({
                type:'field'
                editable:true
                schema_slugs: $in: [current_type]
            }, {sort:{rank:1}}).fetch()

    child_schema_docs: ->
        Docs.find
            type:@axon_schema

    child_schema_fields: ->
        console.log @

Template.delta_results.helpers
    is_calculating: -> Session.get('is_calculating')

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
        # console.log fields
        fields



    can_add: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        schema = Docs.findOne
            type:'schema'
            slug:type_key
        if 'dev' in Meteor.user().roles
            true
        else
            my_role = Meteor.user()?.roles?[0]
            if my_role

                if schema.add_roles
                    if my_role in schema.add_roles
                        true
                    else
                        false
                else
                    false
            else
                false


    current_type: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        Docs.findOne
            type:'schema'
            slug:type_key



Template.delta.helpers
    current_type: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        Docs.findOne
            type:'schema'
            slug:type_key

    schema_doc: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        if current_type
            schema = Docs.findOne
                type:'schema'
                slug:current_type
            # for field in schema.fields
            #     console.log 'found field', field

    delta_fields: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        delta_fields = []
        if current_type
            fields =
                Docs.find({
                    type:'field'
                    schema_slugs:$in:[current_type]
                    faceted: true
                }, {sort:{rank:1}}).fetch()


    fields: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        fields = Docs.find({
            type:'field'
            schema_slugs: $in: [current_type]
        }, {sort:{rank:1}}).fetch()
        # console.log fields
        fields



Template.set_delta_key.helpers
    set_delta_key_class: ->
        delta = Docs.findOne type:'delta'
        if delta.query["#{@key}"] is @value then 'active' else ''

Template.filter.helpers
    values: ->
        delta = Docs.findOne type:'delta'
        delta["#{@key}_return"]?[..20]

    set_delta_key_class: ->
        delta = Docs.findOne type:'delta'
        if delta.query["#{@slug}"] is @value then 'active' else ''

Template.selector.helpers
    toggle_value_class: ->
        delta = Docs.findOne type:'delta'
        filter = Template.parentData()
        filter_list = delta["filter_#{filter.key}"]
        if filter_list and @name in filter_list then 'active' else ''

Template.filter.events
    # 'click .set_delta_key': ->
    #     delta = Docs.findOne type:'delta'
    'click .recalc': ->
        delta = Docs.findOne type:'delta'
        Meteor.call 'fo'

Template.selector.events
    'click .toggle_value': ->
        # console.log @
        filter = Template.parentData()
        delta = Docs.findOne type:'delta'
        filter_list = delta["filter_#{filter.key}"]

        if filter_list and @name in filter_list
            Docs.update delta._id,
                $set:
                    current_page:1
                $pull: "filter_#{filter.key}": @name
        else
            Docs.update delta._id,
                $set:
                    current_page:1
                $addToSet:
                    "filter_#{filter.key}": @name
        Session.set 'is_calculating', true
        # console.log 'hi call'
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else if res
                # console.log 'return', res
                Session.set 'is_calculating', false

Template.edit_field_text.helpers
    field_value: ->
        field = Template.parentData()
        field["#{@key}"]


Template.edit_field_text.events
    'change .text_val': (e,t)->
        text_value = e.currentTarget.value
        # console.log @filter_id
        Docs.update @filter_id,
            { $set: "#{@key}": text_value }


Template.edit_field_number.helpers
    field_value: ->
        field = Template.parentData()
        field["#{@key}"]


Template.edit_field_number.events
    'change .number_val': (e,t)->
        number_value = parseInt e.currentTarget.value
        # console.log @filter_id
        Docs.update @filter_id,
            { $set: "#{@key}": number_value }

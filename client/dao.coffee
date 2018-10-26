Template.dao.onCreated ->
    @autorun -> Meteor.subscribe 'facet'
    # @autorun => Meteor.subscribe 'type', 'filter'
    @autorun => Meteor.subscribe 'type', 'schema'
    @autorun => Meteor.subscribe 'type', 'field', 300

    # @autorun => Meteor.subscribe 'type', 'ticket_type'
    Session.setDefault 'is_calculating', false

Template.detail_pane.onCreated ->
    facet = Docs.findOne type:'facet'
    if facet
        @autorun => Meteor.subscribe 'single_doc', facet.detail_id

Template.facet_segment.onCreated ->
    @autorun => Meteor.subscribe 'single_doc', @data

Template.facet_segment.events
    'click .facet_segment': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:
                viewing_detail: true
                detail_id: @_id


Template.facet_segment.helpers
    local_doc: ->
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()

    is_array: -> @field_type is 'array'

    facet_segment_class: ->
        facet = Docs.findOne type:'facet'
        if facet.detail_id and facet.detail_id is @_id then 'tertiary blue' else ''

    view_full: ->
        # facet = Docs.findOne type:'facet'
        # if facet.detail_id and facet.detail_id is @_id then true else false
        true

    field_docs: ->
        facet = Docs.findOne type:'facet'
        local_doc =
            if @data
                Docs.findOne @data.valueOf()
            else
                Docs.findOne @valueOf()
        if local_doc?.type is 'field'
            Docs.find({
                type:'field'
                axon:$ne:true
                schema_slugs: $in: ['field']
            }, {sort:{rank:1}}).fetch()
        else
            schema = Docs.findOne
                type:'schema'
                slug:facet.filter_type[0]
            linked_fields = Docs.find({
                type:'field'
                schema_slugs: $in: [schema.slug]
                axon:$ne:true
                visible:true
            }, {sort:{rank:1}}).fetch()


    value: ->
        # console.log @
        facet = Docs.findOne type:'facet'
        schema = Docs.findOne
            type:'schema'
            slug:facet.filter_type[0]
        parent = Template.parentData()
        field_doc = Docs.findOne
            type:'field'
            schema_slugs:$in:[schema.slug]
        # console.log 'field doc', field_doc
        parent["#{@key}"]

    doc_header_fields: ->
        facet = Docs.findOne type:'facet'
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
                slug:facet.filter_type[0]
            linked_fields = Docs.find({
                type:'field'
                schema_slugs: $in: [schema.slug]
                header:true
                axon:$ne:true
            }, {sort:{rank:1}}).fetch()



Template.dao.onRendered ->
    Meteor.setTimeout ->
        $('.dropdown').dropdown()
    , 700



Template.toggle_facet_config.helpers
    boolean_true: ->
        facet = Docs.findOne type:'facet'
        if facet then facet["#{@key}"]

Template.toggle_facet_config.events
    'click .enable_key': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:"#{@key}":true

    'click .disable_key': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:"#{@key}":false


Template.dao.events
    'click .close_details': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set: viewing_detail: false

    'click .delete_facet': ->
        if confirm 'Clear Session?'
            facet = Docs.findOne type:'facet'
            Docs.remove facet._id

    'click .create_facet': (e,t)->
        new_facet_id =
            Docs.insert
                type:'facet'
                result_ids:[]
                current_page:1
                page_size:10
                skip_amount:0
                view_full:true
        Meteor.call 'fo', new_facet_id

    'click .page_up': (e,t)->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $inc: current_page:1
        Meteor.call 'fo'

    'click .page_down': (e,t)->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $inc: current_page:-1
        Meteor.call 'fo'

    'click .add_doc': (e,t)->
        facet = Docs.findOne type:'facet'
        type = facet.filter_type[0]
        user = Meteor.user()
        new_doc = {}
        if type
            new_doc['type'] = type
        new_id = Docs.insert(new_doc)

        Docs.update facet._id,
            $set:
                viewing_detail:true
                detail_id:new_id
                editing_mode:true

    'click .add_field': (e,t)->
        facet = Docs.findOne type:'facet'
        type = facet.filter_type[0]
        Docs.insert
            type:'field'
            schema_slugs:[type]
        Meteor.call 'fo'

    'click .show_facet': (e,t)->
        facet = Docs.findOne type:'facet'
        console.log facet


Template.set_page_size.helpers
    page_size_class: ->
        facet = Docs.findOne type:'facet'
        if @value is facet.page_size then 'blue' else ''


Template.set_page_size.events
    'click .set_page_size': (e,t)->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:
                current_page:0
                skip_amount:0
                page_size:@value
        Meteor.call 'fo'


Template.selector.helpers
    selector_value: ->
        switch typeof @value
            when 'string' then @value
            when 'boolean'
                # console.log @value
                if @value is true then 'True'
                else if @value is false then 'False'
            when 'number' then @value


Template.type_filter.helpers
    faceted_types: ->
        if Meteor.user() and Meteor.user().roles
            # if 'dev' in Meteor.user().roles and Session.equals('dev_mode', true)
                Docs.find(
                    type:'schema'
                    nav_roles:$in:Meteor.user().roles
                ).fetch()

    set_type_class: ->
        facet = Docs.findOne type:'facet'
        if facet.filter_type and @slug in facet.filter_type then 'blue large' else ''


Template.type_filter.events
    'click .set_type': ->
        facet = Docs.findOne type:'facet'

        Docs.update facet._id,
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
        facet = Docs.findOne type:'facet'
        target_doc = Docs.findOne _id:facet.detail_id
        if confirm "Delete #{target_doc.title}?"
            Docs.remove target_doc._id
            Docs.update facet._id,
                $set:
                    detail_id:null
                    editing_mode:false
                    viewing_detail:false

    'click .enable_editing': ->
        facet=Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:editing_mode:true
    'click .disable_editing': ->
        facet=Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:editing_mode:false

    'click .select_axon': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:
                viewing_children:true
                children_template:@children_template
                viewing_axon:@axon_schema



Template.children_view.onCreated ->
    facet = Docs.findOne type:'facet'
    @autorun => Meteor.subscribe 'schema_doc_by_type', facet.viewing_axon
    @autorun => Meteor.subscribe 'type', 'schama'




Template.children_view.helpers
    axon_schema: ->
        facet = Docs.findOne type:'facet'
        res = Docs.findOne
            type:'schema'
            slug:facet.viewing_axon
        res



Template.detail_pane.helpers
    detail_doc: ->
        facet = Docs.findOne type:'facet'
        Docs.findOne facet.detail_id

    facet_doc: -> Docs.findOne type:'facet'


    can_edit: ->
        facet = Docs.findOne type:'facet'
        type_key = facet.filter_type[0]
        schema = Docs.findOne
            type:'schema'
            slug:type_key
        if 'dev' in Meteor.user().roles
            true
        else
            my_role = Meteor.user()?.roles?[0]
            if my_role

                if schema.editable_roles
                    if my_role in schema.editable_roles
                        true
                    else
                        false
                else
                    false
            else
                false

    axon_selector_class: ->
        facet = Docs.findOne type:'facet'
        if @axon_schema is facet.viewing_axon then 'blue' else ''

    fields: ->
        facet = Docs.findOne type:'facet'
        detail_doc = Docs.findOne facet.detail_id
        if detail_doc?.type is 'field'
            Docs.find({
                type:'field'
                axon:$ne:true
                schema_slugs: $in: ['field']
            }, {sort:{rank:1}}).fetch()
        else
            current_type = facet.filter_type[0]
            Docs.find({
                type:'field'
                axon:$ne:true
                schema_slugs: $in: [current_type]
            }, {sort:{rank:1}}).fetch()

    axons: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        Docs.find({
            type:'field'
            axon:true
            schema_slugs: $in: [current_type]
        }, {sort:{rank:1}}).fetch()


    child_schema_docs: ->
        Docs.find
            type:@axon_schema

    child_schema_fields: ->
        console.log @

Template.draft.events
    'click .submit_draft': ->
        facet = Docs.findOne type:'facet'
        draft_doc = Docs.findOne facet.adding_id
        Docs.update draft_doc._id,
            $set:
                submitted:true
                submitted_timestamp:Date.now()
        Docs.update facet._id,
            $set:
                adding_id:null
                is_adding:false


    'click .cancel_draft': ->
        facet = Docs.findOne type:'facet'
        draft_doc = Docs.findOne facet.adding_id
        if confirm "Cancel draft?"
            if draft_doc
                Docs.remove draft_doc._id
            Docs.update facet._id,
                $set:
                    adding_id:null
                    is_adding:false


Template.draft.helpers
    draft_doc: ->
        facet = Docs.findOne type:'facet'
        Docs.findOne facet.adding_id
    draft_fields: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        Docs.find(
            type:'field'
            schema_slugs: $in: [current_type]
            # draft:true
        ).fetch()


Template.dao.helpers
    is_calculating: -> Session.get('is_calculating')
    facet_doc: -> Docs.findOne type:'facet'

    visible_result_ids: ->
        facet = Docs.findOne type:'facet'
        if facet.result_ids then facet.result_ids[..10]

    current_type: ->
        facet = Docs.findOne type:'facet'
        type_key = facet.filter_type[0]
        Docs.findOne
            type:'schema'
            slug:type_key

    can_add: ->
        facet = Docs.findOne type:'facet'
        type_key = facet.filter_type[0]
        schema = Docs.findOne
            type:'schema'
            slug:type_key

        my_role = Meteor.user()?.roles?[0]
        if my_role
            if schema.addable_roles
                if my_role in schema.addable_roles
                    true
                else
                    false
            else
                false
        else
            false


    ticket_types: -> Docs.find type:'ticket_type'

    schema_doc: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        if current_type
            schema = Docs.findOne
                type:'schema'
                slug:current_type
            # for field in schema.fields
            #     console.log 'found field', field

    field_fields: ->
        Docs.find({
            type:'field'
            schema_slugs: $in: ['field']
            axon:$ne:true
        }, {sort:{rank:1}}).fetch()


    faceted_fields: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        faceted_fields = []
        if current_type
            fields =
                Docs.find({
                    type:'field'
                    schema_slugs:$in:[current_type]
                    faceted: true
                }, {sort:{rank:1}}).fetch()


    fields: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        fields = Docs.find({
            type:'field'
            schema_slugs: $in: [current_type]
        # }, {sort:{rank:1}}).fetch()
        }).fetch()
        # console.log fields
        fields



Template.set_facet_key.helpers
    set_facet_key_class: ->
        facet = Docs.findOne type:'facet'
        if facet.query["#{@key}"] is @value then 'blue' else ''

Template.filter.helpers
    values: ->
        facet = Docs.findOne type:'facet'
        facet["#{@key}_return"]?[..10]

    set_facet_key_class: ->
        facet = Docs.findOne type:'facet'
        if facet.query["#{@slug}"] is @value then 'blue' else ''

Template.selector.helpers
    toggle_value_class: ->
        facet = Docs.findOne type:'facet'
        filter = Template.parentData()
        filter_list = facet["filter_#{filter.key}"]
        if filter_list and @value in filter_list then 'blue' else ''

Template.filter.events
    # 'click .set_facet_key': ->
    #     facet = Docs.findOne type:'facet'
    'click .recalc': ->
        facet = Docs.findOne type:'facet'
        Meteor.call 'fo'

Template.selector.events
    'click .toggle_value': ->
        # console.log @
        filter = Template.parentData()
        facet = Docs.findOne type:'facet'
        filter_list = facet["filter_#{filter.key}"]

        if filter_list and @value in filter_list
            Docs.update facet._id,
                $set:
                    current_page:1
                $pull: "filter_#{filter.key}": @value
        else
            Docs.update facet._id,
                $set:
                    current_page:1
                $addToSet:
                    "filter_#{filter.key}": @value
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





Template.ticket_assignment_cell.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id

Template.ticket_assignment_cell.helpers
    # ticket_assignment_cell_class: ->
    #     if @assignment_timestamp
    #         now = Date.now()
    #         response = @assignment_timestamp - now
    #         calc = moment.duration(response).humanize()
    #         hour_amount = moment.duration(response).asHours()
    #         if hour_amount<-5 then 'negative' else 'positive'

    assigned_users: ->
        if @assigned_to
            Meteor.users.find
                _id: $in: @assigned_to

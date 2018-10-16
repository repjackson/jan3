Template.dao.onCreated ->
    @autorun -> Meteor.subscribe 'facet'
    @autorun => Meteor.subscribe 'type', 'filter'
    @autorun => Meteor.subscribe 'type', 'schema'
    @autorun => Meteor.subscribe 'type', 'field'

    # @autorun => Meteor.subscribe 'type', 'ticket_type'
    @is_editing = new ReactiveVar false
    Session.setDefault 'is_calculating', false

Template.detail_pane.onCreated ->
    facet = Docs.findOne type:'facet'
    if facet
        @autorun => Meteor.subscribe 'single_doc', facet.detail_id

Template.facet_segment.onCreated ->
    @autorun => Meteor.subscribe 'single_doc', @data

Template.field_edit.events
    'blur .text_field_val': (e,t)->
        # console.log Template.parentData()
        parent = Template.parentData()

        val = e.currentTarget.value
        Docs.update parent._id,
            $set:
                "#{@key}": val

    'keyup .add_array_element': (e,t)->
        if e.which is 13
            parent = Template.parentData()

            val = e.currentTarget.value
            Docs.update parent._id,
                $addToSet:
                    "#{@key}": val


    'click .pull_element': (e,t)->
        local_id = Template.currentData()
        local_doc = Docs.findOne local_id
        target_doc = Template.parentData()

        Docs.update target_doc._id,
            $pull:
                "#{local_doc.key}": @valueOf()


Template.facet_segment.events
    'click .facet_segment': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:
                viewing_detail: true
                detail_id: @_id

    'click .remove_doc': ->
        if confirm "Delete #{@title}?"
            Docs.remove @_id

Template.facet_segment.helpers
    local_doc: -> Docs.findOne @valueOf()

    facet_segment_class: ->
        facet = Docs.findOne type:'facet'
        if facet.detail_id and facet.detail_id is @_id then 'secondary' else ''

    field_docs: ->
        facet = Docs.findOne type:'facet'
        schema = Docs.findOne
            type:'schema'
            slug:facet.filter_type[0]
        linked_fields = Docs.find(
            type:'field'
            schema_slugs: $in: [schema.slug]
            ).fetch()

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
        header = []
        Docs.find(
            type:'field'
            schema_slugs:$in:[facet.filter_type[0]]
            card_header:true
        ).fetch()

Template.field_edit.helpers
    is_array:-> @field_type is 'schemas'
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
Template.field_view.helpers
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




Template.dao.onRendered ->
    # Meteor.setTimeout ->
    #     $('.accordion').accordion();
    # , 500
    Meteor.setTimeout ->
        $('.dropdown').dropdown()
    , 700


Template.edit_field.events
    'click .remove_field':->
        if confirm "Delete #{@title} field?"
            Docs.remove @_id

Template.edit_field_boolean.helpers
    is_true: ->
        field = Template.parentData()
        field["#{@key}"]


Template.edit_field_array.helpers
    values: ->
        field = Template.parentData()
        if field["#{@key}"] then field["#{@key}"]


Template.edit_field_array.events
    'keyup .add_value': (e,t)->
        if e.which is 13
            new_val = e.currentTarget.value
            field = Template.parentData()
            Docs.update field._id,
                $addToSet:
                    "#{@key}": new_val



Template.edit_field_boolean.events
    'click .set_true': ->
        field = Template.parentData()
        Docs.update field._id,
            $set:
                "#{@key}": true
    'click .set_false': ->
        field = Template.parentData()
        Docs.update field._id,
            $set:
                "#{@key}": false



Template.dao.events
    'click .close_details': ->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set: viewing_detail: false

    'click .delete_facet': ->
        if confirm 'Delete facet?'
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
        new_id = Docs.insert
            type:type
        # Meteor.call 'fo'
        Docs.update facet._id,
            $set:
                viewing_detail:true
                adding_id:new_id
                is_adding:true

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


Template.set_page_size.events
    'click .set_page_size': (e,t)->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:page_size:@value
        Meteor.call 'fo'

Template.selector.helpers
    selector_value: ->
        switch typeof @value
            when 'string' then @value
            when 'boolean'
                if @value is true then 'Open'
                else if @value is false then 'Closed'
            when 'number' then @value


Template.type_filter.helpers
    faceted_types: ->
        if Meteor.user() and Meteor.user().roles and 'dev' in Meteor.user().roles
            Docs.find(
                type:'schema'
                # faceted:true
            ).fetch()
        else
            Docs.find(
                type:'schema'
                faceted:true
                dev:$ne:true
            ).fetch()

    set_type_class: ->
        facet = Docs.findOne type:'facet'
        if facet.filter_type and @slug in facet.filter_type then 'primary' else ''


Template.type_filter.events
    'click .set_type': ->
        facet = Docs.findOne type:'facet'

        Docs.update facet._id,
            $set:
                "filter_type": [@slug]
                current_page: 0
        Session.set 'is_calculating', true
        # console.log 'hi call'
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else if res
                # console.log 'return', res
                Session.set 'is_calculating', false



Template.detail_pane.helpers
    detail_doc: ->
        facet = Docs.findOne type:'facet'
        Docs.findOne facet.detail_id
    fields: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        Docs.find(
            type:'field'
            schema_slugs: $in: [current_type]
        ).fetch()

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

    # detail_view: ->

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

    faceted_fields: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        faceted_fields = []
        if current_type
            fields =
                Docs.find(
                    type:'field'
                    schema_slugs:$in:[current_type]
                    faceted: true
                ).fetch()


    fields: ->
        facet = Docs.findOne type:'facet'
        current_type = facet.filter_type[0]
        Docs.find(
            type:'field'
            schema_slugs: $in: [current_type]
        ).fetch()
    is_editing: -> Template.instance().is_editing.get()



Template.set_facet_key.helpers
    set_facet_key_class: ->
        facet = Docs.findOne type:'facet'
        if facet.query["#{@key}"] is @value then 'primary' else ''

Template.filter.helpers
    values: ->
        facet = Docs.findOne type:'facet'
        facet["#{@key}_return"][..10]

    set_facet_key_class: ->
        facet = Docs.findOne type:'facet'
        if facet.query["#{@slug}"] is @value then 'primary' else ''

Template.selector.helpers
    toggle_value_class: ->
        facet = Docs.findOne type:'facet'
        filter = Template.parentData()
        filter_list = facet["filter_#{filter.key}"]
        if filter_list and @value in filter_list then 'primary' else ''

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


Template.bool_switch.helpers
    'bool_switch_class': ->
        target_doc = Template.parentData(5)
        bool_value = target_doc["#{@key}"]
        if bool_value and bool_value is true
            'primary'
        else
            ''
Template.bool_switch.events
    'click .toggle_field': ->
        # console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)
        target_doc = Template.parentData(5)
        bool_value = target_doc["#{@key}"]

        if bool_value and bool_value is true
            Docs.update target_doc._id,
                $set: "#{@key}": false
        else
            Docs.update target_doc._id,
                $set: "#{@key}": true



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

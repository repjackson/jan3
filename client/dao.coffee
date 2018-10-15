Template.dao.onCreated ->
    @autorun -> Meteor.subscribe 'facet'
    @autorun => Meteor.subscribe 'type', 'filter'
    @autorun => Meteor.subscribe 'type', 'schema'
    @autorun => Meteor.subscribe 'type', 'field'
    # @autorun => Meteor.subscribe 'type', 'ticket_type'
    @is_editing = new ReactiveVar false
    Session.setDefault 'is_calculating', false
    Session.setDefault 'view_mode', 'cards'


Template.facet_card.onCreated ->
    @autorun => Meteor.subscribe 'single_doc', @data
Template.dao_table_row.onCreated ->
    @autorun => Meteor.subscribe 'single_doc', @data

Template.dao_table_row.helpers
    local_doc: -> Docs.findOne @valueOf()

    visible_fields: ->
        facet = Docs.findOne type:'facet'
        schema = Docs.findOne
            type:'schema'
            slug:facet.filter_type[0]
        visible = []
        for field in schema.fields
            if field.table_column
                visible.push field
        visible


    value: ->
        doc = Template.parentData()
        doc["#{@slug}"]

Template.field_doc.events
    'blur .text_field_val': (e,t)->
        console.log Template.parentData()
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


Template.facet_card.events
    'click .remove_doc': ->
        if confirm "Delete #{@title}?"
            Docs.remove @_id

Template.facet_card.helpers
    local_doc: -> Docs.findOne @valueOf()

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

Template.field_doc.helpers
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




Template.dao.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
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
        Docs.insert
            type:type
        Meteor.call 'fo'

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

    'click .set_view_cards': -> Session.set 'view_mode', 'cards'
    'click .set_view_segments': -> Session.set 'view_mode', 'segments'
    'click .set_view_table': -> Session.set 'view_mode', 'table'


Template.set_page_size.events
    'click .set_page_size': (e,t)->
        facet = Docs.findOne type:'facet'
        Docs.update facet._id,
            $set:page_size:@value
        Meteor.call 'fo'



Template.table_column_header.onCreated ->
    @is_sorting = new ReactiveVar false

Template.table_column_header.events
    'click .sort_key': (e,t)->
        t.is_sorting.set true
        key = if @ev_subset then "ev.#{@slug}" else @slug
        facet_doc = Docs.findOne type:'facet'
        if facet_doc.sort_direction is -1
            Docs.update facet_doc._id,
                $set:
                    sort_key: key
                    sort_direction: 1
        else
            Docs.update facet_doc._id,
                $set:
                    sort_key: key
                    sort_direction: -1
        Meteor.call 'fo',(err,res) =>
            if res
                t.is_sorting.set false

    # 'click .raise_filter':->
    #     Docs.update @_id,
    #         $inc:rank:1

    # 'click .lower_filter':->
    #     Docs.update @_id,
    #         $inc:rank:-1


Template.table_column_header.helpers
    sort_descending: ->
        key = if @ev_subset then "ev.#{@key}" else @key
        facet = Docs.findOne type:'facet'
        if facet.sort_direction is 1 and facet.sort_key is key
            return true
    sort_ascending: ->
        key = if @ev_subset then "ev.#{@key}" else @key
        facet = Docs.findOne type:'facet'
        if facet.sort_direction is -1 and facet.sort_key is key
            return true

    is_sorting: -> Template.instance().is_sorting.get() is true

Template.facet_table.helpers
    facet_doc: -> Docs.findOne type:'facet'

    visible_fields: ->
        facet = Docs.findOne type:'facet'
        schema = Docs.findOne
            type:'schema'
            slug:facet.filter_type[0]
        visible = []
        for field in schema.fields
            if field.table_column
                visible.push field
        visible


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





Template.dao.helpers
    is_calculating: -> Session.get('is_calculating')
    facet_doc: -> Docs.findOne type:'facet'

    visible_result_ids: ->
        facet = Docs.findOne type:'facet'
        if facet.result_ids then facet.result_ids[..10]

    ticket_types: -> Docs.find type:'ticket_type'

    view_segments: -> Session.equals 'view_mode', 'segments'
    view_cards: -> Session.equals 'view_mode', 'cards'
    view_table: -> Session.equals 'view_mode', 'table'

    view_cards_class: -> if Session.equals 'view_mode', 'cards' then 'primary' else ''
    view_segments_class: -> if Session.equals 'view_mode', 'segments' then 'primary' else ''
    view_table_class: -> if Session.equals 'view_mode', 'table' then 'primary' else ''

    # other_filters: ->
    #     facet = Docs.findOne type:'facet'
    #     current_type = facet.filter_type[0]
    #     switch current_type
    #         when 'ticket'
    #             Docs.find
    #                 type:'filter'
    #                 key:$ne:'type'
    #                 doc_type: 'ticket'

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

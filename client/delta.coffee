
Template.delta.onCreated ->
    @autorun => Meteor.subscribe 'type', 'field', 200
    @autorun => Meteor.subscribe 'type', 'schema', 200
    @autorun -> Meteor.subscribe 'delta'
    @autorun => Meteor.subscribe 'schema_fields'
    @autorun -> Meteor.subscribe 'me'



# Template.delta.onCreated ->
#     @autorun -> Meteor.subscribe 'nav_items'
#     @autorun -> Meteor.subscribe 'my_customer_account'
#     @autorun -> Meteor.subscribe 'my_franchisee'
#     @autorun -> Meteor.subscribe 'my_office'
#     @autorun -> Meteor.subscribe 'my_schemas'
#     @autorun -> Meteor.subscribe 'my_bookmarks'


Template.delta.helpers
    center_column_class: ->
        delta = Docs.findOne type:'delta'
        if delta.viewing_detail
            return 'sixteen wide column'
        else
            size = 16
            if delta.viewing_delta then size -= 4
            # console.log size
            switch size
                when 16 then 'sixteen wide column'
                when 13 then 'thirteen wide column'
                when 10 then 'ten wide column'
                when 12 then 'twelve wide column'
                when 9 then 'nine wide column'
                when 8 then 'eight wide column'
                when 6 then 'six wide column'

    current_type: ->
        delta = Docs.findOne type:'delta'
        if delta and delta.filter_type
            type_key = delta.filter_type[0]
            Docs.findOne
                type:'schema'
                slug:type_key

    viewing_schemas: ->
        delta = Docs.findOne type:'delta'
        type_key = delta.filter_type[0]
        if type_key is 'schema' then true else false

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
        if Meteor.user() and Meteor.user().roles and current_type
            if 'dev' in Meteor.user().roles
                Docs.find({
                    type:'field'
                    schema_slugs:$in:[current_type]
                    faceted: true
                }, {sort:{rank:1}}).fetch()
            else
                Docs.find({
                    type:'field'
                    # view_roles: $in: Meteor.user().roles
                    schema_slugs:$in:[current_type]
                    faceted: true
                }, {sort:{rank:1}}).fetch()


    fields: ->
        delta = Docs.findOne type:'delta'
        current_type = delta.filter_type[0]
        if current_type
            fields = Docs.find({
                type:'field'
                schema_slugs: $in: [current_type]
            }, {sort:{rank:1}}).fetch()
            fields


Template.delta.events
    'click .toggle_topbar': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: viewing_topbar: !delta.viewing_topbar

    'click .toggle_rightbar': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_rightbar: !delta.viewing_rightbar
                # viewing_leftbar:false

    'click .toggle_leftbar': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set: viewing_leftbar: !delta.viewing_leftbar



    'click .view_schamas': ->
        delta = Docs.findOne type:'delta'

        Docs.update delta._id,
            $set:
                filter_type: ['schema']
                current_page: 0
                detail_id:null
                viewing_children:false
                viewing_detail:false
                editing:false
                config_mode:false
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


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
                editing:true
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


    'click .create_delta': (e,t)->
        new_delta_id =
            Docs.insert
                type:'delta'
                filter_type: ['schema']
                result_ids:[]
                current_page:1
                page_size:10
                skip_amount:0
                view_full:true
        Meteor.call 'fo', new_delta_id


Template.delta_card.onCreated ->
    @autorun => Meteor.subscribe 'doc', @data


Template.delta_card.events
    'click .mark_complete': ->
        Docs.update @_id,
            $set: complete:true

    'click .mark_incomplete': ->
        Docs.update @_id,
            $set: complete:false


    'click .expand': ->
        delta = Docs.findOne type:'delta'
        if delta.expand_id is @_id
            Docs.update delta._id,
                $set: expand_id: null
        else
            Docs.update delta._id,
                $set: expand_id: @_id

    'click .toggle_full': ->
        delta = Docs.findOne type:'delta'
        if delta.viewing_detail
            Docs.update delta._id,
                $set:
                    viewing_detail: false
                    detail_id: null
        else
            Docs.update delta._id,
                $set:
                    viewing_detail: true
                    detail_id: @_id
                    expand_id: @_id

    'click .maximize': ->
        delta = Docs.findOne type:'delta'
        unless delta.viewing_detail
            Docs.update delta._id,
                $set:
                    viewing_detail: true
                    detail_id: @_id




Template.task_card.helpers
    # expand_class: ->
    #     delta = Docs.findOne type:'delta'
    #     if delta.expand_id is @_id then 'blue'


    # maximize_class: ->
    #     delta = Docs.findOne type:'delta'
    #     if delta.detail_id is @_id then 'blue'


Template.delta_card.helpers
    card_template: ->
        doc = Docs.findOne @valueOf()
        if doc and doc.type
            if doc.type is 'task' then 'task_card' else 'delta_card'

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
            Docs.find({
                type:'field'
                schema_slugs: $in: [schema.slug]
                # view_roles: $in: Meteor.user().roles
            }, {sort:{rank:1}}).fetch()

    # actions: ->
    #     delta = Docs.findOne type:'delta'
    #     local_doc =
    #         if @data
    #             Docs.findOne @data.valueOf()
    #         else
    #             Docs.findOne @valueOf()
    #     if local_doc?.type is 'field'
    #         Docs.find({
    #             type:'action'
    #             schema_slugs: $in: ['field']
    #         }, {sort:{rank:1}}).fetch()
    #     else
    #         schema = Docs.findOne
    #             type:'schema'
    #             slug:delta.filter_type[0]
    #         Docs.find({
    #             type:'action'
    #             visible:true
    #             schema_slugs: $in: [schema.slug]
    #         }, {sort:{rank:1}}).fetch()


    value: ->
        delta = Docs.findOne type:'delta'
        schema = Docs.findOne
            type:'schema'
            slug:delta.filter_type[0]
        parent = Template.parentData()
        field_doc = Docs.findOne
            type:'field'
            schema_slugs:$in:[schema.slug]
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
                # axon:$ne:true
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
                # axon:$ne:true
            }, {sort:{rank:1}}).fetch()






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
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


Template.selector.helpers
    selector_value: ->
        switch typeof @name
            when 'string' then @name
            when 'boolean'
                if @name is true then 'True'
                else if @name is false then 'False'
            when 'number' then @name

    toggle_value_class: ->
        delta = Docs.findOne type:'delta'
        filter = Template.parentData()
        filter_list = delta["filter_#{filter.key}"]
        if filter_list and @name in filter_list then 'active' else ''


Template.delta_card.events
    'click .save': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing:false

    'click .edit': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                editing:true
                viewing_detail: true
                detail_id: @_id


Template.facet.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
# Template.delta_card.onRendered ->
#     Meteor.setTimeout ->
#         # $('.accordion').accordion();
#         # $('.shape').shape()
#     , 500




Template.set_delta_key.helpers
    set_delta_key_class: ->
        delta = Docs.findOne type:'delta'
        if delta.query["#{@key}"] is @value then 'blue' else 'basic'

Template.facet.helpers
    values: ->
        delta = Docs.findOne type:'delta'
        # delta["#{@key}_return"]?[..20]
        filtered_values = []
        fo_values = delta["#{@key}_return"]
        filters = delta["filter_#{@key}"]
        for value in fo_values
            if value.name in filters
                filtered_values.push value
            else if value.count < delta.total
                filtered_values.push value
        filtered_values

    # set_delta_key_class: ->
    #     delta = Docs.findOne type:'delta'
    #     if delta.query["#{@slug}"] is @value then 'blue' else 'basic'


Template.facet.events
    # 'click .set_delta_key': ->
    #     delta = Docs.findOne type:'delta'
    'click .recalc': ->
        delta = Docs.findOne type:'delta'
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false

Template.selector.events
    'click .toggle_value': ->
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
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


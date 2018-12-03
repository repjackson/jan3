
Template.doc.onCreated ->
    @autorun => Meteor.subscribe 'delta'

Template.home.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'block', 200
    @autorun => Meteor.subscribe 'type', 'schema', 200
    @autorun -> Meteor.subscribe 'delta'
    @autorun => Meteor.subscribe 'schema_blocks'
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'my_alerts'




# Template.delta.onCreated ->
#     @autorun -> Meteor.subscribe 'nav_items'
#     @autorun -> Meteor.subscribe 'my_customer_account'
#     @autorun -> Meteor.subscribe 'my_franchisee'
#     @autorun -> Meteor.subscribe 'my_office'
#     @autorun -> Meteor.subscribe 'my_schemas'
#     @autorun -> Meteor.subscribe 'my_bookmarks'


Template.delta.helpers
    unread_alerts: ->
        Docs.find
            type:'alert'

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
            # for block in schema.blocks
            #     console.log 'found block', block

    facets: ->
        # delta = Docs.findOne type:'delta'
        # current_type = delta.filter_type[0]

        # schema_doc =
        #     Docs.findOne
        #         type:'schema'
        #         slug:current_type
        # if schema_doc
        #     blocks = Docs.find({
        #         type:'block'
        #         slug: $in: schema_doc.attached_blocks
        #         # faceted:true
        #     }, {sort:{rank:1}}).fetch()
        facets = [
            {
                key:'type'
                primitive:'string'
            }
            {
                key:'tags'
                type:'array'
            }
            {
                key:'keys'
                type:'array'
            }
        ]

            


    blocks: ->
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


Template.nav.events
    # 'click .toggle_topbar': ->
    #     delta = Docs.findOne type:'delta'
    #     Docs.update delta._id,
    #         $set:
    #             view_topbar: !delta.view_topbar
    #             view_leftbar: false
    #             view_rightbar: false
    #             expand_footer: false

    # 'click .toggle_rightbar': ->
    #     delta = Docs.findOne type:'delta'
    #     Docs.update delta._id,
    #         $set:
    #             view_rightbar: !delta.view_rightbar
    #             view_leftbar:false
    #             view_topbar:false
    #             expand_footer: false

    # 'click .toggle_leftbar': ->
    #     delta = Docs.findOne type:'delta'
    #     Docs.update delta._id,
    #         $set:
    #             view_leftbar: !delta.view_leftbar
    #             view_rightbar:false
    #             view_topbar:false
    #             expand_footer: false


Template.delta.events
    'click .view_schamas': ->
        delta = Docs.findOne type:'delta'

        Docs.update delta._id,
            $set:
                filter_type: ['schema']
                current_page: 0
                doc_id:null
                viewing_children:false
                doc_view:false
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
                doc_view:true
                doc_id:new_id
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
                # filter_type: ['schema']
                result_ids:[]
                # current_page:1
                # page_size:10
                # skip_amount:0
                # view_full:true
        Meteor.call 'fo', new_delta_id


Template.doc.onCreated ->
    @autorun => Meteor.subscribe 'doc', @data




Template.doc.events
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
        if delta.doc_view
            Docs.update delta._id,
                $set:
                    doc_view: false
                    doc_id: null
        else
            Docs.update delta._id,
                $set:
                    doc_view: true
                    doc_id: @_id
                    expand_id: @_id

    'click .maximize': ->
        delta = Docs.findOne type:'delta'
        unless delta.doc_view
            Docs.update delta._id,
                $set:
                    doc_view: true
                    doc_id: @_id





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
        if @value is delta.page_size then 'active blue' else ''


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
        if filter_list and @name in filter_list then 'blue active' else ''


Template.doc.events
    'click .save': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:editing:false

    'click .edit': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                editing:true
                doc_view: true
                doc_id: @_id


Template.facet.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
# Template.doc.onRendered ->
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
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@key}_return"]?[..20]
        filtered_values = []
        fo_values = delta["#{@key}_return"]
        filters = delta["filter_#{@key}"]
        if fo_values
            for value in fo_values
                if value.name in filters
                    filtered_values.push value
                else if value.count < delta.total
                    filtered_values.push value
        filtered_values
    
    
    selected_values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@key}_return"]?[..20]
        filtered_values = []
        fo_values = delta["#filter_{@key}"]
        filters = delta["filter_#{@key}"]


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

    'click .unselect': ->
        facet = Template.currentData()
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $pull: 
                "filter_#{facet.key}": @valueOf()
                active_facets: facet.key
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false



Template.selector.events
    'click .select': ->
        filter = Template.parentData()
        delta = Docs.findOne type:'delta'
        filter_list = delta["filter_#{filter.key}"]
        
        # console.log filter
        
        Docs.update delta._id,
            $addToSet:
                "filter_#{filter.key}": @name
                active_facets: filter.key
                
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


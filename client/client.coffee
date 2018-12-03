Template.registerHelper 'delta', () -> Docs.findOne type:'delta'


Template.registerHelper 'is_eric', ()->
    if Meteor.user()
        'Bda8mRG925DnxTjQC' is Meteor.userId()


Template.registerHelper 'is_array', ()->
    if @primitive
        @primitive in ['array','multiref']
    # else
    #     console.log 'no primitive', @

Template.registerHelper 'is_dev_env', () -> Meteor.isDevelopment

Template.nav.events
    'click .delta': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'delta'
                viewing_delta: false
   
    'click .add': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'add'
                viewing_delta: false

    'click .delete_delta': ->
        if confirm 'Clear Session?'
            delta = Docs.findOne type:'delta'
            Docs.remove delta._id

    'click .run_fo': ->
        delta = Docs.findOne type:'delta'
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false

    'click .show_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        console.log delta

    'click #logout': (e,t)->
        # e.preventDefault()
        Meteor.logout ->
            t.signing_out.set false
            
            
            
Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'delta'
    @autorun -> Meteor.subscribe 'me'


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
        delta = Docs.findOne type:'delta'
        if delta and delta.keys_return then delta.keys_return
            

Template.delta.events
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
                result_ids:[]
        Meteor.call 'fo', new_delta_id


Template.doc.onCreated ->
    @autorun => Meteor.subscribe 'doc', @data







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
        fo_values = delta["#{@valueOf()}_return"]
        filters = delta["filter_#{@valueOf()}"]
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



Template.doc.onCreated ->
    if delta.doc_id
        @autorun => Meteor.subscribe 'doc', delta.doc_id
        # @autorun => Meteor.subscribe 'children', delta.doc_id

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


Template.doc.helpers
    detail_doc: ->
        delta = Docs.findOne type:'delta'
        Docs.findOne delta.doc_id

    delta_doc: -> Docs.findOne type:'delta'

    fields: ->
        console.log @

    local_doc: ->
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()


    value: ->
        parent = Template.parentData()
        parent["#{@valueOf()}"]
        
        # delta = Docs.findOne type:'delta'
        # values = []
        # if @keys
        #     for key in @keys
        #         values.push parent["#{@key}"]
        # values
        
        
Template.login.events
    'click .login': (e,t)->
        # e.preventDefault()
        username = $('.username').val()
        password = $('.password').val()
        Meteor.loginWithPassword username, password, (err,res)->
            if err
                alert err
            # else
            #     console.log 'yea'

    'keyup .username, keyup .password': (e,t)->
        if e.which is 13 #enter
            e.preventDefault()
            username = $('.username').val()
            password = $('.password').val()
            Meteor.loginWithPassword username, password, (err,res)->
                if err
                    alert err


    'click #login_demo_admin': ->
        Meteor.loginWithPassword 'demo_admin', 'demoadminpassword', (err,res)->

    'click #login_demo_office': ->
        Meteor.loginWithPassword 'demo_office', 'demoofficepassword', (err,res)->

    'click #login_demo_customer': ->
        Meteor.loginWithPassword 'demo_customer', 'democustomerpassword', (err,res)->


Template.login.helpers
    login_button_class: ->
        if Meteor.loggingIn()
            'loading disabled'
        else if Meteor.user()
            ''

    demo_class: ->
        if Meteor.loggingIn()
            'disabled'
        # else if Meteor.user()
        #     'disabled'
        
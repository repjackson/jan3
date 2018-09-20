Template.toggle_boolean.events
    'click #turn_on': ->
        data_doc = Template.parentData()
        Docs.update data_doc._id, $set: "#{@key}": true

    'click #turn_off': ->
        data_doc = Template.parentData()
        Docs.update data_doc._id, $set: "#{@key}": false

Template.toggle_boolean.helpers
    is_on: -> 
        # page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        data_doc = Template.parentData()
        data_doc["#{@key}"]


Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"


# Template.reference_type_single.onCreated ->
#     @autorun =>  Meteor.subscribe 'type', @data.type
# Template.reference_type_multiple.onCreated ->
#     @autorun =>  Meteor.subscribe 'type', @data.type

Template.associated_users.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id
    
Template.associated_users.helpers
    associated_users: -> 
        if @assigned_to
            Meteor.users.find 
                _id: $in: @assigned_to


Template.incident_assignment_cell.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id
    
Template.incident_assignment_cell.helpers
    # incident_assignment_cell_class: ->
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



# Template.reference_type_single.helpers
    # settings: -> 
    #     {
    #         position: 'bottom'
    #         limit: 10
    #         rules: [
    #             {
    #                 collection: Docs
    #                 field: "#{@search_field}"
    #                 matchAll: true
    #                 filter: { type: "#{@type}" }
    #                 template: Template.office_result
    #             }
    #         ]
    #     }

# Template.reference_type_multiple.helpers
    # settings: -> 
    #     {
    #         position: 'bottom'
    #         limit: 10
    #         rules: [
    #             {
    #                 collection: Docs
    #                 field: "#{@search_field}"
    #                 matchAll: true
    #                 filter: { type: "#{@type}" }
    #                 template: Template.customer_result
    #             }
    #         ]
    #     }


# Template.reference_type_single.events
    # 'autocompleteselect #search': (event, template, doc) ->
    #     searched_value = doc["#{template.data.key}"]
    #     Docs.update FlowRouter.getQueryParam('doc_id'),
    #         $set: "#{template.data.key}": "#{doc._id}"
    #     $('#search').val ''



# Template.reference_type_multiple.events
    # 'autocompleteselect #search': (event, template, doc) ->
    #     searched_value = doc["#{template.data.key}"]
    #     Docs.update FlowRouter.getQueryParam('doc_id'),
    #         $addToSet: "#{template.data.key}": "#{doc._id}"
    #     $('#search').val ''




# Template.set_view_mode.helpers
#     view_mode_button_class: -> if Session.equals('view_mode', @view) then 'primary' else ''

# Template.set_view_mode.events
#     'click #set_view_mode': -> Session.set 'view_mode', @view
            
# Template.set_session_button.events
#     'click .set_session_filter': -> Session.set "#{@key}", @value
            
# Template.set_session_button.helpers
#     filter_class: -> 
#         if Session.equals("#{@key}","all") 
#             if @value is 'all'
#                 'primary' 
#             else
#                 ''
#         else if Session.get("#{@key}")
#             if Session.equals("#{@key}", parseInt(@value))
#                 'primary'
#             else
#                 ''
            
            
            
# Template.set_session_item.events
#     'click .set_session_filter': -> Session.set "#{@key}", @value
            

            
# Template.publish_button.events
#     'click #publish': ->
#         Docs.update FlowRouter.getQueryParam('doc_id'),
#             $set: published: true

#     'click #unpublish': ->
#         Docs.update FlowRouter.getQueryParam('doc_id'),
#             $set: published: false
            
            
Template.call_method.events
    'click .call_method': -> 
        Meteor.call @name, @argument, (err,res)->
            # else
                
                
            
        
        
Template.toggle_key.helpers
    toggle_key_button_class: -> 
        current_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        if @value
            if current_doc["#{@key}"] is @value then 'primary'
        # else if current_doc["#{@key}"] is true then 'primary' else ''
        else ''

Template.toggle_key.events
    'click .toggle_key': ->
        doc_id = FlowRouter.getQueryParam('doc_id')
        if @value
            Docs.update {_id:doc_id}, 
                { $set: "#{@key}": "#{@value}" },
                (err,res)=>
                    unless err
                        Docs.insert
                            type:'event'
                            parent_id: doc_id
                            text:"changed #{@key} to #{@value}."
                        
        else if Template.parentData()["#{@key}"] is true
            Docs.update doc_id, 
                $set: "#{@key}": false
        else
            Docs.update doc_id, 
                $set: "#{@key}": true



Template.set_sla_key_value.events
    'click .set_page_key_value': ->
        sla_doc = Template.parentData(1)
        Docs.update sla_doc._id,
            { $set: "#{@key}": @value }

Template.set_sla_key_value.helpers
    set_value_button_class: ->
        sla_doc = Template.parentData(1)
        if sla_doc["#{@key}"] is @value then 'primary' else ''


Template.toggle_sla_boolean.helpers
    toggle_boolean_button_class: -> 
        sla_doc = Template.parentData(1)
        if sla_doc["#{@key}"] is true then 'primary'
        else ''

Template.toggle_sla_boolean.events
    'click .trigger': (e,t)->
        sla_doc = Template.parentData(1)
        if sla_doc
            boolean_value = sla_doc["#{@key}"]
            
        # if @value
        #     Docs.update {_id:doc_id}, 
        #         { $set: "#{@key}": "#{@value}" },
        #         (err,res)=>
        #             if err
        #             else
        #                 Docs.insert
        #                     type:'event'
        #                     parent_id: doc_id
        #                     text:"changed #{@key} to #{@value}."
        Docs.update sla_doc._id, 
            $set: "#{@key}": !boolean_value
                        
Template.toggle_user_published.events
    'click #toggle_button': (e,t)->
        doc_id = FlowRouter.getQueryParam('doc_id')
        # if @value
        #     Docs.update {_id:doc_id}, 
        #         { $set: "#{@key}": "#{@value}" },
        #         (err,res)=>
        #             if err
        #             else
        #                 Docs.insert
        #                     type:'event'
        #                     parent_id: doc_id
        #                     text:"changed #{@key} to #{@value}."
        
        Meteor.users.update @_id, 
            $set: published: !@published
                        

        
Template.radio_item.events
    'click .ui.toggle.checkbox': (e,t)->
        doc_id = FlowRouter.getQueryParam('doc_id')
        # checkbox_value = $("input[name=#{@key}]").is(":checked")
        element = t.find("input:radio[name=#{@key}]:checked");
        radio_item_value = ($(element).val());

        # if @value
        #     Docs.update {_id:doc_id}, 
        #         { $set: "#{@key}": "#{@value}" },
        #         (err,res)=>
        #             if err
        #             else
        #                 Docs.insert
        #                     type:'event'
        #                     parent_id: doc_id
        #                     text:"changed #{@key} to #{@value}."
        Docs.update doc_id, 
            $set: "#{@key}": radio_item_value
                        

        
        
 
Template.multiple_user_select.onCreated ()->
    @autorun => Meteor.subscribe 'selected_users', FlowRouter.getQueryParam('doc_id'), @data.key
    @user_results = new ReactiveVar( [] )
Template.multiple_user_select.events
    'keyup #multiple_user_select_input': (e,t)->
        multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
        current_incident = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Meteor.call 'lookup_office_user_by_username_and_officename', current_incident.incident_office_name, multiple_user_select_input_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res

    'click .select_user': (e,t) ->
        key = Template.parentData(0).key
        page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'user_array_add', page_doc._id, key, @, (err,res)=>
            if err
            else
        $('#multiple_user_select_input').val ''
        t.user_results.set null
        if key is 'assigned_to'
            if page_doc.type is 'task'
                Meteor.call 'send_message', @username, Meteor.user().username, "You have been assigned to task: #{page_doc.title}."
                Meteor.call 'send_email_about_task_assignment', page_doc._id, @username
            else if page_doc.type is 'incident'
                Docs.update page_doc._id,
                    $set: assignment_timestamp:Date.now()
                Meteor.call 'send_message', @username, Meteor.user().username, "You have been assigned to incident: #{page_doc.title}."
                Meteor.call 'send_email_about_incident_assignment', page_doc._id, @username
    
    'click .pull_user': ->
        context = Template.currentData(0)
        if confirm 'Remove user?'
            page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
            Meteor.call 'user_array_pull', page_doc._id, context.key, @
    
Template.multiple_user_select.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    user_array_users: ->
        context = Template.currentData(0)
        parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Meteor.users.find(_id: $in: parent_doc["#{context.key}"])
    


# Template.many_doc_select.onCreated ->
#     @autorun =>  Meteor.subscribe 'type', 'customer'
# Template.many_doc_select.events
#     'autocompleteselect #search': (event, template, selected_doc) ->
#         key = Template.parentData(0).key
#         page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#         # searched_value = doc["#{template.data.key}"]
#         Meteor.call 'doc_array_add', page_doc._id, key, selected_doc, (err,res)=>
#         $('#search').val ''

#     'click .pull_doc': ->
#         context = Template.currentData(0)
#         swal {
#             title: "Remove #{@title} #{@text}?"
#             # text: 'Confirm delete?'
#             type: 'info'
#             animation: false
#             showCancelButton: true
#             closeOnConfirm: true
#             cancelButtonText: 'Cancel'
#             confirmButtonText: 'Unassign'
#             confirmButtonColor: '#da5347'
#         }, =>
#             page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#             Meteor.call 'doc_array_pull', page_doc._id, context.key, @, (err,res)=>
#                 if err
#                 else
    
# Template.single_doc_select.onCreated ->
#     @autorun =>  Meteor.subscribe 'type', 'customer'
# Template.single_doc_select.events
#     'autocompleteselect #search': (event, template, selected_doc) ->
#         save_key = Template.parentData(0).save_key
#         page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#         # searched_value = doc["#{template.data.key}"]
#         Meteor.call 'link_doc', page_doc._id, save_key, selected_doc, (err,res)=>
#         $('#search').val ''

#     'click .remove_doc': ->
#         context = Template.currentData(0)
#         swal {
#             title: "Remove #{@cust_name}?"
#             # text: 'Confirm delete?'
#             type: 'info'
#             animation: false
#             showCancelButton: true
#             closeOnConfirm: true
#             cancelButtonText: 'Cancel'
#             confirmButtonText: 'Unassign'
#             confirmButtonColor: '#da5347'
#         }, =>
#             page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#             Meteor.call 'unlink_doc', page_doc._id, context.save_key, @, (err,res)=>
#                 if err
#                 else
    
# Template.single_doc_select.helpers
#     settings: -> 
#         {
#             position: 'bottom'
#             limit: 10
#             rules: [
#                 {
#                     collection: Docs
#                     field: "#{@search_key}"
#                     matchAll: true
#                     filter: { type: "#{@type}" }
#                     template: Template.doc_result
#                 }
#             ]
#         }

#     selected_doc: ->
#         context = Template.currentData(0)
#         parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#         doc = 
#             Docs.findOne _id: parent_doc["#{context.save_key}"]
#         doc
        
# Template.single_doc_view.onCreated ->
#     @autorun =>  Meteor.subscribe 'incident', FlowRouter.getQueryParam('doc_id')
# Template.single_doc_view.helpers
#     selected_doc: ->
#         context = Template.currentData(0)
#         parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#         doc = 
#             Docs.findOne 
#                 "ev.ID": parent_doc["#{context.key}"]
#         doc
# Template.view_multiple_user.onCreated ->
#     @autorun =>  Meteor.subscribe 'users'

# Template.view_multiple_user.helpers
#     user_array_users: ->
#         context = Template.parentData(1)
#         parent_doc = Docs.findOne context._id
#         Meteor.users.find
#             _id: $in: parent_doc["#{@key}"]


Template.doc_result.onCreated ->
    @autorun =>  Meteor.subscribe 'doc', @data._id

Template.doc_result.helpers
    doc_context: ->
        context = Template.currentData(0)
        # parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        found = Docs.findOne context._id
        found
        
            
# Template.session_delete_button.onCreated ->
#     @confirming = new ReactiveVar(false)
            
     
# Template.session_delete_button.helpers
#     confirming: -> Template.instance().confirming.get()
# Template.session_delete_button.events
#     'click .delete': (e,t)-> 
#         # $(e.currentTarget).closest('.comment').transition('flash')
#         t.confirming.set true

#     'click .cancel': (e,t)-> t.confirming.set false
#     'click .confirm': (e,t)-> 
#         $(e.currentTarget).closest('.comment').transition('fade right')
#         $(e.currentTarget).closest('.notification_segment').transition('fade right')
#         Meteor.setTimeout =>
#             Docs.remove(@_id)
#         , 1000


Template.office_card.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', @data.office_jpid
Template.office_card.helpers
    office_doc: ->
        context = Template.currentData(0)
        doc = 
            Docs.findOne 
                type:'office'
                "ev.ID": context.office_jpid
        doc
        
Template.customer_card.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', @data.customer_jpid
Template.customer_card.helpers
    customer_doc: ->
        context = Template.currentData(0)
        doc = 
            Docs.findOne 
                type:'customer'
                "ev.ID": context.customer_jpid
        doc


Template.franchisee_card.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', @data.franchisee_jpid
Template.franchisee_card.helpers
    franchisee_doc: ->
        context = Template.currentData(0)
        doc = 
            Docs.findOne 
                type:'franchisee'
                "ev.ID": context.franchisee_jpid
        doc



Template.view_stat.onCreated ->
    @autorun =>  Meteor.subscribe 'stat', @data.doc_type, @data.stat_type
Template.view_stat.helpers
    stat_value: ->
        inputs = Template.currentData(0)
        doc = 
            Stats.findOne 
                doc_type:inputs.doc_type
                stat_type:inputs.stat_type
        if doc
            doc.amount



Template.view_single_user_key.onCreated ->
    @autorun =>  Meteor.subscribe 'sing_user_key', @data.doc_id, @data.key
Template.view_single_user_key.helpers
    stat_value: ->
        inputs = Template.currentData(0)
        doc = 
            Stats.findOne 
                doc_type:inputs.doc_type
                stat_type:inputs.stat_type
        if doc
            doc.amount


Template.assignment_widget.onCreated ()->
    @autorun => Meteor.subscribe 'assigned_users', FlowRouter.getQueryParam('doc_id')
    @user_results = new ReactiveVar( [] )
Template.assignment_widget.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup #multiple_user_select_input': (e,t)->
        multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
        current_incident = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Meteor.call 'lookup_office_user_by_username_and_officename', current_incident.incident_office_name, multiple_user_select_input_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res

    'click .select_user': (e,t) ->
        key = Template.parentData(0).key
        page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'assign_user', page_doc._id, @, (err,res)=>
            if err
            else
        $('#multiple_user_select_input').val ''
        t.user_results.set null
        if page_doc.type is 'task'
            Meteor.call 'send_message', @username, Meteor.user().username, "You have been assigned to task: #{page_doc.title}."
            Meteor.call 'send_email_about_task_assignment', page_doc._id, @username
        else if page_doc.type is 'incident'
            Docs.update page_doc._id,
                $set: assignment_timestamp:Date.now()
            Meteor.call 'send_message', @username, Meteor.user().username, "You have been assigned to incident: #{page_doc.title}."
            Meteor.call 'send_email_about_incident_assignment', page_doc._id, @username
    
    'click .pull_user': ->
        context = Template.currentData(0)
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
            Meteor.call 'unassign_user', page_doc._id, @
    
Template.assignment_widget.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    assigned_users: ->
        parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        if parent_doc
            Meteor.users.find(_id: $in: parent_doc.assigned_to)


Template.author_info.onCreated ->
    @autorun => Meteor.subscribe 'author', @data.author_id

# Template.blocks.onCreated ->
    # if @data.tags and typeof @data.tags is 'string'
    #     split_tags = @data.tags.split ','
    # else
    #     split_tags = @data.tags

Template.blocks.helpers
    blocks: -> 
        # if @tags and typeof @tags is 'string'
        #     split_tags = @tags.split ','
        # else
        #     split_tags = @tags
        if @position is 'left'
            Docs.find {
                type:'block'
                parent_slug:FlowRouter.getParam('page_slug')
                horizontal_position:'left'
            }, sort:rank:1
        else if @position is 'right'
            Docs.find {
                type:'block'
                parent_slug:FlowRouter.getParam('page_slug')
                horizontal_position:'right'
            }, sort:rank:1
        else
            Docs.find {
                type:'block'
                parent_slug:FlowRouter.getParam('page_slug')
                horizontal_position:$nin:['left','right']
            }, sort:rank:1
            
Template.block.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500

# Template.block.onRendered ->
#     stat = Stats.findOne()
#     if stat

Template.edit_block.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'schema'
    @autorun => Meteor.subscribe 'type', 'view'
    @autorun => Meteor.subscribe 'type', 'collection'

Template.block.onCreated ->
    @editing_block = new ReactiveVar false

    # Meteor.subscribe('facet', 
    #     selected_tags.array()
    #     selected_author_ids.array()
    #     selected_location_tags.array()
    #     selected_timestamp_tags.array()
    #     type=@data.children_doc_type
    #     )
    @page_number = new ReactiveVar(1)
    @sort_key = new ReactiveVar('timestamp')
    @sort_direction = new ReactiveVar(-1)
    @number_of_pages = new ReactiveVar(1)
    @page_size = new ReactiveVar(10)
    @skip = new ReactiveVar(0)

    if @data.limit
        @limit = new ReactiveVar(parseInt(@data.limit))
        @page_size = new ReactiveVar(parseInt(@data.limit))
    else
        @page_size = new ReactiveVar(10)
        @limit = new ReactiveVar(10)
    match_object = {}
    if FlowRouter.getParam 'jpid'
        match_object.jpid = FlowRouter.getParam 'jpid'
    if FlowRouter.getQueryParam 'doc_id'
        match_object.doc_id = FlowRouter.getQueryParam 'doc_id'
    if @data.filter_status is "ACTIVE"
        match_object.active = true
    else
        match_object.active = false
    match_object.doc_type = @data.children_doc_type
    match_object.stat_type = @data.table_stat_type
    @autorun -> Meteor.subscribe 'stat', match_object
    @autorun => Meteor.subscribe 'block_children', 
        @data._id, 
        @data.filter_key, 
        @data.filter_value, 
        Session.get('query'), 
        @page_size.get(),
        @sort_key.get(),
        @sort_direction.get(),
        @skip.get(),
        @data.filter_status,
        FlowRouter.getParam('jpid'),
        FlowRouter.getQueryParam('doc_id')

    @autorun => Meteor.subscribe 'schema_doc_by_type', @data.children_doc_type
    @autorun => Meteor.subscribe 'block_field_docs', @data._id
    
    
Template.block.helpers
    editing_block: -> Template.instance().editing_block.get() and Session.get('editing_mode')
    editing_button_class: -> if Template.instance().editing_block.get() is true then 'primary' else ''

    block_class: ->
        if @published
            @block_classes
        else
            @block_classes+" disabled"


    sort_descending: ->
        key = if @ev_subset then "ev.#{@key}" else @key
        temp = Template.instance() 
        if temp.sort_direction.get() is 1 and temp.sort_key.get() is key 
            return true
    sort_ascending: ->
        key = if @ev_subset then "ev.#{@key}" else @key
        temp = Template.instance() 
        if temp.sort_direction.get() is -1 and temp.sort_key.get() is key 
            return true

    comment_children: -> 
        temp = Template.instance() 
        match.type = @children_doc_type
        Docs.find {_id:$ne:Meteor.userId()},{ 
            sort:"timestamp":parseInt("#{temp.sort_direction.get()}") 
            }


    children: -> 
        temp = Template.instance() 
        if @children_collection is 'users'
            Meteor.users.find {_id:$ne:Meteor.userId()},{ 
                sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}") 
                }
        else
            match = {}
            if @filter_value is "{source_key}"
                context_doc = Docs.findOne FlowRouter.getQueryParam 'doc_id'
                if context_doc
                    result = context_doc["#{@filter_source_key}"]
                    if @children_doc_type is 'event'
                        match["#{@filter_key}"] = result
                    
            match.type = @children_doc_type
            # if @children_doc_type is 'event'
            if @filter_key is '_id'
                match._id = FlowRouter.getQueryParam 'doc_id'    
            if @hard_limit
                Docs.find match,
                    { 
                        sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}") 
                        limit:parseInt(@hard_limit)
                        }
            else
                Docs.find match,
                    { sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}") }

    can_view_block: ->
        if @published
            true
        else
            if Meteor.user() and Meteor.user().roles and 'dev' in Meteor.user().roles and Session.get('editing_mode')
                true
            else
                false
    child_schema_field_value: ->
        child_doc = Template.parentData(1)
        if @ev_subset
            child_doc.ev["#{@key}"]
        else
            child_doc["#{@key}"]
        
    is_table: -> @view is 'table'    
    is_list: -> @view is 'list'    
    is_comments: -> @view is 'comments'    
    is_grid: -> @view is 'grid'    
    is_cards: -> @view is 'cards'    
    is_sla_settings: -> @view is 'sla_settings'    

    can_lower: -> @rank>1
    
    th_field_docs: ->
        # block = Template.currentData()
        block = Template.parentData(0)
        # count = Docs.find(
        #     type:'display_field'
        #     # block_id:@_id
        # ).count()
        Docs.find {
            type:'display_field'
            block_id: block._id
        }, sort:rank:1
            
    children_field_docs: ->
        block = Template.parentData(1)
        Docs.find {
            type:'display_field'
            block_id: block._id
        }, sort:rank:1
            
            
Template.block.events
    'click .raise_block':->
        Docs.update @_id,
            $inc:rank:1
            
    'click .lower_block':->
        Docs.update @_id,
            $inc:rank:-1

    'click .toggle_editing_block': (e,t)->
        t.editing_block.set(!t.editing_block.get())

    'click .add_block_child': (e,t)->
        if FlowRouter.getParam('jpid')
            new_id = Docs.insert 
                type:@children_doc_type
                office_jpid:FlowRouter.getParam('jpid')
        else
            new_id = Docs.insert 
                type:@children_doc_type
        # FlowRouter.go("/edit/#{_id}")
    
    
    'click .move_up': ->
        current = Template.currentData()
        current_index = current.fields.indexOf @ 
        next_index = current+1
        Meteor.call 'move', current._id, current.fields, current_index, next_index
        
        
    'click .move_down': ->
        current = Template.currentData()
        current_index = current.fields.indexOf @ 
        lower_index = current-1
        Meteor.call 'move', current._id, current.fields, current_index, lower_index

    'click .sort_by': (e,t)->
        key = if @ev_subset then "ev.#{@key}" else @key
        t.sort_key.set key
        if t.sort_direction.get() is -1
            t.sort_direction.set 1
        else
            t.sort_direction.set -1


Template.edit_block.onRendered ->
    Meteor.setTimeout ->
        $('.tabular.menu .tab_nav').tab()
    , 400
    
    
Template.edit_block.helpers
    schema_doc: ->
        Docs.findOne
            type:'schema'
            slug:@children_doc_type
        
    show_schema_field: ->
        parent = Template.parentData()
        schema_fields = 
            Docs.findOne({
                type:'schema'
                slug:parent.children_doc_type
            }).fields
        block_fields = Docs.find(type:'display_field').fetch()
        selected_keys = _.pluck block_fields, 'key'
        if @slug in selected_keys then false else true
        
        
    schema_doc_fields: -> 
        block_doc = Template.parentData(1)
        schema_doc = Docs.findOne 
            type:'schema'
            slug: block_doc.children_doc_type
        if schema_doc
            schema_doc.fields
        
        
        
    values: ->
        schema_doc = Docs.findOne
            type:'schema'
            slug:@children_doc_type
        if schema_doc
            fields = schema_doc.fields
            values = []
            for field in fields
                values.push @ev["#{field.slug}"]
                # if field.ev_subset is true
                #     values.push Template.currentData().ev["#{field.key}"]
                # else
                #     values.push Template.currentData()["#{field.key}"]
            values
        
    schemas: -> Docs.find type:'schema'
    views: -> Docs.find type:'view'
    collections: -> Docs.find type:'collection'

    display_field_schema: ->
        Docs.findOne
            type:'schema'
            slug:'display_field'


    display_field_value: ->
        display_field = Template.parentData(1)
        display_field["#{@slug}"]


    field_docs: ->
        Docs.find {
            type:'display_field'
            block_id: @_id 
        }, sort:rank:1


 
    
Template.edit_block.events
    'click .tab_nav': (e,t)->
        tab_name = e.target.getAttribute('data-tab')

        button=e.currentTarget.id

        $("#"+button).addClass('primary');

        $.tab('change tab', tab_name)

    'click .add_field_doc': ->
        block = Template.currentData()
        field_count = Docs.find(type:'display_field').count()
        Docs.insert
            type:'display_field'
            block_id: @_id
            rank:field_count+1
            
            
    'click .delete_field': ->
        if confirm 'Remove field?'
            Docs.remove @_id
        

    'click .remove_block': ->
        if confirm 'Remove block?'
            Docs.remove @_id

    'click .add_schema_field': ->
        block = Template.currentData()
        field_count = Docs.find(type:'display_field').count()
        Docs.insert 
            type:'display_field'
            key:@slug
            label:@title
            sortable:true
            visible:true
            ev_subset:@ev_subset
            block_id: block._id
            rank:field_count+1
    
    'click .remove_schema_field': ->
        if confirm 'Remove field?'
            block = Template.currentData()
            Meteor.call 'remove_block_field_object', block._id, @

    'blur .field_template': (e,t)->
        template_value = e.currentTarget.value
        Meteor.call 'update_block_field', Template.currentData()._id, @, 'field_template', template_value

    'blur .field_label': (e,t)->
        template_value = e.currentTarget.value
        Meteor.call 'update_block_field', Template.currentData()._id, @, 'label', template_value



Template.blocks.events
    'click #add_block': (e,t)->
        # if @tags and typeof @tags is 'string'
        #     split_tags = @tags.split ','
        # else
        #     split_tags = @tags
        Docs.insert
            type:'block'
            position:@position
            title:'new block'
            published:false
            block_classes:'ui secondary segment'
            view_title:true
            parent_slug:FlowRouter.getParam('page_slug') 
            fields: []
    
    
    
Template.set_key_value.events
    'click .set_key_value': ->
        Docs.update Template.parentData(1)._id,
            { $set: "#{@key}": @value }
            
            
Template.set_page_key_value.events
    'click .set_page_key_value': ->
        page = Docs.findOne 
            type:'page'
            slug:FlowRouter.getParam('page_slug')
        Docs.update page._id,
            { $set: "#{@key}": @value }
    
Template.set_key_value_2.events
    'click .set_key_value': ->
        Docs.update Template.parentData(2)._id,
            { $set: "#{@key}": @value }
    
Template.set_key_value.helpers
    set_value_button_class: -> 
        if Template.parentData()["#{@key}"] is @value then 'primary' else ''

    
Template.set_page_key_value.helpers
    set_value_button_class: ->
        page = Docs.findOne 
            type:'page'
            slug:FlowRouter.getParam('page_slug')
        if page["#{@key}"] is @value then 'inverted blue' else ''

    
Template.set_key_value_2.helpers
    set_value_button_class: -> 
        if Template.parentData(2)["#{@key}"] is @value then 'primary' else ''

    
Template.edit_block_text_field.helpers 
    block_key_value: () -> 
        block_doc = Template.parentData()
        if block_doc
            block_doc["#{@key}"]
Template.edit_block_text_field.events
    'change .text_field': (e,t)->
        text_value = e.currentTarget.value
        Docs.update Template.parentData()._id,
            { $set: "#{@key}": text_value }


Template.edit_block_number_field.helpers 
    block_key_value: () -> 
        block_doc = Template.parentData()
        if block_doc
            block_doc["#{@key}"]
Template.edit_block_number_field.events
    'change .number_field': (e,t)->
        number_value = parseInt e.currentTarget.value
        Docs.update Template.parentData()._id,
            { $set: "#{@key}": number_value }


Template.set_field_key_value.events 
    'click .set_field_key_value': (e,t)->
        Meteor.call 'update_block_field', Template.parentData(2)._id, Template.parentData(), @key, @value

Template.toggle_block_field_boolean.events 
    'click .toggle_block_field_boolean': (e,t)->
        Meteor.call 'update_block_field', Template.parentData(2)._id, Template.parentData(), @key, true

Template.toggle_block_field_boolean.helpers 
    toggle_value_button_class: -> 
        if Template.parentData(2)["#{@key}"] is true then 'primary' else ''



Template.view_button.helpers
    url:-> "/p/#{@type}?doc_id=#{@_id}"
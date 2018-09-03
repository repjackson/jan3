Template.toggle_boolean.events
    'click #turn_on': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: "#{@key}": true

    'click #turn_off': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: "#{@key}": false

Template.toggle_boolean.helpers
    is_on: -> 
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        page_doc["#{@key}"]


Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"


Template.reference_type_single.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type
Template.reference_type_multiple.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type

Template.associated_users.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id
    
Template.associated_users.helpers
    associated_users: -> 
        if @assigned_to
            Meteor.users.find 
                _id: $in: @assigned_to


Template.incident_assigment_cell.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id
    
Template.incident_assigment_cell.helpers
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

Template.associated_incidents.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], 'incident'
Template.associated_incidents.helpers
    incidents: -> Docs.find type:'incident'


Template.reference_type_single.helpers
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

Template.reference_type_multiple.helpers
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


Template.reference_type_single.events
    # 'autocompleteselect #search': (event, template, doc) ->
    #     searched_value = doc["#{template.data.key}"]
    #     Docs.update FlowRouter.getParam('doc_id'),
    #         $set: "#{template.data.key}": "#{doc._id}"
    #     $('#search').val ''



Template.reference_type_multiple.events
    # 'autocompleteselect #search': (event, template, doc) ->
    #     searched_value = doc["#{template.data.key}"]
    #     Docs.update FlowRouter.getParam('doc_id'),
    #         $addToSet: "#{template.data.key}": "#{doc._id}"
    #     $('#search').val ''




Template.set_view_mode.helpers
    view_mode_button_class: -> if Session.equals('view_mode', @view) then 'active' else ''

Template.set_view_mode.events
    'click #set_view_mode': -> Session.set 'view_mode', @view
            
Template.set_session_button.events
    'click .set_session_filter': -> Session.set "#{@key}", @value
            
Template.set_session_button.helpers
    filter_class: -> 
        if Session.equals("#{@key}","all") 
            if @value is 'all'
                'primary' 
            else
                'basic'
        else if Session.get("#{@key}")
            if Session.equals("#{@key}", parseInt(@value))
                'primary'
            else
                'basic'
            
            
            
Template.set_session_item.events
    'click .set_session_filter': -> Session.set "#{@key}", @value
            

            
Template.publish_button.events
    'click #publish': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: published: true

    'click #unpublish': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: published: false
            
            
Template.call_method.events
    'click .call_method': -> 
        Meteor.call @name, @argument, (err,res)->
            # else
                
                
            
Template.incidents_by_type.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], 'incident'
Template.incidents_by_type.helpers
    typed_incidents: -> 
        incident_type_doc = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find {
            type:'incident'
            incident_type:incident_type_doc.slug
        }, sort:timestamp:-1
        
        
        
Template.toggle_key.helpers
    toggle_key_button_class: -> 
        current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        
        if @value
            if current_doc["#{@key}"] is @value then 'primary'
        # else if current_doc["#{@key}"] is true then 'active' else 'basic'
        else ''

Template.toggle_key.events
    'click .toggle_key': ->
        doc_id = FlowRouter.getParam('doc_id')
        if @value
            Docs.update {_id:doc_id}, 
                { $set: "#{@key}": "#{@value}" },
                (err,res)=>
                    if err
                        Bert.alert "Error changing #{@key} to #{@value}: #{error.reason}", 'danger', 'growl-top-right'
                    else
                        Docs.insert
                            type:'event'
                            parent_id: doc_id
                            text:"changed #{@key} to #{@value}."
                        Bert.alert "Changed #{@key} to #{@value}", 'success', 'growl-top-right'
                        
        else if Template.parentData()["#{@key}"] is true
            Docs.update doc_id, 
                $set: "#{@key}": false
        else
            Docs.update doc_id, 
                $set: "#{@key}": true


Template.toggle_boolean_checkbox.onRendered ->
    Meteor.setTimeout ->
        $('.checkbox').checkbox(
            # onChecked: -> 
            # onUnchecked: ->
        )
    , 500

        
# Template.toggle_boolean_checkbox.helpers
#     toggle_key_button_class: -> 
#         current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        
#         if @value
#             if current_doc["#{@key}"] is @value then 'primary'
#         # else if current_doc["#{@key}"] is true then 'active' else 'basic'
#         else ''

Template.toggle_boolean_checkbox.events
    'click .ui.toggle.checkbox': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        checkbox_value = $("input[name=#{@key}]").is(":checked")
        # if @value
        #     Docs.update {_id:doc_id}, 
        #         { $set: "#{@key}": "#{@value}" },
        #         (err,res)=>
        #             if err
        #                 Bert.alert "Error changing #{@key} to #{@value}: #{error.reason}", 'danger', 'growl-top-right'
        #             else
        #                 Docs.insert
        #                     type:'event'
        #                     parent_id: doc_id
        #                     text:"changed #{@key} to #{@value}."
        #                 Bert.alert "Changed #{@key} to #{@value}", 'success', 'growl-top-right'
        Docs.update doc_id, 
            $set: "#{@key}": checkbox_value
                        
Template.toggle_user_published.events
    'click #toggle_button': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        # if @value
        #     Docs.update {_id:doc_id}, 
        #         { $set: "#{@key}": "#{@value}" },
        #         (err,res)=>
        #             if err
        #                 Bert.alert "Error changing #{@key} to #{@value}: #{error.reason}", 'danger', 'growl-top-right'
        #             else
        #                 Docs.insert
        #                     type:'event'
        #                     parent_id: doc_id
        #                     text:"changed #{@key} to #{@value}."
        #                 Bert.alert "Changed #{@key} to #{@value}", 'success', 'growl-top-right'
        
        Meteor.users.update @_id, 
            $set: published: !@published
                        

        
Template.radio_item.events
    'click .ui.toggle.checkbox': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        # checkbox_value = $("input[name=#{@key}]").is(":checked")
        element = t.find("input:radio[name=#{@key}]:checked");
        radio_item_value = ($(element).val());

        # if @value
        #     Docs.update {_id:doc_id}, 
        #         { $set: "#{@key}": "#{@value}" },
        #         (err,res)=>
        #             if err
        #                 Bert.alert "Error changing #{@key} to #{@value}: #{error.reason}", 'danger', 'growl-top-right'
        #             else
        #                 Docs.insert
        #                     type:'event'
        #                     parent_id: doc_id
        #                     text:"changed #{@key} to #{@value}."
        #                 Bert.alert "Changed #{@key} to #{@value}", 'success', 'growl-top-right'
        Docs.update doc_id, 
            $set: "#{@key}": radio_item_value
                        

        
        
 
Template.multiple_user_select.onCreated ()->
    @autorun => Meteor.subscribe 'selected_users', FlowRouter.getParam('doc_id'), @data.key
    @user_results = new ReactiveVar( [] )
Template.multiple_user_select.events
    'keyup #multiple_user_select_input': (e,t)->
        multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
        current_incident = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.call 'lookup_office_user_by_username_and_officename', current_incident.incident_office_name, multiple_user_select_input_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res

    'click .select_user': (e,t) ->
        key = Template.parentData(0).key
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'user_array_add', page_doc._id, key, @, (err,res)=>
            if err
                Bert.alert "Error Assigning #{@username}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{@username}.", 'success', 'growl-top-right'
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
        swal {
            title: "Remove #{@username}?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Unassign'
            confirmButtonColor: '#da5347'
        }, =>
            page_doc = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call 'user_array_pull', page_doc._id, context.key, @, (err,res)=>
                if err
                    Bert.alert "Error removing #{@username}: #{err.reason}", 'danger', 'growl-top-right'
                else
                    Bert.alert "Removed #{@username}.", 'success', 'growl-top-right'
    
Template.multiple_user_select.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    user_array_users: ->
        context = Template.currentData(0)
        # console.log context
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.users.find(_id: $in: parent_doc["#{context.key}"])
    
Template.office_username_query.onCreated ()->
    @user_results = new ReactiveVar( [] )
    
Template.office_username_query.events
    'click .select_office_user': (e,t) ->
        key = Template.parentData(0).key
        # searched_value = doc["#{template.data.key}"]
        office_doc_id = FlowRouter.getParam('doc_id')
        # console.log key
        # console.log @username
        
        Docs.update office_doc_id,
            $set: "#{key}": @username
        # console.log Docs.findOne(office_doc_id)["#{key}"]
        # $(e.currentTarget).closest('#office_username_query').val ''
        t.user_results.set null


    'keyup #office_username_query': (e,t)->
        office_username_query = $(e.currentTarget).closest('#office_username_query').val().trim()
        # $('#office_username_query').val ''
        Session.set 'office_username_query', office_username_query
        current_office_id = Docs.findOne(FlowRouter.getParam('doc_id')).ev.ID
        Meteor.call 'lookup_office_user_by_username_and_office_jpid', current_office_id, office_username_query, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .pull_user': ->
        context = Template.currentData(0)
        swal {
            title: "Remove #{@username}?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Unassign'
            confirmButtonColor: '#da5347'
        }, =>
            page_doc = Docs.findOne FlowRouter.getParam('doc_id')
            Docs.update page_doc._id,
                $unset: "#{context.key}": 1

Template.office_username_query.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    selected_user: ->
        context = Template.currentData(0)
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        if parent_doc["#{context.key}"]
            Meteor.users.findOne
                username: parent_doc["#{context.key}"]
        else
            false


Template.view_sla_contact.helpers
    selected_contact: ->
        context = Template.currentData(0)
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        if parent_doc["#{context.key}"]
            Meteor.users.findOne
                username: parent_doc[parent_doc["#{context.key}"]]
        else
            false


Template.many_doc_select.onCreated ->
    @autorun =>  Meteor.subscribe 'type', 'customer'
Template.many_doc_select.events
    'autocompleteselect #search': (event, template, selected_doc) ->
        key = Template.parentData(0).key
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'doc_array_add', page_doc._id, key, selected_doc, (err,res)=>
            if err
                Bert.alert "Error Assigning #{selected_doc.text}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{selected_doc.text}.", 'success', 'growl-top-right'
        $('#search').val ''

    'click .pull_doc': ->
        context = Template.currentData(0)
        swal {
            title: "Remove #{@title} #{@text}?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Unassign'
            confirmButtonColor: '#da5347'
        }, =>
            page_doc = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call 'doc_array_pull', page_doc._id, context.key, @, (err,res)=>
                if err
                    Bert.alert "Error removing #{@title} #{@text}: #{err.reason}", 'danger', 'growl-top-right'
                else
                    Bert.alert "Removed #{@title} #{@text}.", 'success', 'growl-top-right'
    
Template.single_doc_select.onCreated ->
    @autorun =>  Meteor.subscribe 'type', 'customer'
Template.single_doc_select.events
    'autocompleteselect #search': (event, template, selected_doc) ->
        save_key = Template.parentData(0).save_key
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'link_doc', page_doc._id, save_key, selected_doc, (err,res)=>
            if err
                Bert.alert "Error Assigning #{selected_doc.cust_name}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{selected_doc.cust_name}.", 'success', 'growl-top-right'
        $('#search').val ''

    'click .remove_doc': ->
        context = Template.currentData(0)
        swal {
            title: "Remove #{@cust_name}?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Unassign'
            confirmButtonColor: '#da5347'
        }, =>
            page_doc = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call 'unlink_doc', page_doc._id, context.save_key, @, (err,res)=>
                if err
                    Bert.alert "Error removing #{@cust_name}: #{err.reason}", 'danger', 'growl-top-right'
                else
                    Bert.alert "Removed #{@cust_name}.", 'success', 'growl-top-right'
    
Template.single_doc_select.helpers
    settings: -> 
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Docs
                    field: "#{@search_key}"
                    matchAll: true
                    filter: { type: "#{@type}" }
                    template: Template.doc_result
                }
            ]
        }

    selected_doc: ->
        context = Template.currentData(0)
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        doc = 
            Docs.findOne _id: parent_doc["#{context.save_key}"]
        doc
        
Template.single_doc_view.onCreated ->
    @autorun =>  Meteor.subscribe 'incident', FlowRouter.getParam('doc_id')
Template.single_doc_view.helpers
    selected_doc: ->
        context = Template.currentData(0)
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        doc = 
            Docs.findOne 
                "ev.ID": parent_doc["#{context.key}"]
        doc
Template.view_multiple_user.onCreated ->
    @autorun =>  Meteor.subscribe 'users'

Template.view_multiple_user.helpers
    user_array_users: ->
        context = Template.parentData(1)
        parent_doc = Docs.findOne context._id
        Meteor.users.find
            _id: $in: parent_doc["#{@key}"]


Template.doc_result.onCreated ->
    @autorun =>  Meteor.subscribe 'doc', @data._id

Template.doc_result.helpers
    doc_context: ->
        context = Template.currentData(0)
        # parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
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
    @autorun =>  Meteor.subscribe 'office_by_id', @data.office_jpid
Template.office_card.helpers
    office_doc: ->
        context = Template.currentData(0)
        doc = 
            Docs.findOne 
                type:'office'
                "ev.ID": context.office_jpid
        doc
        
Template.customer_card.onCreated ->
    @autorun =>  Meteor.subscribe 'customer_by_id', @data.customer_jpid
Template.customer_card.helpers
    customer_doc: ->
        context = Template.currentData(0)
        doc = 
            Docs.findOne 
                type:'customer'
                "ev.ID": context.customer_jpid
        doc


Template.franchisee_card.onCreated ->
    @autorun =>  Meteor.subscribe 'franchisee_by_id', @data.franchisee_jpid
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
    @autorun => Meteor.subscribe 'assigned_users', FlowRouter.getParam('doc_id')
    @user_results = new ReactiveVar( [] )
Template.assignment_widget.events
    'keyup #multiple_user_select_input': (e,t)->
        multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
        current_incident = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.call 'lookup_office_user_by_username_and_officename', current_incident.incident_office_name, multiple_user_select_input_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res

    'click .select_user': (e,t) ->
        key = Template.parentData(0).key
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'assign_user', page_doc._id, @, (err,res)=>
            if err
                Bert.alert "Error Assigning #{@username}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{@username}.", 'success', 'growl-top-right'
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
        swal {
            title: "Remove #{@username}?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Unassign'
            confirmButtonColor: '#da5347'
        }, =>
            page_doc = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call 'unassign_user', page_doc._id, @, (err,res)=>
                if err
                    Bert.alert "Error removing #{@username}: #{err.reason}", 'danger', 'growl-top-right'
                else
                    Bert.alert "Removed #{@username}.", 'success', 'growl-top-right'
    
Template.assignment_widget.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    assigned_users: ->
        # console.log context
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.users.find(_id: $in: parent_doc.assigned_to)




Template.doc_type_module.onCreated ->
    @autorun => Meteor.subscribe 'doc_type_module', FlowRouter.getParam('doc_id'), @data.doc_type
Template.doc_type_module.onRendered ->
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 500

Template.doc_type_module.helpers
    children: -> Docs.find { type:@doc_type}

    view_mode_template: ->
        console.log @
        
        

Template.modules.onCreated ->
    @autorun => Meteor.subscribe 'type', 'module'

Template.modules.helpers
    modules: -> Docs.find type:'module'
    
    
Template.modules.events
    'click #add_module': (e,t)->
        Docs.insert
            type:'module'
    
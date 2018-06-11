Template.toggle_boolean.events
    'click #turn_on': ->
        Docs.update Template.parentData()._id, $set: complete: true

    'click #turn_off': ->
        Docs.update Template.parentData()._id, $set: complete: false

Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"


Template.reference_type_single.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type
Template.reference_type_multiple.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type

Template.associated_users.onCreated ->
    @autorun =>  Meteor.subscribe 'users'
Template.associated_users.helpers
    associated_users: -> 
        # console.log @
        if @assigned_to
            Meteor.users.find 
                _id: $in: @assigned_to

Template.associated_incidents.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], 'incident'
Template.associated_incidents.helpers
    incidents: -> Docs.find type:'incident'


Template.reference_type_single.helpers
    settings: -> 
        # console.log @
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Docs
                    field: "#{@search_field}"
                    matchAll: true
                    filter: { type: "#{@type}" }
                    template: Template.office_result
                }
            ]
        }

Template.reference_type_multiple.helpers
    settings: -> 
        # console.log @
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Docs
                    field: "#{@search_field}"
                    matchAll: true
                    filter: { type: "#{@type}" }
                    template: Template.customer_result
                }
            ]
        }


Template.reference_type_single.events
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{template.data.key}": "#{doc._id}"
        $('#search').val ''



Template.reference_type_multiple.events
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Docs.update FlowRouter.getParam('doc_id'),
            $addToSet: "#{template.data.key}": "#{doc._id}"
        $('#search').val ''




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
            

Template.delete_button.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            # doc = Docs.findOne FlowRouter.getParam('doc_id')
            # Docs.remove doc._id, ->
            #     FlowRouter.go "/docs"
            console.log template



Template.edit_link.events
    'blur #link': ->
        link = $('#link').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: link: link
            
            
Template.publish_button.events
    'click #publish': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: published: true

    'click #unpublish': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: published: false
            
            
Template.call_method.events
    'click .call_method': -> 
        # console.log Template.parentData(1)
        Meteor.call @name, Template.parentData(1)._id, (err,res)->
            # if err then console.log err
            # else
                # console.log 'res', res
                
                
Template.html_create.onCreated ->
    @autorun => Meteor.subscribe 'facet_doc', @data.tags
    
Template.html_create.helpers
    doc: ->
        tags = Template.currentData().tags
        split_array = tags.split ','

        Docs.findOne
            tags: split_array

    template_tags: -> Template.currentData().tags

    doc_classes: -> Template.parentData().classes

Template.html_create.events
    'click .create_doc': (e,t)->
        tags = t.data.tags
        split_array = tags.split ','
        new_id = Docs.insert
            tags: split_array
        Session.set 'editing_id', new_id

    'blur #staff': ->
        staff = $('#staff').val()
        Docs.update @_id,
            $set: staff: staff                
            
            
Template.google_places_input.onRendered ->
    # input = document.getElementById('google_places_field');
    # options = {
    #     types: ['geocode'],
    #     # componentRestrictions: {country: 'fr'}
    # }
    # @autocomplete = new google.maps.places.Autocomplete(input, options);
    # # console.log @autocomplete.getPlace
    # @autorun(() =>
    #     if GoogleMaps.loaded()
    #         # $('#google_places_field').geocomplete();
    #         $("#google_places_field").geocomplete().bind("geocode:result", (event, result)->
    #             console.log(result)
    #             lat = result.geometry.location.lat()
    #             long = result.geometry.location.lng()
    #             result.lat = lat
    #             result.lng = long
    #             if confirm "change location to #{result.formatted_address}?"
    #                 Meteor.call 'update_location', FlowRouter.getParam('doc_id'), result
    #             )
    # )


# Template.google_places_input.events
    # 'change #google_places_field': (e,t)->
    #     console.log $('#google_places_field').geocomplete();

        # result = t.autocomplete.gm_accessors_.place.jd.w3
        # console.dir result
        # Meteor.call 'update_location', FlowRouter.getParam('doc_id'), result, (err,res)->
            # console./log res
        # stuff = Template.instance().autocomplete.gm_accessors_.place
        # Docs.update FlowRouter.getParam('doc_id'),
        #     $set: stuff: stuff
        # console.dir stuff.jd.formattedPrediction
        
# Template.office_map.onRendered ->
#     doc = Docs.findOne FlowRouter.getParam('doc_id')
#     # console.log doc.location_ob.geometry
#     mymap = L.map('map').setView([doc.location_lat, doc.location_lng], 15);
#     L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
#         # attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
#         maxZoom: 18,
#         id: 'mapbox.streets',
#         accessToken: 'pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJjamc4dGtiYm4yN245MnFuNWMydWNuaXJlIn0.z3_-xuCT46yTC_6Zhl34kQ'
#     }).addTo(mymap);



Template.edit_author.onCreated ->
    Meteor.subscribe 'usernames'

Template.edit_author.events
    "autocompleteselect input": (event, template, doc) ->
        # console.log("selected ", doc)
        if confirm 'Change author?'
            Docs.update FlowRouter.getParam('doc_id'),
                $set: author_id: doc._id
            $('#author_select').val("")



Template.edit_author.helpers
    author_edit_settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Meteor.users
                field: 'username'
                matchAll: true
                template: Template.user_pill
            }
            ]
    }


Template.small_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', @data._id, 1
Template.small_doc_history.helpers
    doc_history_events: (e,t) ->
        Docs.find {
            parent_id: Template.currentData()._id
            type:'event'
        }, 
            sort:timestamp:-1
            
Template.full_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', @data._id
Template.full_doc_history.helpers
    doc_history_events: (e,t) ->
        Docs.find {
            parent_id: Template.currentData()._id
            type:'event'
        }, 
            sort:timestamp:-1
            
            
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
        # console.log current_doc["#{@key}"]
        # console.log @key
        # console.log Template.parentData()
        # console.log Template.parentData()["#{@key}"]
        
        if @value
            if current_doc["#{@key}"] is @value then 'primary'
        # else if current_doc["#{@key}"] is true then 'active' else 'basic'
        else ''

Template.toggle_key.events
    'click .toggle_key': ->
        doc_id = FlowRouter.getParam('doc_id')
        # console.log Template.parentData()
        # console.log @
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

        
        
# Template.view_telephone_field.helpers
#     doc_history_events: ->
#         Docs.find
#             parent_id:FlowRouter.getParam('doc_id')
#             type:'event'
       
Template.multiple_user_select.onCreated ->
    @autorun =>  Meteor.subscribe 'users'
Template.multiple_user_select.events
    'autocompleteselect #search': (event, template, selected_user) ->
        key = Template.parentData(0).key
        # console.log 'selected ', doc
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Meteor.call 'user_array_add', page_doc._id, key, selected_user, (err,res)=>
            if err
                Bert.alert "Error Assigning #{selected_user.username}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{selected_user.username}.", 'success', 'growl-top-right'

        $('#search').val ''

    'click .pull_user': ->
        context = Template.currentData(0)
        console.log context
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
    settings: -> 
        # console.log @
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Meteor.users
                    field: 'username'
                    matchAll: true
                    # filter: { type: "#{@type}" }
                    template: Template.user_result
                }
            ]
        }

    user_array_users: ->
        context = Template.currentData(0)
        # console.log context.key
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.users.find
            _id: $in: parent_doc["#{context.key}"]



Template.many_doc_select.onCreated ->
    @autorun =>  Meteor.subscribe 'type', 'customer'
Template.many_doc_select.events
    'autocompleteselect #search': (event, template, selected_doc) ->
        key = Template.parentData(0).key
        # console.log 'selected ', doc
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Meteor.call 'doc_array_add', page_doc._id, key, selected_doc, (err,res)=>
            if err
                Bert.alert "Error Assigning #{selected_doc.text}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{selected_doc.text}.", 'success', 'growl-top-right'
        $('#search').val ''

    'click .pull_doc': ->
        context = Template.currentData(0)
        console.log context
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
        # console.log 'selected ', selected_doc
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Meteor.call 'link_doc', page_doc._id, save_key, selected_doc, (err,res)=>
            if err
                Bert.alert "Error Assigning #{selected_doc.cust_name}: #{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Assigned #{selected_doc.cust_name}.", 'success', 'growl-top-right'
        $('#search').val ''

    'click .remove_doc': ->
        context = Template.currentData(0)
        console.log context
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
        # console.log @
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
        # console.log context.save_key
        parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log parent_doc["#{context.save_key}"]
        doc = 
            Docs.findOne _id: parent_doc["#{context.save_key}"]
        # console.log doc
        doc
Template.view_multiple_user.onCreated ->
    @autorun =>  Meteor.subscribe 'users'

Template.view_multiple_user.helpers
    user_array_users: ->
        context = Template.parentData(1)
        # console.log context
        parent_doc = Docs.findOne context._id
        Meteor.users.find
            _id: $in: parent_doc["#{@key}"]


Template.doc_result.onCreated ->
    @autorun =>  Meteor.subscribe 'doc', @data._id

Template.doc_result.helpers
    doc_context: ->
        context = Template.currentData(0)
        # console.log context.key
        # parent_doc = Docs.findOne FlowRouter.getParam('doc_id')
        found = Docs.findOne context._id
        # console.log found
        found
Template.toggle_boolean.events
    'click #make_featured': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: featured: true

    'click #make_unfeatured': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: featured: false

Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"


Template.reference_office.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type
Template.reference_customer.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type


Template.reference_office.helpers
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

Template.reference_customer.helpers
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


Template.reference_office.events
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{template.data.key}": "#{doc._id}"
        $('#search').val ''

Template.reference_customer.events
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{template.data.key}": "#{doc._id}"
        $('#search').val ''




Template.toggle_view_mode_button.helpers
    viewing_list: -> Session.equals 'viewing_list', false

Template.toggle_view_mode_button.events
    'click #toggle_view_mode': ->
        if Session.equals 'viewing_list', true
            Session.set 'viewing_list', false
        else
            Session.set 'viewing_list', true
            
Template.set_session_button.events
    'click .set_session_filter': -> Session.set "#{@key}", @value
            
Template.set_session_button.helpers
    filter_class: -> 
        if Session.equals("#{@key}","all") 
            if @value is 'all'
                'active' 
            else
                'basic'
        else if Session.get("#{@key}")
            if Session.equals("#{@key}", parseInt(@value))
                'active'
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
        console.log name
        Meteor.call @name, FlowRouter.getParam('doc_id'), (err,res)->
            if err then console.log err
            else
                console.log 'res', res
Template.services.onCreated ->
    @autorun => Meteor.subscribe 'type', 'service'

Template.services.helpers
    services: -> Docs.find type:'service'

    top_requested: -> 
        Docs.find {type:'service'}, 
            sort:request_count:-1

Template.request_service_button.events
    'click .request_service': ->
        current_customer_jpid = Meteor.user().customer_jpid
        new_request_id = 
            Docs.insert 
                type:'service_request'
                service_id:@_id
                service_title:@title
                service_slug:@slug
                customer_jpid:current_customer_jpid
        FlowRouter.go "/edit/#{new_request_id}"
        Meteor.call 'calculate_request_count', @_id


Template.service_view.onCreated ->
    @autorun => Meteor.subscribe 'service_child_requests', FlowRouter.getQueryParam('doc_id')

Template.service_child_requests.helpers
    child_requests: ->
        Docs.find type:'service_request'

Template.service_edit.events
    'click #delete': ->
        template = Template.currentData()
        if confirm 'Delete service?'
            doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
            Docs.remove doc._id, ->
                FlowRouter.go "/services"


Template.service_request_edit.events
    'click #delete': ->
        template = Template.currentData()
        if confirm 'Delete service request?'
            doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
            Docs.remove doc._id, ->
                FlowRouter.go "/services"
    
    'click #submit_request': ->
        doc_id = FlowRouter.getQueryParam 'doc_id'
        request = Docs.findOne doc_id
        
        service = Docs.findOne request.service_id
        Docs.update doc_id,
            $set:
                submitted:true
                submitted_datetime: Date.now()
                last_updated_datetime: Date.now()
        Meteor.call 'create_event', doc_id, 'submit_service_request', "submitted the service request for #{service.title}."
        # Meteor.call 'email_about_service_request', request._id
        FlowRouter.go "/v/#{request._id}"

Template.service_request_edit.helpers
    can_submit: ->
        @request_date and @request_details
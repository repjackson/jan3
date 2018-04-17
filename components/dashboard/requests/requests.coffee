if Meteor.isClient
    FlowRouter.route '/requests', action: ->
        BlazeLayout.render 'layout', 
            main: 'requests'
            
            
    FlowRouter.route '/request/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_request'
    
    
    
    Template.requests.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'request')

    Template.edit_request.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))

    
    Template.requests.helpers
        requests: -> Docs.find type:'request'

         
         
         
                
    Template.requests.events
        'click #add_request': ->
            id = Docs.insert type:'request'
            FlowRouter.go "/request/edit/#{id}"
    

    Template.request.events
        'click .approve': ->
            Docs.update @_id,
                $set:
                    approved: true
        
        'click .disapprove': ->
            Docs.update @_id,
                $set:
                    approved: false
            




    Template.edit_request.helpers
        request: -> 
            doc_id = FlowRouter.getParam 'doc_id'
            Docs.findOne  doc_id

        # shift_button_class: ->
        #     console.log @valueOf()

    Template.edit_request.events
        'blur #request_date': ->
            request_date = $('#request_date').val()
            # console.log request_date
            Docs.update FlowRouter.getParam('doc_id'),
                $set:
                    request_date: request_date
    
        'click .shift': (e,t)->
            selected_shift = $(e.currentTarget).closest('.shift').data('value')
            Docs.update @_id,
                $set: shift: selected_shift
                
    
        'click #delete_request': ->
            swal {
                title: 'Delete request?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/requests"
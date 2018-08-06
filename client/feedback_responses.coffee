if Meteor.isClient
    FlowRouter.route '/feedback_responses', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'admin_nav'
            main: 'feedback_responses'
    
    
    Template.feedback_responses.onCreated ->
        @autorun => Meteor.subscribe 'type', 'feedback_response'
    Template.feedback_responses.helpers
        feedback_responses: ->  Docs.find { type:'feedback_response'}


    Template.feedback_response_card.onCreated ->

    Template.feedback_response_card.helpers
        
    
    Template.feedback_response_edit.onCreated ->
        # @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.feedback_response_edit.helpers
        feedback_response: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.feedback_response_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete feedback_response?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                doc = Docs.findOne FlowRouter.getParam('doc_id')
                # console.log doc
                Docs.remove doc._id, ->
                    FlowRouter.go "/feedback_responses"


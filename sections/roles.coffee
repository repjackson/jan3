if Meteor.isClient
    Template.roles.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.roles.helpers
    
    
    FlowRouter.route '/roles', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'dev_nav'
            main: 'roles'
    
    
    @selected_role_tags = new ReactiveArray []
    
    Template.roles.onCreated ->
        @autorun => Meteor.subscribe 'docs', [], 'role'
    Template.roles.helpers
        roles: ->  Docs.find { type:'role'}


    Template.role_card.onCreated ->

    Template.role_card.helpers
        
    
    Template.role_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.role_edit.helpers
        role: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.role_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete role?'
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
                    FlowRouter.go "/roles"



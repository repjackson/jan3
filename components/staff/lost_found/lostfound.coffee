if Meteor.isClient
    FlowRouter.route '/lostfound', action: ->
        BlazeLayout.render 'layout', 
            main: 'lostfound'
            
            
    FlowRouter.route '/lostfound/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_lf_item'
    
    
    
    Template.lostfound.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'lostfound')
    Template.edit_lf_item.onCreated ->
        @autorun -> Meteor.subscribe('lostfound_item', FlowRouter.getParam('doc_id'))

    
    Template.lostfound.helpers
        lostfound_items: -> 
            Docs.find 
                type: 'lostfound'
         
         
         
         
                
    Template.lostfound.events
        'click #add_lf_reading': ->
            id = Docs.insert
                type: 'lostfound'
            FlowRouter.go "/lostfound/edit/#{id}"
    

    Template.edit_lf_item.helpers
        doc: -> 
            doc_id = FlowRouter.getParam 'doc_id'
            Docs.findOne  doc_id

    Template.edit_lf_item.events
        'click #delete_lf_item': ->
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
                doc = Docs.findOne FlowRouter.getParam('doc_id')
                Docs.remove doc._id, ->
                    FlowRouter.go "/lostfound"



if Meteor.isServer
    Meteor.publish 'lostfound', ()->
        
        self = @
        match = {}
        match.type = 'lostfound'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Docs.find match,
            limit: 10
            sort: 
                timestamp: -1
    
    Meteor.publish 'lostfound_item', (doc_id)->
        Docs.find doc_id

    

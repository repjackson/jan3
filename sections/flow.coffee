if Meteor.isClient
    Template.flow.onCreated ->
        # @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.flow.helpers
    
    FlowRouter.route '/flow', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'dev_nav'
            main: 'flow'
    
    @selected_flow_tags = new ReactiveArray []
    
    Template.flow.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='flow'
            author_id=null
            
    Template.flow.helpers
        flow: ->  Docs.find { type:'flow'}, sort:timestamp:1

    Template.create_child.events
        'click .create_child': ->  
            new_id = Docs.insert 
                type: 'flow'
                parent_id: FlowRouter.getParam('doc_id')
            FlowRouter.go "/edit/#{new_id}"

    Template.flow_child.events
        'click .start_move': ->  
            Session.set 'moving_id', @_id
            
            
        'click .end_move': ->  
            target_doc = Docs.findOne @_id
            moving_doc = Docs.findOne(Session.get('moving_id'))
            if confirm "Move #{moving_doc.text} under #{target_doc.text}?"
                Docs.update moving_doc._id,
                    $set: parent_id: target_doc._id
                Session.set 'moving_id', null

    Template.flow_child.helpers
        is_moving: -> Session.get 'moving_id'

    Template.flow_view.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='flow'
            author_id=null
            parent_id=FlowRouter.getParam('doc_id')

    Template.flow_card.helpers
        
    Template.flow_child.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', @data._id
    
    # Template.flow_edit.helpers
    #     flow: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.flow_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete flow?'
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
                    FlowRouter.go "/flow"



if Meteor.isClient
    Template.ideas.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.ideas.helpers
    
    
    FlowRouter.route '/ideas', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'admin_nav'
            main: 'ideas'
    
    
    @selected_idea_tags = new ReactiveArray []
    
    Template.ideas.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='idea'
            author_id=null
    Template.ideas.helpers
        ideas: ->  Docs.find { type:'idea'}


    Template.idea_card.onCreated ->

    Template.idea_card.helpers
        
    
    Template.idea_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.idea_edit.helpers
        idea: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.idea_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete idea?'
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
                    FlowRouter.go "/ideas"



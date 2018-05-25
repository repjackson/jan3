

Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
        # Meteor.call 'generate_person_cloud', Meteor.userId()
        return id


if Meteor.isClient
    FlowRouter.route '/view/:doc_id', 
        name: 'view'
        action: (params) ->
            BlazeLayout.render 'layout',
                # nav: 'nav'
                main: 'doc_view'
    
    
    Template.doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.doc_view.helpers
        doc: -> Docs.findOne FlowRouter.getParam('doc_id')
        type_view: -> "#{@type}_view"
            
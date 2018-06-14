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
        
        
FlowRouter.route '/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'doc_edit'

Template.doc_edit.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.doc_edit.helpers
    doc: -> Docs.findOne FlowRouter.getParam('doc_id')
    type_edit: -> "#{@type}_edit"
            
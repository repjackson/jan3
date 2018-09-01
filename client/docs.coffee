FlowRouter.route '/v/:doc_id', 
    name: 'view'
    action: (params) ->
        BlazeLayout.render 'layout',
            # nav: 'nav'
            main: 'doc_view'


Template.doc_view.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    @autorun -> Meteor.subscribe 'schema_doc', FlowRouter.getParam('doc_id')

Template.doc_view.helpers
    doc: -> Docs.findOne FlowRouter.getParam('doc_id')
    type_view: -> "#{@type}_view"
    schema_doc: ->
        Docs.findOne
            type:'schema'
    view_field_template: -> "view_#{@type}_field"

FlowRouter.route '/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'doc_edit'

Template.doc_edit.onCreated ->
    @autorun -> Meteor.subscribe 'schema_doc', FlowRouter.getParam('doc_id')
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.doc_edit.helpers
    doc: -> Docs.findOne FlowRouter.getParam('doc_id')
    type_edit: -> "#{@type}_edit"
    schema_doc: ->
        Docs.findOne
            type:'schema'
    edit_field_template: -> "edit_#{@type}_field"


Template.doc_card.onCreated ->
    @autorun => Meteor.subscribe 'schema_doc', @data._id
    
Template.doc_card.helpers
    schema_doc: ->
        Docs.findOne
            type:'schema'
            slug:@type

    slug_value: () -> 
        current_doc = Template.parentData(2)
        current_doc["#{@slug}"]

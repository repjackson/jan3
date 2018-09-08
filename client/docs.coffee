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
        doc = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.findOne
            type:'schema'
            slug:doc.type
    view_field_template: -> "view_#{@type}_field"
    slug_value: -> 
        doc = Docs.findOne FlowRouter.getParam('doc_id')
        if doc
            doc["#{@slug}"]


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
        doc = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.findOne
            type:'schema'
            slug:doc.type
    edit_field_template: -> "edit_#{@type}_field"

    slug_value: -> 
        doc = Docs.findOne FlowRouter.getParam('doc_id')
        if doc
            doc["#{@slug}"]


Template.doc_edit.events
    'change .text_field': (e,t)->
        text_value = e.currentTarget.value
        Docs.update FlowRouter.getParam('doc_id'),
            { $set: "#{@slug}": text_value }
            , (err,res)=>
                if err
                    Bert.alert "Error Updating #{@label}: #{err.reason}", 'danger', 'growl-top-right'
                else
                    Bert.alert "Updated #{@label}", 'success', 'growl-top-right'


Template.doc_card.onCreated ->
    @autorun => Meteor.subscribe 'schema_doc', @data._id
    
Template.doc_card.helpers
    schema_doc: ->
        found = Docs.findOne
            type:'schema'
            slug:@type
        # console.log found
        found
    

    slug_value: -> 
        current_doc = Template.parentData(2)
        if @ev_subset
            current_doc.ev["#{@slug}"]
        else
            current_doc["#{@slug}"]

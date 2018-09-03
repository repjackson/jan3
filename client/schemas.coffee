Template.schemas.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
Template.schemas.helpers


FlowRouter.route '/schemas', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'admin_nav'
        main: 'schemas'


# @selected_schema_tags = new ReactiveArray []

Template.schemas.onCreated ->
    @autorun => Meteor.subscribe 'type', 'schema'
    
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='schema'
        author_id=null
        
        
Template.schemas.helpers
    schemas: ->  Docs.find { type:'schema'}


Template.schema_card.onCreated ->

Template.schema_card.helpers
    

Template.schema_edit.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
Template.schema_view.onCreated ->
    doc = Docs.findOne FlowRouter.getParam('doc_id')
    if doc
        @autorun -> Meteor.subscribe 'type', doc.slug

# Template.schema_edit.helpers
#     schema: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.schema_view.helpers
    schema_docs: -> 
        schema = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find type:schema.slug
    single_view: -> 
        schema = Docs.findOne FlowRouter.getParam('doc_id') 
        return "#{schema.slug}_single"

Template.schema_view.events

Template.schema_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete schema?'
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
                FlowRouter.go "/schemas"


    'click #add_field': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $addToSet: 
                fields: 
                    title: 'New Field'
                    type: 'text'


Template.field_edit.events
    'click .remove_field': -> 
        if confirm "Remove #{@label} field?"
            schema_doc_id = FlowRouter.getParam('doc_id')
            Meteor.call 'pull_schema_field', schema_doc_id, @, (err,res)=>
                if err
                    Bert.alert "Error pulling #{@label}: #{err.reason}", 'danger', 'growl-top-right'
                else
                    # Bert.alert "Updated", 'success', 'growl-top-right'


    'change .field_title': (e,t)->
        self = @
        new_title = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_title', doc_id, @, new_title, (err,res)=>
            # if err
            #     Bert.alert "Error Updating #{@label}: #{err.reason}", 'danger', 'growl-top-right'
            # else
            #     Bert.alert "Updated Field Title to #{new_title}", 'success', 'growl-top-right'
        # Meteor.call 'slugify', doc_id, @, new_title, (err,res)=>
        #     if err
        #         Bert.alert "Error Updating #{@label}: #{err.reason}", 'danger', 'growl-top-right'
        #     else
        #         console.log res
        #         $(e.currentTarget).closest('.field_slug').val res
        #         Meteor.call 'update_field_slug', doc_id, @, res, (err,res)=>

            

    'change .field_slug': (e,t)->
        text_value = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        # console.log text_value
        Meteor.call 'update_field_slug', doc_id, @, text_value, (err,res)=>
            # if err
            #     Bert.alert "Error Updating #{@label}: #{err.reason}", 'danger', 'growl-top-right'
            # else
            #     Bert.alert "Updated Field slug to #{text_value}", 'success', 'growl-top-right'



Template.schema_doc.helpers
    schema_fields: -> 
        # current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log current_doc["#{@key}"]
        console.log @
        console.log Template.parentData()
        console.log Template.parentData(2)
        # console.log Template.parentData()["#{@key}"]
        
        # if Template.parentData().type is @value then 'active' else 'basic'

    view_field_template: -> "view_#{@type}_field"
        

Template.select_field_key_value.events
    'click .select_field_key_value': ->
        field = Template.parentData()
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_key_value', doc_id, field, @key, @value, (err,res)=>
            # if err
            #     Bert.alert "Error updating field type to #{@value}: #{err.reason}", 'danger', 'growl-top-right'
            # else
            #     Bert.alert "Updated field type to #{@value}", 'success', 'growl-top-right'


Template.select_field_key_value.helpers
    select_field_key_value_button_class: -> 
        # current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log current_doc["#{@key}"]
        # console.log @
        # console.log Template.parentData()
        # console.log Template.parentData()["#{@key}"]
        
        if Template.parentData()["#{@key}"] is @value then 'active' else 'basic'
    # 'change .field_type': (e,t)->
    #     text_value = e.currentTarget.value
    #     Docs.update FlowRouter.getParam('doc_id'),
    #         { $set: "#{@key}": text_value }
    #         , (err,res)=>




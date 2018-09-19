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
            Docs.remove doc._id, ->
                FlowRouter.go "/p/schemas"


    'click #add_field': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $addToSet: 
                fields: 
                    title: 'New Field'
                    type: 'text'

Template.schema_field_edit.onCreated ->
    @autorun => Meteor.subscribe 'type', 'field'

Template.schema_field_edit.helpers
    fields: -> Docs.find type:'field'

Template.schema_field_edit.events
    'click .remove_field': -> 
        if confirm "Remove #{@label} field?"
            schema_doc_id = FlowRouter.getParam('doc_id')
            Meteor.call 'pull_schema_field', schema_doc_id, @, (err,res)=>


    'change .field_title': (e,t)->
        self = @
        new_title = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_title', doc_id, @, new_title, (err,res)=>
        # Meteor.call 'slugify', doc_id, @, new_title, (err,res)=>
        #         $(e.currentTarget).closest('.field_slug').val res
        #         Meteor.call 'update_field_slug', doc_id, @, res, (err,res)=>

            

    'change .field_slug': (e,t)->
        text_value = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_slug', doc_id, @, text_value, (err,res)=>



Template.schema_doc.helpers
    schema_fields: -> 
        # current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        
        # if Template.parentData().type is @value then 'blue' else 'basic'

    view_field_template: -> "view_#{@type}_field"
        

Template.select_field_key_value.events
    'click .select_field_key_value': ->
        field = Template.parentData()
        field_object = Template.parentData(2)
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_key_value', doc_id, field_object, @key, @value


Template.toggle_field_boolean.events
    'click .toggle_field_boolean': ->
        parent = Template.parentData()

        toggled_value = !parent["#{@key}"]
        field = Template.parentData()
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_key_value', doc_id, field, @key, toggled_value

Template.toggle_field_boolean.helpers
    field_boolean_class: -> 
        if Template.parentData()["#{@key}"] is true then 'blue' else 'basic'

Template.select_field_key_value.helpers
    select_field_key_value_button_class: -> 
        if Template.parentData(2)["#{@key}"] is @value then 'blue' else 'basic'




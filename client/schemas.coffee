Template.schema_edit.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
Template.schema_view.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'field_instance'
    
    doc = Docs.findOne FlowRouter.getParam('doc_id')
    if doc
        @autorun -> Meteor.subscribe 'type', doc.slug

# Template.schema_edit.helpers
#     schema: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.schema_view.helpers
    field_instances: ->
        Docs.find type:'field_instance'
        
    referenced_field_instances: ->
        page_schema = Docs.findOne FlowRouter.getParam 'doc_id'
        
        Docs.find 
            type:'field_instance'
            _id: $in: page_schema.field_instance_ids

    schema_docs: -> 
        schema = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find type:schema.slug
    single_view: -> 
        schema = Docs.findOne FlowRouter.getParam('doc_id') 
        return "#{schema.slug}_single"

Template.schema_view.events
    'click .add_field_instance': ->
        page_schema = Docs.findOne FlowRouter.getParam 'doc_id'
        Docs.update page_schema._id,
            $addToSet: field_instance_ids: @_id



Template.schema_edit.events
    'click #delete': ->
        template = Template.currentData()
        if confirm 'Delete schema?'
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
    @autorun => Meteor.subscribe 'type', 'field_type'

Template.schema_field_edit.helpers
    fields: -> Docs.find type:'field_type'

Template.schema_field_edit.events
    'click .remove_field': -> 
        if confirm "Remove #{@label} field?"
            schema_doc_id = FlowRouter.getParam('doc_id')
            Meteor.call 'pull_schema_field', schema_doc_id, @


    'change .field_title': (e,t)->
        self = @
        new_title = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_title', doc_id, @, new_title
        # Meteor.call 'slugify', doc_id, @, new_title
        #         $(e.currentTarget).closest('.field_slug').val res
        #         Meteor.call 'update_field_slug', doc_id, @, res

    'change .field_slug': (e,t)->
        text_value = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_slug', doc_id, @, text_value

    'change .field_template': (e,t)->
        text_value = e.currentTarget.value
        doc_id = FlowRouter.getParam('doc_id')
        Meteor.call 'update_field_template', doc_id, @, text_value



Template.schema_doc.helpers
    schema_fields: -> 
        # current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        
        # if Template.parentData().type is @value then 'primary' else ''

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
        if Template.parentData()["#{@key}"] is true then 'primary' else ''

Template.select_field_key_value.helpers
    select_field_key_value_button_class: -> 
        if Template.parentData(2)["#{@key}"] is @value then 'primary' else ''




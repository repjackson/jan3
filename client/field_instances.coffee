FlowRouter.route '/field_instances', 
    name: 'field_instances'
    action: (params) ->
        BlazeLayout.render 'layout',
            # nav: 'nav'
            main: 'field_instances'

Template.field_instances.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'field_instance'
    
Template.field_instances.helpers
    field_instances: ->
        Docs.find type:'field_instance'
        

Template.field_instances.events
    'click .add_field_instance': ->
        Docs.insert
            type:'field_instance'
            
            
Template.edit_field_instance_field.events
    'change .text_field': (e,t)->
        text_value = e.currentTarget.value
        field_doc = Template.parentData(1)
        Docs.update field_doc._id,
            { $set: "#{@key}": text_value }
            
            
Template.edit_field_instance_field.helpers
    field_instance_value: ->
        doc_field = Template.parentData(1)
        if doc_field
            doc_field["#{@key}"]
                
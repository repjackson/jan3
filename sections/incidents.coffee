if Meteor.isClient
    FlowRouter.route '/incidents', 
        action: ->
            selected_timestamp_tags.clear()
            selected_keywords.clear()
            BlazeLayout.render 'layout', main: 'incidents'
 
    Template.incident_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
 

 
    Template.incident_view.onRendered ->
        Meteor.setTimeout ->
            $('.ui.checkbox').checkbox()
        #     $('.ui.tabular.menu .item').tab()
        , 400
        Meteor.setTimeout ->
            $('.ui.tabular.menu .item').tab()
        , 500
        
        # $('.step').on('click', () ->
        #     console.log 'hi'
        #     $.tab('change tab', 'two')
        #     )
    Template.incident_level_set.events
        'click .set_level': ->
            incident = Template.parentData(1)
            doc_id = FlowRouter.getParam('doc_id')

            Docs.update incident._id,
                $set: current_level:@level
                Meteor.call 'create_event', doc_id, 'change_incident_level', 'changed incident level'
                
                
                
    Template.incident_type_label.helpers
        incident_type_label: ->
            switch @incident_type
                when 'missed_service' then 'Missed Service'
                when 'poor_service' then 'Poor Service'
                when 'employee_issue' then 'Employee Issue'
                when 'other' then 'Other'
        
        type_label_class: ->
            switch @incident_type
                when 'missed_service' then 'basic'
                when 'poor_service' then 'basic'
                when 'employee_issue' then 'basic'
                when 'other' then 'grey'
    
    
    Template.incidents.onCreated ->
    Template.incidents.helpers
        selector: ->  type: "incident"
    
    Template.incident_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
        @autorun -> Meteor.subscribe 'docs', [], 'incident_type'
    
    Template.incident_edit.helpers
        incident: -> Doc.findOne FlowRouter.getParam('doc_id')
        incident_type_docs: -> Docs.find type:'incident_type'
    Template.incident_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete Incident?'
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
                    FlowRouter.go "/incidents"




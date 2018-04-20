if Meteor.isClient
    Template.incident_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
 
    Template.incident_view.onRendered ->
        Meteor.setTimeout ->
            $('.ui.checkbox').checkbox()
        #     $('.ui.tabular.menu .item').tab()
        , 400
        
        # $('.step').on('click', () ->
        #     console.log 'hi'
        #     $.tab('change tab', 'two')
        #     )
    Template.incident_level_set.events
        'click .set_level': ->
            incident = Template.parentData(1)
            Docs.update incident._id,
                $set: current_level:@level
    
    Template.incident_type_label.helpers
        incident_type_label: ->
            switch @incident_type
                when 'missed_service' then 'Missed Service'
                when 'poor_service' then 'Poor Service'
                when 'employee_issue' then 'Employee Issue'
                when 'other' then 'Other'
        
        type_label_class: ->
            switch @incident_type
                when 'missed_service' then 'teal basic'
                when 'poor_service' then 'blue basic'
                when 'employee_issue' then 'violet basic'
                when 'other' then 'grey'
    
    
    
            
        
    FlowRouter.route '/incidents', action: ->
        BlazeLayout.render 'layout', main: 'incidents'
    
    
    @selected_incident_tags = new ReactiveArray []
    
    Template.incidents.onCreated ->
        @autorun -> Meteor.subscribe('docs',[],'incident')
        @autorun -> Meteor.subscribe('docs',[],'comment')
    Template.incidents.helpers
        incidents: ->  Docs.find { type:'incident'}
    
        viewing_list: -> Session.equals 'viewing_list',true    
    
    Template.incident_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.incident_edit.helpers
        incident: -> Doc.findOne FlowRouter.getParam('doc_id')
        
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



if Meteor.isClient
    Template.my_incidents.onCreated -> @autorun -> Meteor.subscribe('my_incidents')
    
    Template.my_incidents.helpers
        my_incidents: -> 
            Incidents.find {},
                sort: publish_date: -1
                
if Meteor.isServer
    Meteor.publish 'my_incidents', ->
        Incidents.find author_id: @userId


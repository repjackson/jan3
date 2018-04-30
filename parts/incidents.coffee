if Meteor.isClient
    FlowRouter.route '/incidents', action: ->
        BlazeLayout.render 'layout', main: 'incidents'
 
    Session.setDefault 'level','all'
    Session.setDefault 'view_mode','table'
 
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
                when 'missed_service' then 'basic'
                when 'poor_service' then 'basic'
                when 'employee_issue' then 'basic'
                when 'other' then 'grey'
    
    
    
            
        
    
    
    @selected_incident_tags = new ReactiveArray []
    
    Template.incidents.onCreated ->
        # @autorun -> Meteor.subscribe('incidents',parseInt(Session.get('level')))
        # @autorun -> Meteor.subscribe('docs',[],'comment')
        # @autorun -> Meteor.subscribe('docs',[],'office')
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='incident'
            author_id=null

        
        
    Template.incidents.helpers
        incidents: ->  
            Docs.find {type:'incident'}, {limit:7}
            # if Session.equals('level','all')
            #     Docs.find type:'incident'
            # else
            #     Docs.find 
            #         type:'incident'
            #         current_level:parseInt(Session.get('level'))
        viewing_list: -> Session.equals 'view_mode','list'    
        viewing_table: -> Session.equals 'view_mode','table'    
        viewing_cards: -> Session.equals 'view_mode','cards'    
    
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




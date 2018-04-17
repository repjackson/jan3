if Meteor.isClient
    FlowRouter.route '/readings', action: ->
        BlazeLayout.render 'layout', 
            sub_sub_nav: 'reading_menu'
            main: 'all_readings'
            
    FlowRouter.route '/readings/indoor', action: ->
        BlazeLayout.render 'layout', 
            sub_sub_nav: 'reading_menu'
            main: 'readings'
            
    FlowRouter.route '/readings/outdoor', action: ->
        BlazeLayout.render 'layout', 
            sub_sub_nav: 'reading_menu'
            main: 'readings'
            
    FlowRouter.route '/readings/pool', action: ->
        BlazeLayout.render 'layout', 
            sub_sub_nav: 'reading_menu'
            main: 'readings'
            
            
    FlowRouter.route '/reading/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'reading_menu'
            main: 'edit_reading'
    
    
    
    
    Template.readings.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500    

    Template.readings.onCreated ->
        @autorun -> Meteor.subscribe('readings')

    Template.edit_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))
    
    Template.readings.helpers
        readings: -> 
            Docs.find 
                type: 'reading'
                location: Template.currentData().location
         
        readings_label: ->
            switch Template.currentData().location
                when 'outdoor_hot_tub' then 'Outdoor Hot Tub'
                when 'indoor_hot_tub' then 'Indoor Hot Tub'
                when 'pool' then 'Pool'
         
                
    Template.readings.events
        'click #add_reading': ->
            id = Docs.insert
                type: 'reading'
                location: Template.currentData().location
            FlowRouter.go "/reading/edit/#{id}"
    
    
    
    
    Template.edit_reading.helpers
        reading: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 


    Template.ph.events
        'blur #ph': (e,t)->
            ph = parseFloat $(e.currentTarget).closest('#ph').val()
            Docs.update @_id,
                $set: ph: ph
    
    Template.chlorine.events
        'blur #chlorine': (e,t)->
            chlorine = parseFloat $(e.currentTarget).closest('#chlorine').val()
            Docs.update @_id,
                $set: chlorine: chlorine
    
    Template.temperature.events
        'blur #temperature': (e,t)->
            temperature = parseFloat $(e.currentTarget).closest('#temperature').val()
            Docs.update @_id,
                $set: temperature: temperature
    
    Template.br.events
        'blur #br': (e,t)->
            br = parseFloat $(e.currentTarget).closest('#br').val()
            Docs.update @_id,
                $set: br: br
    
    Template.alkalinity.events
        'blur #alkalinity': (e,t)->
            alkalinity = parseFloat $(e.currentTarget).closest('#alkalinity').val()
            Docs.update @_id,
                $set: alkalinity: alkalinity
    
    Template.notes.events
        'blur #notes': (e,t)->
            notes =  $(e.currentTarget).closest('#notes').val()
            Docs.update @_id,
                $set: notes: notes

    Template.delete_reading_button.events
        'click #delete_reading': (e,t)->
            swal {
                title: 'Delete Reading?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/readings"







if Meteor.isServer
    Meteor.publish 'readings', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        type = 'reading'
        
        Docs.find match,
            limit: 10
            sort: 
                timestamp: -1
    

    

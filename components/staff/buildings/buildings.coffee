if Meteor.isClient
    FlowRouter.route '/buildings', action: ->
        BlazeLayout.render 'layout', 
            main: 'buildings'
            
            
    FlowRouter.route '/building/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_building'
    
    
    FlowRouter.route '/building/view/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'view_building'
    
    
    Template.buildings.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500    

    
    Template.buildings.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'building')
        
   
    Template.edit_building.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))

    Template.view_building.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))



    Template.buildings.helpers
        buildings: ->
            Docs.find
                type: 'building'
                
    Template.buildings.events
        'click #add_building': ->
            id = Docs.insert type: 'building'
            FlowRouter.go "/building/edit/#{id}"
    
    Template.edit_building.helpers
        building: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 

    Template.view_building.helpers
        building: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 


    Template.edit_building.events
        'click #delete_building': (e,t)->
            swal {
                title: 'Delete Building?'
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
                    FlowRouter.go "/buildings"



        'click #add_building_number': (e,t)->
            building_number = parseInt $('#new_building_number').val()
            Docs.update @_id,
                $addToSet: 
                    building_numbers: building_number
            $('#new_building_number').val('')
        
        'keyup #new_building_number': (e,t)->
            if e.which is 13
                building_number = parseInt $('#new_building_number').val()
                Docs.update @_id,
                    $addToSet: 
                        building_numbers: building_number
                $('#new_building_number').val('')
    
        'change #select_building_street': (e,t)->
            building_street = e.currentTarget.value
            Docs.update @_id,
                $set: building_street: building_street

        'click .remove_number': (e,t)->
            building_number = @valueOf()
            Docs.update FlowRouter.getParam('doc_id'),
                $pull: 
                    building_numbers: building_number
            

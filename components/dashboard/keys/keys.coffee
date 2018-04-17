




if Meteor.isClient
    @selected_buildings = new ReactiveArray []

    
    FlowRouter.route '/keys', action: ->
        BlazeLayout.render 'layout',
            main: 'keys'
            
            
    FlowRouter.route '/key/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_key'
    
    FlowRouter.route '/key/view/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'view_key'
    
    
    
    
    Template.keys.onCreated ->
        @autorun -> Meteor.subscribe('keys', selected_buildings.array())
        @autorun -> Meteor.subscribe('docs', [], 'building')

    # Template.edit_key.onRendered ->
    #     Meteor.setTimeout (->
    #         $('select.dropdown').dropdown()
    #     ), 500

    Template.keys.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
            # $('select.dropdown').dropdown()
        ), 500



    Template.edit_key.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))
        @autorun -> Meteor.subscribe('buildings')
    
         
         
    Template.keys.helpers
        keys: -> 
            Docs.find {type: 'key'},
                sort: tag_number: 1
        buildings: -> Docs.find type: 'building'
         
        selected_building_class: ->
            if @building_code in selected_buildings.array() then 'blue' else 'basic'
         
         selected_buildings: -> selected_buildings.array()
         
    Template.edit_key.helpers
        buildings: -> Docs.find type: 'building'
         
        building_numbers: ->
            # console.log @
            building = Docs.findOne 
                type: 'building'
                building_code: @building_code
            # console.log building
            if building then building.building_numbers
        key: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 

        mark_true_class: -> 
            if @fpm then 'disabled green'
            else if @key_exists then '' else 'basic'
        
        mark_false_class: -> 
            if @fpm then 'disabled basic'
            else if @key_exists then 'basic' else ''




    Template.keys.events
        'click #add_key': ->
            id = Docs.insert type: 'key'
            FlowRouter.go "/key/edit/#{id}"
    
        'click .add_next_key': ->
            id = Docs.insert 
                tag_number: @tag_number + 1
                building_code: @building_code
                building_number: @building_number
                type: 'key'
            FlowRouter.go "/key/edit/#{id}"
    
        'click .toggle_view_building': ->
            if @building_code in selected_buildings.array() then selected_buildings.remove @building_code else selected_buildings.push @building_code

    Template.edit_key.events
        'click #delete_key': (e,t)->
            swal {
                title: 'Delete Key?'
                text: 'Cannot be undone.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/keys"

        'change #select_building_code': (e,t)->
            building_code = e.currentTarget.value
            Docs.update @_id,
                $set: building_code: building_code

        'blur #apartment_number': (e,t)->
            apartment_number = $(e.currentTarget).closest('#apartment_number').val()
            Docs.update @_id,
                $set: apartment_number: apartment_number

        'change #select_building_number': (e,t)->
            building_number = e.currentTarget.value
            Docs.update @_id,
                $set: building_number: building_number


        'change #fpm': (e,t)->
            # console.log e.currentTarget.value
            value = $('#fpm').is(":checked")
            if value is true
                Docs.update @_id, 
                    $set:
                        key_exists: true
                    
            Docs.update @_id, 
                $set:
                    fpm: value
    
        'click #mark_true': (e,t)->
            Docs.update @_id,
                $set: key_exists: true
        'click #mark_false': (e,t)->
            Docs.update @_id,
                $set: key_exists: false
    
        'blur #tag_number': (e,t)->
            tag_number = parseInt $(e.currentTarget).closest('#tag_number').val()
            Docs.update @_id,
                $set: tag_number: tag_number



if Meteor.isServer
    Meteor.publish 'keys', (selected_buildings)->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        match.type = 'key'
        match.building_code = $in: selected_buildings
        
        Docs.find match,
            # limit: 10
            sort: 
                tag_number: -1
    
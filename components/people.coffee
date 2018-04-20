if Meteor.isClient
    FlowRouter.route '/people', action: ->
        BlazeLayout.render 'layout', 
            main: 'people'
            
            
    Template.people.onCreated ->
        @autorun -> Meteor.subscribe('docs', [], 'person')
   

    Template.people.helpers
        people: -> 
            # People.find {}
            Docs.find
                type: 'person'
                
    Template.people.events
        'click #add_person': ->
            id = Docs.insert type:'person'
            FlowRouter.go "/person/edit/#{id}"
    

    Template.person_view.helpers
        person: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 
    
    Template.person_edit.helpers
        person: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 

        unassigned_roles: ->
            role_list = [
                'admin'
                'customer'
                'user_master'
                ]
            _.difference role_list, @roles


    Template.person_edit.events
        'click #delete_person': (e,t)->
            swal {
                title: 'Delete person?'
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
                    FlowRouter.go "/people"


        'click .assign_role': ->
            Docs.update FlowRouter.getParam('doc_id'),
                $addToSet: 
                    roles: @valueOf()
        'click .unassign_role': ->
            Docs.update FlowRouter.getParam('doc_id'),
                $pull: 
                    roles: @valueOf()
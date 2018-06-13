if Meteor.isClient
    FlowRouter.route '/users', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            sub_nav: 'admin_nav'
            main: 'users'

            
    Template.users.helpers
        # users: -> Meteor.users.find()
                
    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert type:'user'
        #     FlowRouter.go "/user/edit/#{id}"
    
    
    
    Template.users.onCreated ->
        # @autorun -> Meteor.subscribe('users', selected_people_tags.array())
    # Template.user.onCreated ->
    #     @autorun -> Meteor.subscribe('user', @_id)
    Template.role_selector.onCreated ->
        @autorun -> Meteor.subscribe('type', 'role')
    
    Template.role_selector.helpers
        user_roles: -> Docs.find type:'role'
    
    
    Template.users.helpers
        # people: -> 
        #     Meteor.users.find { 
        #         _id: $ne: Meteor.userId()
        #         # tags: $in: selected_people_tags.array()
        #         }, 
        #         sort:
        #             tag_count: 1
        #         limit: 20
    
    Template.users.onCreated () ->
        Template.instance().uploading = new ReactiveVar false 
    
    Template.users.helpers
        uploading: -> Template.instance().uploading.get()
    
    
    Template.users.events
        'change [name="upload_csv"]': (event,template)->
            template.uploading.set true

            Papa.parse event.target.files[0],
                header: true
                complete: (results,file) =>
                    Meteor.call 'parseUpload', results.data, (err,res)=>
                        if err
                            console.log err.reason
                        else
                            template.uploading.set false
                            Bert.alert 'Upload complete!', 'success', 'growl-top-right'
    
    
    
    
    Template.role_selector.events
        'click .toggle_role': ->
            console.log @
    
        #  'click .remove_role': ->
        #     self = @
        #     swal {
        #         title: "Remove #{@username} from roles?"
        #         # text: 'You will not be able to recover this imaginary file!'
        #         type: 'warning'
        #         animation: false
        #         showCancelButton: true
        #         # confirmButtonColor: '#DD6B55'
        #         confirmButtonText: 'Remove role Status'
        #         closeOnConfirm: false
        #     }, ->
        #         Meteor.users.update self._id, 
        #             $pull: roles: 'role'
        #         swal "Removed role privilages from #{self.username}", "",'success'
        #         return
    @selected_people_tags = new ReactiveArray []
    
    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe 'people_tags', selected_people_tags.array()
    
    Template.user_cloud.helpers
        all_people_tags: ->
            user_count = Meteor.users.find(_id: $ne:Meteor.userId()).count()
            if 0 < user_count < 3 then People_tags.find({ count: $lt: user_count }, {limit:42}) else People_tags.find({}, limit:42)
            # People_tags.find()
    
        selected_people_tags: -> selected_people_tags.array()
    
        cloud_tag_class: ->
            button_class = switch
                when @index <= 10 then 'big'
                when @index <= 20 then 'large'
                when @index <= 30 then ''
                when @index <= 40 then 'small'
                when @index <= 50 then 'tiny'
            return button_class
        
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: People_tags
                    field: 'name'
                    matchAll: false
                    template: Template.tag_result
                }
                ]
        }
    
    
    Template.user_cloud.events
        'click .select_tag': -> selected_people_tags.push @name
        'click .unselect_tag': -> selected_people_tags.remove @valueOf()
        'click #clear_tags': -> selected_people_tags.clear()
    
    
        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_people_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_people_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_people_tags.pop()
                        
        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_people_tags.push doc.name
            $('#search').val ''
        

FlowRouter.route '/admin', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'user_table'
 
 
if Meteor.isClient
    Template.user_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users'
    
    
    Template.user_table.helpers
        users: -> Meteor.users.find {}
            
        is_staff: -> Roles.userIsInRole(@_id, 'staff')
        is_owner: -> Roles.userIsInRole(@_id, 'owner')
        is_dev: -> Roles.userIsInRole(@_id, 'dev')
        is_resident: -> Roles.userIsInRole(@_id, 'resident')
    
    
    
    
    
    Template.user_table.events
        'click #add_user': ->
            
    
    
        'click .remove_staff': ->
            self = @
            swal {
                title: "Remove #{@emails[0].address} from staffs?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Privilages'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'staff'
                swal "Removed staff Privilages from #{self.emails[0].address}", "",'success'
                return
    
    
        'click .make_staff': ->
            self = @
            swal {
                title: "Make #{@emails[0].address} an staff?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make staff'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'staff'
                swal "Made #{self.emails[0].address} a staff", "",'success'
                return
    
        'click .remove_owner': ->
            self = @
            swal {
                title: "Remove #{@emails[0].address} from owners?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove owner Status'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'owner'
                swal "Removed owner privilages from #{self.emails[0].address}", "",'success'
                return
    
    
        'click .make_owner': ->
            self = @
            swal {
                title: "Make #{@emails[0].address} a owner?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make owner'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'owner'
                swal "Made #{self.emails[0].address} an owner", "",'success'
                return
    
 
         'click .remove_resident': ->
            self = @
            swal {
                title: "Remove #{@username} from residents?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove resident Status'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'resident'
                swal "Removed resident privilages from #{self.username}", "",'success'
                return
    
    
        'click .make_resident': ->
            self = @
            swal {
                title: "Make #{@username} a resident?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make resident'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'resident'
                swal "Made #{self.username} an resident", "",'success'
                return
    
 
  
         'click .remove_dev': ->
            self = @
            swal {
                title: "Remove #{@username} from devs?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove dev Status'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'dev'
                swal "Removed dev privilages from #{self.username}", "",'success'
                return
    
    
        'click .make_dev': ->
            self = @
            swal {
                title: "Make #{@username} a dev?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make dev'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'dev'
                swal "Made #{self.username} a dev", "",'success'
                return
    
 
 

FlowRouter.route '/admin', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'admin'
 
FlowRouter.route '/admin/users', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'user_table'
 
FlowRouter.route '/admin/notifications', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'user_table'
 
FlowRouter.route '/admin/roles', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'roles'
 
FlowRouter.route '/admin/rules', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'admin_rules'
 
 
if Meteor.isClient
    Template.user_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users'
    
    
    Template.user_table.helpers
        users: -> Meteor.users.find {}
        is_admin: -> Roles.userIsInRole(@_id, 'admin')
    
    
    
    
    
    Template.user_table.events
        'click .remove_admin': ->
            self = @
            swal {
                title: "Remove #{@emails[0].address} from admins?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Privilages'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'admin'
                swal "Removed admin Privilages from #{self.emails[0].address}", "",'success'
                return
    
    
        'click .make_admin': ->
            self = @
            swal {
                title: "Make #{@emails[0].address} an admin?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make admin'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'admin'
                swal "Made #{self.emails[0].address} a admin", "",'success'
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
    
 
 
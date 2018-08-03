FlowRouter.route '/users', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        # sub_nav: 'admin_nav'
        main: 'users'


Template.users.onCreated ->
    @autorun -> Meteor.subscribe 'all_users', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))

Template.users.helpers
    all_users: -> 
        Meteor.users.find {
        },{ 
            sort:
                "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}")
        }

    
    
    # settings: ->
    #     collection: 'users'
    #     rowsPerPage: 10
    #     showFilter: true
    #     # showColumnToggles: true
    #     showRowCount: true
    #     fields: [
    #         { key: 'username', label: 'Username' }
    #         { key: 'profile.first_name', label: 'First Name' }
    #         { key: 'profile.last_name', label: 'Last Name' }
    #         { key: 'ev.JOB_TITLE', label: 'Job Title' }
    #         { key: 'ev.WORK_TELEPHONE', label: 'Work Tel' }
    #         { key: 'emails[0].address', label: 'Email' }
    #         { key: 'profile.office_name', label: 'Email' }
    #         { key: '', label: 'View', tmpl:Template.view_user_button }
    #     ]

Template.role_switcher.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'role'

Template.role_switcher.helpers
    role_docs: ->
        Docs.find
            type: 'role'

    role_button_class: ->
        if Meteor.user() and Meteor.user().roles and @slug in Meteor.user().roles then 'active' else ''


Template.footer.helpers
    site_doc: ->
        site_doc = Docs.findOne Session.get('current_site_id')
        if site_doc then site_doc

    bug_link: -> Session.get 'bug_link'


Template.footer.events
    "click #report_bug": ->
        Session.set 'bug_link', window.location.pathname
        new_bug_id = Docs.insert
            type:'bug'
            complete:false
            link:window.location.pathname
        FlowRouter.go("/edit/#{new_bug_id}")


Template.role_switcher.events
    'click .change_role': ->
        cursor = Docs.find(type:'role').fetch()
        # console.log @
        user = Meteor.user()
        if user
            if @slug in user.roles
                Meteor.users.update Meteor.userId(),
                    $pull: roles:@slug
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: roles: @slug
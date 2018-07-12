Template.role_switcher.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'role'

Template.role_switcher.helpers
    role_docs: -> 
        Docs.find 
            type: 'role'

    role_button_class: ->
        if Meteor.user() and Meteor.user().roles and @name in Meteor.user().roles then 'blue' else ''


Template.footer.helpers
    site_doc: -> 
        site_doc = Docs.findOne Session.get('current_site_id')
        if site_doc then site_doc

    bug_link: -> Session.get 'bug_link'


Template.footer.events
    "click #report_bug": ->
        Session.set 'bug_link', window.location.pathname
        $('.ui.report.modal').modal(
            inverted: true
            # transition: 'vertical flip'
            # observeChanges: true
            duration: 500
            onApprove : ()->
                val = $("#bug_description").val()
                window.alert val
                console.log val
                Docs.insert
                    type: 'bug'
                    complete: false
                    body: val
                    link: window.location.pathname
                $("#bug_description").val('')
    
                # $('.ui.confirm.modal').modal('show');
            ).modal('show')

Template.role_switcher.events
    'click .change_role': ->
        cursor = Docs.find(type:'role').fetch()
        # console.log @
        Meteor.users.update Meteor.userId(),
            $set: roles: [@name]
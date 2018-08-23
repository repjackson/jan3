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
        new_bug_id = Docs.insert
            type:'bug'
            complete:false
            link:window.location.pathname
        FlowRouter.go("/edit/#{new_bug_id}")
        # $('.ui.report.modal').modal(
        #     inverted: false
        #     # transition: 'vertical flip'
        #     # observeChanges: true
        #     duration: 400
        #     onApprove : ()->
        #         val = $("#bug_description").val()
        #         timestamp = Date.now()
        #         long_timestamp = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
                
        #         new_bug_id = Docs.insert
        #             type: 'bug'
        #             complete: false
        #             body: val
        #             link: window.location.pathname
        #         link = "https://www.jan.meteorapp.com/view/#{new_bug_id}"
        #         $("#bug_description").val('')
        #         Meteor.call 'create_event', new_bug_id, 'bug_submit', "submitted a bug: #{val}."
        #         Meteor.call 'beta_send_email', "#{Meteor.user().username} submitted a bug on the JP Portal.", "<h3>#{Meteor.user().username} submitted this bug on the JP Portal:</h3> <h3>#{val}</h3><h3> at #{long_timestamp}.</h3> <a href=#{link}>View Bug</a>"
    
        #         # $('.ui.confirm.modal').modal('show');
        #     ).modal('show')
            

Template.role_switcher.events
    'click .change_role': ->
        cursor = Docs.find(type:'role').fetch()
        console.log @
        user = Meteor.user()
        if user
            if @name in user.roles
                Meteor.users.update Meteor.userId(),
                    $pull: roles:@name
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: roles: @name
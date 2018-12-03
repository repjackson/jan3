Template.nav.events
    'click .delta': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'delta'
                viewing_delta: false
   
    'click .add': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'add'
                viewing_delta: false

    

Template.nav.events
    'click .delete_delta': ->
        if confirm 'Clear Session?'
            delta = Docs.findOne type:'delta'
            Docs.remove delta._id

    'click .run_fo': ->
        delta = Docs.findOne type:'delta'
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false

    'click .show_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        console.log delta

Template.cc.events
    'click .settings': ->
        delta = Docs.findOne type:'delta'
        # console.log @
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'account_settings'
                viewing_delta:false
                viewing_menu:false

    'click .work': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                page_template:'work'
                viewing_page: true
                viewing_delta: false


    'click .view_profile': ->
        delta = Docs.findOne type:'delta'
        # console.log @
        Docs.update delta._id,
            $set:
                viewing_username: Meteor.user().username
                viewing_page:true
                page_template:'user_view'
                viewing_delta:false
                viewing_menu:false


    'click .sla': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'office_sla'
                viewing_delta:false
                viewing_menu:false

Template.nav.events
    'click #logout': (e,t)->
        # e.preventDefault()
        t.signing_out.set true
        Meteor.logout ->
            t.signing_out.set false


Template.nav.helpers
    signing_out: -> Template.instance().signing_out.get()



Template.role_switcher.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'role'

Template.role_switcher.helpers
    role_docs: ->
        Docs.find
            type: 'role'

    role_button_class: ->
        if Meteor.user() and Meteor.user().roles and @slug in Meteor.user().roles then 'blue' else ''


# Template.footer.helpers
    # site_doc: ->
    #     site_doc = Docs.findOne Session.get('current_site_id')
    #     if site_doc then site_doc

    # bug_link: -> Session.get 'bug_link'



# Template.footer.events
    # "click #report_bug": ->
    #     Session.set 'bug_link', window.location.pathname
    #     new_bug_id = Docs.insert
    #         type:'bug'
    #         complete:false
    #         link:window.location.pathname
    #     FlowRouter.go("/edit/#{new_bug_id}")


    # 'click .toggle_footer': ->
    #     delta = Docs.findOne type:'delta'
    #     Docs.update delta._id,
    #         $set:
    #             viewing_menu: !delta.viewing_menu
    #             menu_template: 'dash'

    # 'click .expand_footer': ->
    #     delta = Docs.findOne type:'delta'
    #     Docs.update delta._id,
    #         $set:
    #             expand_footer:true
    #             view_leftbar:false
    #             view_rightbar:false
    #             view_topbar:false

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
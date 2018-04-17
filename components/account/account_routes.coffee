FlowRouter.route '/account', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_account'



FlowRouter.route '/account/settings', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'account_settings'
        
        





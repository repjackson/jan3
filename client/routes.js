import { FlowRouter } from 'meteor/kadira:flow-router'
import { BlazeLayout } from 'meteor/kadira:blaze-layout'

FlowRouter.notFound = {
  action: ()=> {
    return BlazeLayout.render('layout', {
      main: 'not_found'
    })
  }
}
FlowRouter.route('/account/settings', {
	action: function(params) {
		return BlazeLayout.render('layout', {
			main: 'account_settings'
		})
	}
})
FlowRouter.route('/customers', {
  action: ()=> {
    return BlazeLayout.render('layout', {
      main: 'customers'
    })
  }
})

FlowRouter.route('/history', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'history'
    })
  }
})


FlowRouter.route('/users', {
  action: function(params) {
    return BlazeLayout.render('layout', {
      nav: 'nav',
      main: 'users'
    })
  }
})


FlowRouter.route('/user/:username', {
  action: function(params) {
    return BlazeLayout.render('layout', {
      main: 'user_view'
    })
  }
})



FlowRouter.route('/user/add', {
  action: ()=> {
    return BlazeLayout.render('layout', {
      nav: 'nav',
      main: 'add_user'
    })
  }
})


FlowRouter.route('/admin', {
  action: ()=> {
    return BlazeLayout.render('layout', {
      main: 'admin'
    })
  }
})

FlowRouter.route('/bugs', {
  action: ()=> {
    return BlazeLayout.render('layout', {
      main: 'bugs'
    })
  }
})


FlowRouter.route('/login', {
  action: ()=> {
    return BlazeLayout.render('accounts_layout', {
      main: 'login'
    })
  }
})

FlowRouter.route('/register_officer', {
  action: ()=> {
    return BlazeLayout.render('accounts_layout', {
      main: 'register_officer'
    })
  }
})

FlowRouter.route('/register_customer', {
  action: ()=> { return BlazeLayout.render('accounts_layout', { main: 'register_customer'})
  }
})

FlowRouter.route('/reset_password', {
  action: ()=> {
    return BlazeLayout.render('accounts_layout', {
      main: 'reset_password'
    })
  }
})

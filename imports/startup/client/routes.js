import { FlowRouter } from 'meteor/kadira:flow-router'
import { BlazeLayout } from 'meteor/kadira:blaze-layout'

FlowRouter.notFound = {
  action: function() {
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
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'customers'
    });
  }
});


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
    });
  }
});



FlowRouter.route('/user/add', {
  action: function() {
    return BlazeLayout.render('layout', {
      nav: 'nav',
      main: 'add_user'
    })
  }
})


FlowRouter.route('/admin', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'admin'
    })
  }
})

FlowRouter.route('/bugs', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'bugs'
    })
  }
})


FlowRouter.route('/login', {
  action: function() {
    return BlazeLayout.render('accounts_layout', {
      main: 'login'
    })
  }
})

FlowRouter.route('/register_officer', {
  action: function() {
    return BlazeLayout.render('accounts_layout', {
      main: 'register_officer'
    })
  }
})

FlowRouter.route('/register_customer', {
  action: function() {
    return BlazeLayout.render('accounts_layout', {
      main: 'register_customer'
    })
  }
})

FlowRouter.route('/reset_password', {
  action: function() {
    return BlazeLayout.render('accounts_layout', {
      main: 'reset_password'
    })
  }
})

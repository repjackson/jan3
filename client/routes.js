import { FlowRouter } from 'meteor/ostrio:flow-router-extra'

// FlowRouter.notFound = {
//   action() {
//     this.render('layout', {
//       main: 'not_found'
//     })
//   }
// }

FlowRouter.route('/', {
  action() {
    this.render('layout', {
      main: 'dashboard'
    })
  }
})


FlowRouter.route('/account/settings', {
	action(params) {
		this.render('layout', {
			main: 'account_settings'
		})
	}
})

FlowRouter.route('/customers', {
  action() {
    this.render('layout', {
      main: 'customers'
    })
  }
})

FlowRouter.route('/history', {
  action() {
    this.render('layout', {
      main: 'history'
    })
  }
})


FlowRouter.route('/users', {
  action(params) {
    this.render('layout', {
      nav: 'nav',
      main: 'users'
    })
  }
})
FlowRouter.route('/jpids', {
  action: function() {
    this.render('layout', {
      main: 'jpids'
    })
  }
})

FlowRouter.route('/incidents', {
  action: function() {
    this.render('layout', {
      main: 'incidents'
    });
  }
});

FlowRouter.route('/edit/:doc_id', {
  action: function(params) {
    this.render('layout', {
      main: 'doc_edit'
    });
  }
});



FlowRouter.route('/view/:doc_id', {
  name: 'view',
  action: function(params) {
    this.render('layout', {
      main: 'doc_view'
    });
  }
});


FlowRouter.route('/rules', {
  action: function() {
    this.render('layout', {
      main: 'rules'
    });
  }
});

FlowRouter.route('/rules', {
  action: function() {
    this.render('layout', {
      main: 'rules'
    });
  }
});
FlowRouter.route('/roles', {
  action: function() {
    this.render('layout', {
      main: 'roles'
    });
  }
});


FlowRouter.route('/user/edit/:user_id', {
  action: function(params) {
    this.render('layout', {
      main: 'user_edit'
    });
  }
});


FlowRouter.route('/customer_incidents', {
  action: function() {
    this.render('layout', {
      main: 'customer_incidents'
    });
  }
});



FlowRouter.route('/franchisees', {
  action: function() {
    this.render('layout', {
      main: 'franchisees'
    })
  }
})


FlowRouter.route('/user/:username', {
  action(params) {
    this.render('layout', {
      main: 'user_view'
    })
  }
})



FlowRouter.route('/user/add', {
  action() {
    this.render('layout', {
      nav: 'nav',
      main: 'add_user'
    })
  }
})


FlowRouter.route('/admin', {
  action() {
    this.render('layout', {
      main: 'admin'
    })
  }
})

FlowRouter.route('/bugs', {
  action() {
    this.render('layout', {
      main: 'bugs'
    })
  }
})


FlowRouter.route('/login', {
  action() {
    this.render('accounts_layout', {
      main: 'login'
    })
  }
})

FlowRouter.route('/register_officer', {
  action() {
    this.render('accounts_layout', {
      main: 'register_officer'
    })
  }
})

FlowRouter.route('/register_customer', {
  action() { 
    this.render('accounts_layout', { main: 'register_customer'})
  }
})

FlowRouter.route('/reset_password', {
  action() {
    this.render('accounts_layout', {
      main: 'reset_password'
    })
  }
})


FlowRouter.route('/offices', {
  action() {
    this.render('layout', {
      main: 'offices'
    })
  }
})

FlowRouter.route('/office/:doc_id/incidents', {
  action() {
    this.render('layout', {
      main: 'office_incidents'
    })
  }
})

FlowRouter.route('/office/:doc_id/employees', {
  action() {
    this.render('layout', {
      main: 'office_employees'
    })
  }
})

FlowRouter.route('/office/:doc_id/franchisees', {
  action() {
    this.render('layout', {
      main: 'office_franchisees'
    })
  }
})

FlowRouter.route('/office/:doc_id/customers', {
  action() {
    this.render('layout', {
      main: 'office_customers'
    })
  }
})

FlowRouter.route('/office/:doc_id/settings', {
  action() {
    this.render('layout', {
      main: 'office_settings'
    })
  }
})

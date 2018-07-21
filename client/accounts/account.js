FlowRouter.route('/account/settings', {
	action: function(params) {
		return BlazeLayout.render('layout', {
			main: 'account_settings'
		})
	}
})

Template.account_settings.onCreated(function() {
	return this.autorun(function() {
		return Meteor.subscribe('my_profile', FlowRouter.getParam('user_id'))
	})
})

Template.account_settings.events({
	'click #change_username': function() {
		var new_username, user
		new_username = $('#new_username').val().trim()
		user = Meteor.user()
		if (new_username && user.username !== new_username) {
			return Meteor.call('update_username', new_username, function(error, result) {
				if (error) {
					Bert.alert("Error Updating Username: " + error.reason, 'danger', 'growl-top-right')
				} else {
					Bert.alert(result, 'success', 'growl-top-right')
				}
			})
		}
	},
	'keydown #new_username': (e, t)=> {
		var new_username, user
		if (e.which === 13) {
			new_username = $('#new_username').val().trim()
			user = Meteor.user()
			if (new_username && user.username !== new_username) {
				return Meteor.call('update_username', new_username, function(error, result) {
					if (error) {
						Bert.alert("Error Updating Username: " + error.reason, 'danger', 'growl-top-right')
					} else {
						Bert.alert(result, 'success', 'growl-top-right')
					}
				})
			}
		}
	},
	'click #test_email': ()=> {
		return Meteor.call('sendEmail', {
			to: 'repjackson@gmail.com',
			from: 'no-reply@where-ever.com',
			subject: 'I really like sending emails with Mailgun!',
			text: 'Mailgun is totally awesome for sending emails!',
			html: 'With meteor it&aposs easy to set up <strong>HTML</strong> <span style="color:red">emails</span> too.'
		})
	},
	'click #add_email': ()=> {
		var new_email, re, user, valid_email
		new_email = $('#new_email').val().trim()
		user = Meteor.user()
		re = /^(([^<>()\[\]\\.,:\s@"]+(\.[^<>()\[\]\\.,:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		valid_email = re.test(new_email)
		if (valid_email) {
			return Meteor.call('update_email', new_email, function(error, result) {
				if (error) {
					Bert.alert("Error Adding Email: " + error.reason, 'danger', 'growl-top-right')
				} else {
					Bert.alert(result, 'success', 'growl-top-right')
				}
			})
		}
	},
	'click .send_verification_email': (e, t)=> {
		return Meteor.call('verify_email', Meteor.userId(), function() {
			return Bert.alert('Verification Email Sent', 'success', 'growl-top-right')
		})
	}
})

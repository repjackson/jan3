var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

FlowRouter.route('/incidents', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'incidents'
    });
  }
});

FlowRouter.route('/customer_incidents', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'customer_incidents'
    });
  }
});

Template.incident_view.onCreated(function() {
  return this.autorun(function() {
    return Meteor.subscribe('incident', FlowRouter.getParam('doc_id'));
  });
});

Template.add_incident_button.events({
  'click #add_incident': function() {
    var my_customer_ob, new_incident_id;
    my_customer_ob = Meteor.user().users_customer();
    console.log(my_customer_ob);
    if (my_customer_ob) {
      new_incident_id = Docs.insert({
        type: 'incident',
        customer_jpid: my_customer_ob.ev.ID,
        customer_name: my_customer_ob.ev.CUST_NAME,
        incident_office_name: my_customer_ob.ev.MASTER_LICENSEE,
        incident_franchisee: my_customer_ob.ev.FRANCHISEE,
        level: 1,
        open: true,
        submitted: false
      });
      return FlowRouter.go("/view/" + new_incident_id);
    }
  }
});

Template.incident_view.onRendered(function() {});

Template.incident_type_label.helpers({
  incident_type_label: function() {
    switch (this.incident_type) {
      case 'missed_service':
        return 'Missed Service';
      case 'team_member_infraction':
        return 'Team Member Infraction';
      case 'change_service':
        return 'Request a Change of Service';
      case 'problem':
        return 'Report a Problem or Service Issue';
      case 'special_request':
        return 'Request a Special Service';
      case 'other':
        return 'Other';
    }
  },
  type_label_class: function() {
    switch (this.incident_type) {
      case 'missed_service':
        return 'basic';
      case 'poor_service':
        return 'basic';
      case 'employee_issue':
        return 'basic';
      case 'other':
        return 'grey';
    }
  }
});

Template.incidents.helpers({
  settings: function() {
    return {
      collection: 'incidents',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'customer_name',
          label: 'Customer'
        }, {
          key: 'incident_office_name',
          label: 'Office'
        }, {
          key: '',
          label: 'Type',
          tmpl: Template.incident_type_label
        }, {
          key: 'timestamp',
          label: 'Logged',
          tmpl: Template.when_template,
          sortOrder: 1,
          sortDirection: 'descending'
        }, {
          key: 'last_updated_datetime',
          label: 'Updated',
          tmpl: Template.last_updated_template,
          sortOrder: 0,
          sortDirection: 'descending'
        }, {
          key: 'status',
          label: 'Status',
          tmpl: Template.status_template
        }, {
          key: 'status',
          label: 'Submitted',
          tmpl: Template.submitted_template
        }, {
          key: 'incident_details',
          label: 'Details'
        }, {
          key: 'level',
          label: 'Level'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    };
  }
});

Template.customer_incidents.onCreated(function() {
  return this.autorun(function() {
    return Meteor.subscribe('my_customer_incidents');
  });
});

Template.customer_incidents.helpers({
  customer_incidents: function() {
    return Docs.find({
      type: 'incident'
    });
  },
  settings: function() {
    return {
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'customer_name',
          label: 'Customer'
        }, {
          key: 'incident_office_name',
          label: 'Office'
        }, {
          key: '',
          label: 'Type',
          tmpl: Template.incident_type_label
        }, {
          key: 'when',
          label: 'Logged'
        }, {
          key: 'incident_details',
          label: 'Details'
        }, {
          key: 'level',
          label: 'Level'
        }, {
          key: 'status',
          label: 'Status',
          tmpl: Template.status_template
        }, {
          key: 'status',
          label: 'Submitted',
          tmpl: Template.submitted_template
        }, {
          key: '',
          label: 'Assigned To',
          tmpl: Template.associated_users
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    };
  }
});

Template.incident_view.onCreated(function() {
  this.autorun(function() {
    return Meteor.subscribe('type', 'incident_type');
  });
  this.autorun(function() {
    return Meteor.subscribe('type', 'rule');
  });
  return this.autorun(function() {
    return Meteor.subscribe('my_office_contacts');
  });
});

Template.incident_view.helpers({
  incident_type_docs: function() {
    return Docs.find({
      type: 'incident_type'
    });
  },
  can_submit: function() {
    var is_customer, user;
    user = Meteor.user();
    is_customer = user && user.roles && indexOf.call(user.roles, 'customer') >= 0;
    return this.service_date && this.incident_details && this.incident_type && is_customer && !this.submitted;
  },
  can_edit_core: function() {
    var doc_id, incident, user;
    user = Meteor.user();
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (user && user.roles && indexOf.call(user.roles, 'customer') >= 0) {
      if (incident.submitted === true) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
});

Template.incident_view.events({
  'click .submit': function() {
    var doc_id, escalation_minutes, incident, incidents_office;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    incidents_office = Docs.findOne({
      "ev.MASTER_LICENSEE": incident.incident_office_name,
      type: 'office'
    });
    if (incidents_office) {
      escalation_minutes = incidents_office.escalation_1_hours;
      console.log(incidents_office.escalation_1_hours);
      Meteor.call('create_event', doc_id, 'submit', "submitted incident.  It will escalate in " + escalation_minutes + " minutes according to " + incident.incident_office_name + " rules.");
      Meteor.call('create_event', doc_id, 'submit', "Incident submitted. " + incidents_office.initial_primary_contact + " and " + incidents_office.initial_secondary_contact + " have been notified per " + incident.incident_office_name + " rules.");
    }
    Docs.update(doc_id, {
      $set: {
        submitted: true,
        submitted_datetime: Date.now(),
        last_updated_datetime: Date.now()
      }
    });
    return Meteor.call('create_event', doc_id, 'submit', "submitted the incident.");
  },
  'click .unsubmit': function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    Docs.update(doc_id, {
      $set: {
        submitted: false,
        submitted_datetime: null,
        updated: Date.now()
      }
    });
    return Meteor.call('create_event', doc_id, 'unsubmit', "unsubmitted the incident.");
  },
  'click .close_incident': function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    return $('.ui.confirm_close.modal').modal({
      inverted: false,
      duration: 400,
      onApprove: function() {
        console.log('update', Date.now());
        Docs.update(doc_id, {
          $set: {
            open: false,
            updated: Date.now(),
            closed_datetime: Date.now()
          }
        });
        return Meteor.call('create_event', doc_id, 'close', "closed the incident.");
      }
    }).modal('show');
  },
  'click .reopen_incident': function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (confirm('Reopen incident?')) {
      Docs.update(doc_id, {
        $set: {
          open: true,
          updated: Date.now()
        }
      });
      return Meteor.call('create_event', doc_id, 'open', "reopened the incident.");
    }
  },
  'click #run_single_escalation_check': function() {
    return Meteor.call('single_escalation_check', FlowRouter.getParam('doc_id', function(err, res) {
      if (err) {
        console.dir(err);
        return Bert.alert(err.reason + ".", 'info', 'growl-top-right');
      } else {
        return Bert.alert(res + ".", 'success', 'growl-top-right');
      }
    }));
  },
  'click .remove_incident': function() {
    return swal({
      title: "Remove Incident?",
      type: 'info',
      animation: false,
      showCancelButton: true,
      closeOnConfirm: true,
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Remove',
      confirmButtonColor: '#da5347'
    }, (function(_this) {
      return function() {
        var doc_id;
        doc_id = FlowRouter.getParam('doc_id');
        Docs.remove(doc_id);
        return FlowRouter.go('/incidents');
      };
    })(this));
  }
});

Template.incident_sla_widget.helpers({
  sla_rule_docs: function() {
    return Docs.find({
      type: 'rule'
    }, {
      sort: {
        number: 1
      }
    });
  }
});

Template.sla_rule_doc.helpers({
  is_initial: function() {
    return this.number === 0;
  },
  can_escalate: function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    console.log(this.number);
    console.log(incident.level);
    console.log(incident.level === (this.number + 1));
    return incident.level === (this.number + 1);
  },
  is_level: function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (incident) {
      return incident.level === this.number;
    }
  },
  escalation_level_card_class: function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (incident) {
      if (incident.level === this.number) {
        return 'raised green';
      } else {
        return '';
      }
    }
  },
  incident_doc: function() {
    var doc_id, incident;
    doc_id = FlowRouter.getParam('doc_id');
    return incident = Docs.findOne(doc_id);
  },
  hours_value: function() {
    var customer_doc, doc_id, incident, incident_office;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (incident && incident.customer_jpid) {
      customer_doc = Docs.findOne({
        "ev.ID": incident.customer_jpid,
        type: 'customer'
      });
      if (customer_doc) {
        incident_office = Docs.findOne({
          "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE,
          type: 'office'
        });
        return incident_office["escalation_" + this.number + "_hours"];
      }
    }
  },
  franchisee_toggle_value: function() {
    var customer_doc, doc_id, incident, incident_office;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (incident && incident.customer_jpid) {
      customer_doc = Docs.findOne({
        "ev.ID": incident.customer_jpid,
        type: 'customer'
      });
      if (customer_doc) {
        incident_office = Docs.findOne({
          "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE,
          type: 'office'
        });
        return incident_office["escalation_" + this.number + "_contact_franchisee"];
      }
    }
  },
  primary_contact_value: function() {
    var customer_doc, doc_id, incident, incident_office;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (incident && incident.customer_jpid) {
      customer_doc = Docs.findOne({
        "ev.ID": incident.customer_jpid,
        type: 'customer'
      });
      if (customer_doc) {
        incident_office = Docs.findOne({
          "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE,
          type: 'office'
        });
        return incident_office["escalation_" + this.number + "_primary_contact"];
      }
    }
  },
  secondary_contact_value: function() {
    var customer_doc, doc_id, incident, incident_office;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    if (incident && incident.customer_jpid) {
      customer_doc = Docs.findOne({
        "ev.ID": incident.customer_jpid,
        type: 'customer'
      });
      if (customer_doc) {
        incident_office = Docs.findOne({
          "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE,
          type: 'office'
        });
        return incident_office["escalation_" + this.number + "_secondary_contact"];
      }
    }
  }
});

Template.sla_rule_doc.events({
  'click .set_level': function(e, t) {
    var doc_id, incident, office_doc, primary_contact_target, primary_contact_type, primary_username, secondary_contact_target, secondary_contact_type, secondary_username, sla;
    doc_id = FlowRouter.getParam('doc_id');
    incident = Docs.findOne(doc_id);
    office_doc = Meteor.user().users_customer().parent_franchisee().parent_office();
    primary_contact_type = office_doc.escalation_one_primary_contact;
    secondary_contact_type = office_doc.escalation_one_secondary_contact;
    if (primary_contact_type) {
      primary_contact_target = Meteor.users.findOne({
        username: office_doc["" + primary_contact_type]
      });
      primary_username = primary_contact_target && primary_contact_target.username ? primary_contact_target.username : '';
    }
    if (secondary_contact_type) {
      secondary_contact_target = Meteor.users.findOne({
        username: office_doc["" + secondary_contact_type]
      });
      secondary_username = secondary_contact_target && secondary_contact_target.username ? secondary_contact_target.username : '';
    }
    sla = this;
    Docs.update(doc_id, {
      $set: {
        level: sla.number
      }
    });
    Meteor.call('email_about_escalation', doc_id);
    return Meteor.call('create_event', doc_id, 'level_change', (Meteor.user().username) + " changed level to " + this.number);
  }
});

Template.full_doc_history.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('child_docs', FlowRouter.getParam('doc_id'));
    };
  })(this));
});

Template.incident_tasks.helpers({
  incident_tasks: function() {
    return Docs.find({
      type: 'incident_task',
      parent_id: FlowRouter.getParam('doc_id')
    });
  }
});

Template.incident_tasks.events({
  'click #add_incident_task': function() {
    var new_incident_task_id;
    new_incident_task_id = Docs.insert({
      type: 'incident_task',
      parent_id: FlowRouter.getParam('doc_id')
    });
    return FlowRouter.go("/edit/" + new_incident_task_id);
  }
});

Template.incident_task_edit.onCreated(function() {
  return this.autorun(function() {
    return Meteor.subscribe('type', 'action');
  });
});

Template.incident_task_edit.helpers({
  incident: function() {
    return Doc.findOne(FlowRouter.getParam('doc_id'));
  },
  action_docs: function() {
    return Docs.find({
      type: 'action'
    });
  }
});

// ---
// generated by coffee-script 1.9.2
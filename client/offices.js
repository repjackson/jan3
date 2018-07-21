FlowRouter.route('/offices', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'offices'
    });
  }
});

FlowRouter.route('/office/:doc_id/incidents', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'office_incidents'
    });
  }
});

FlowRouter.route('/office/:doc_id/employees', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'office_employees'
    });
  }
});

FlowRouter.route('/office/:doc_id/franchisees', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'office_franchisees'
    });
  }
});

FlowRouter.route('/office/:doc_id/customers', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'office_customers'
    });
  }
});

FlowRouter.route('/office/:doc_id/settings', {
  action: function() {
    return BlazeLayout.render('layout', {
      main: 'office_settings'
    });
  }
});

Template.offices.helpers({
  settings: function() {
    return {
      collection: 'offices',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      fields: [
        {
          key: 'ev.ID',
          label: 'JPID'
        }, {
          key: 'ev.MASTER_LICENSEE',
          label: 'Name'
        }, {
          key: 'ev.MASTER_OFFICE_MANAGER',
          label: 'Manager'
        }, {
          key: 'ev.MASTER_OFFICE_OWNER',
          label: 'Owner'
        }, {
          key: 'ev.ev.TELEPHONE',
          label: 'Phone'
        }, {
          key: 'ev.ADDR_STREET',
          label: 'Address'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    };
  }
});

Template.office_header.helpers({
  office_doc: function() {
    return Docs.findOne(FlowRouter.getParam('doc_id'));
  },
  office_map_address: function() {
    var encoded_address, page_office;
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    encoded_address = encodeURIComponent(page_office.ev.ADDR_STREET + " " + page_office.ev.ADDR_STREET_2 + " " + page_office.ev.ADDR_CITY + "," + page_office.ev.ADDR_STATE + " " + page_office.ev.ADDR_POSTAL_CODE + " " + page_office.ev.MASTER_COUNTRY);
    return "https://www.google.com/maps/search/?api=1&query=" + encoded_address;
  }
});

Template.office_header.onCreated(function() {
  return this.autorun(function() {
    return Meteor.subscribe('doc', FlowRouter.getParam('doc_id'));
  });
});

Template.office_settings.onCreated(function() {
  this.autorun(function() {
    return Meteor.subscribe('type', 'rule');
  });
  this.autorun(function() {
    return Meteor.subscribe('office_employees', FlowRouter.getParam('doc_id'));
  });
  return this.autorun(function() {
    return Meteor.subscribe('doc', FlowRouter.getParam('doc_id'));
  });
});

Template.office_settings.helpers({
  current_office: function() {
    var page_office;
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    return page_office;
  },
  is_initial: function() {
    return this.number === 0;
  },
  rule_docs: function() {
    return Docs.find({
      type: 'rule'
    }, {
      sort: {
        number: 1
      }
    });
  },
  hours_key: function() {
    return "escalation_" + this.number + "_hours";
  },
  franchisee_toggle_key: function() {
    return "escalation_" + this.number + "_contact_franchisee";
  },
  primary_contact_key: function() {
    console.log("escalation_" + this.number + "_primary_contact");
    return "escalation_" + this.number + "_primary_contact";
  },
  secondary_contact_key: function() {
    return "escalation_" + this.number + "_secondary_contact";
  },
  is_primary_indivdual: function() {
    var page_office, prim_ind;
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    prim_ind = page_office["escalation_" + this.number + "_primary_contact"];
    console.log(prim_ind);
    return prim_ind;
  },
  is_secondary_indivdual: function() {
    var page_office;
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    return page_office["escalation_" + this.number + "_secondary_contact"];
  }
});

Template.office_customers.onCreated(function() {
  var page_office;
  this.autorun(function() {
    return Meteor.subscribe('doc', FlowRouter.getParam('doc_id'));
  });
  if (this.subscriptionsReady()) {
    Template.filter = new ReactiveTable.Filter('office_customers', ["ev.MASTER_LICENSEE"]);
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    return ReactiveTable.Filter('office_customers').set(page_office.ev.MASTER_LICENSEE);
  }
});

Template.office_customers.helpers({
  settings: function() {
    return {
      collection: 'customers',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      showNavigation: 'auto',
      filters: ['office_customers'],
      fields: [
        {
          key: 'ev.CUST_NAME',
          label: 'Customer Name'
        }, {
          key: 'ev.ID',
          label: 'JPID'
        }, {
          key: 'ev.FRANCHISEE',
          label: 'Franchisee'
        }, {
          key: 'ev.MASTER_LICENSEE',
          label: 'Master Licensee'
        }, {
          key: 'ev.CUST_CONT_PERSON',
          label: 'Contact Person'
        }, {
          key: 'ev.CUST_CONTACT_EMAIL',
          label: 'Contact Email'
        }, {
          key: 'ev.TELEPHONE',
          label: 'Telephone'
        }, {
          key: 'ev.ADDR_STREET',
          label: 'Address'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    };
  }
});

Template.office_incidents.onCreated(function() {
  var page_office, user;
  this.autorun(function() {
    return Meteor.subscribe('doc', FlowRouter.getParam('doc_id'));
  });
  if (this.subscriptionsReady()) {
    Template.filter = new ReactiveTable.Filter('office_incidents', ["incident_office_name"]);
    user = Meteor.user();
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    if (page_office) {
      return ReactiveTable.Filter('office_incidents').set(page_office.ev.MASTER_LICENSEE);
    }
  }
});

Template.office_incidents.helpers({
  settings: function() {
    return {
      collection: 'incidents',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      showNavigation: 'auto',
      filters: ['office_incidents'],
      fields: [
        {
          key: 'incident_office_name',
          label: 'Office'
        }, {
          key: 'customer_name',
          label: 'Customer'
        }, {
          key: 'timestamp',
          label: 'Logged',
          tmpl: Template.when_template,
          sortOrder: 1,
          sortDirection: 'descending'
        }, {
          key: '',
          label: 'Type',
          tmpl: Template.incident_type_label
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

Template.office_employees.onCreated(function() {
  this.autorun(function() {
    return Meteor.subscribe('doc', FlowRouter.getParam('doc_id'));
  });
  return this.autorun(function() {
    return Meteor.subscribe('office_employees', FlowRouter.getParam('doc_id'));
  });
});

Template.office_employees.helpers({
  collection: function() {
    var page_office;
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    return Meteor.users.find({
      "profile.office_name": page_office.ev.MASTER_LICENSEE
    });
  },
  settings: function() {
    return {
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      showNavigation: 'auto',
      fields: [
        {
          key: 'username',
          label: 'Username'
        }, {
          key: 'profile.first_name',
          label: 'First Name'
        }, {
          key: 'profile.last_name',
          label: 'Last Name'
        }, {
          key: 'profile.title',
          label: 'Title'
        }, {
          key: 'ev.WORK_TELEPHONE',
          label: 'Work Tel'
        }, {
          key: 'email',
          label: 'Email'
        }, {
          key: '',
          label: 'Public',
          tmpl: Template.toggle_user_published
        }, {
          key: '',
          label: 'Edit',
          tmpl: Template.edit_user_button
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_user_button
        }
      ]
    };
  }
});

Template.office_franchisees.onCreated(function() {
  var page_office;
  this.autorun(function() {
    return Meteor.subscribe('doc', FlowRouter.getParam('doc_id'));
  });
  if (this.subscriptionsReady()) {
    Template.filter = new ReactiveTable.Filter('office_franchisees', ["ev.MASTER_LICENSEE"]);
    page_office = Docs.findOne(FlowRouter.getParam('doc_id'));
    if (page_office) {
      return ReactiveTable.Filter('office_franchisees').set(page_office.ev.MASTER_LICENSEE);
    }
  }
});

Template.office_franchisees.helpers({
  settings: function() {
    return {
      collection: 'franchisees',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
      filters: ['office_franchisees'],
      fields: [
        {
          key: 'ev.ID',
          label: 'JPID'
        }, {
          key: 'ev.FRANCHISEE',
          label: 'Name'
        }, {
          key: 'ev.FRANCH_EMAIL',
          label: 'Email'
        }, {
          key: 'ev.FRANCH_NAME',
          label: 'Short Name'
        }, {
          key: 'ev.TELE_CELL',
          label: 'Phone'
        }, {
          key: 'ev.MASTER_LICENSEE',
          label: 'Office'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    };
  }
});

// ---
// generated by coffee-script 1.9.2

Template.customers.helpers({
  settings: function() {
    return {
      collection: 'customers',
      rowsPerPage: 10,
      showFilter: true,
      showRowCount: true,
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
          key: 'ev.ACCOUNT_STATUS',
          label: 'Status'
        }, {
          key: '',
          label: 'View',
          tmpl: Template.view_button
        }
      ]
    };
  }
});

Template.customers.events({
  'click .sync_customers': function() {
    return Meteor.call('sync_customers', function(err, res) {
      if (err) {
        return console.error(err);
      }
    });
  }
});

Template.franchisee_customers.helpers({
  franchisee_customers_docs: function() {
    var page_doc;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    return Docs.find({
      type: "customer"
    });
  },
  settings: function() {
    return {
      rowsPerPage: 10,
      showFilter: false,
      showRowCount: false,
      showNavigation: 'auto',
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

Template.customers_franchisee.helpers({
  customers_franchisee_doc: function() {
    var found, page_doc;
    page_doc = Docs.findOne(FlowRouter.getParam('doc_id'));
    found = Docs.findOne({
      franchisee: page_doc.franchisee
    });
    console.log(found);
    return found;
  }
});

Template.my_customer_account_card.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('my_customer_account');
    };
  })(this));
});

Template.my_franchisee_card.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('my_franchisee');
    };
  })(this));
});

Template.my_office_card.onCreated(function() {
  return this.autorun((function(_this) {
    return function() {
      return Meteor.subscribe('my_office');
    };
  })(this));
});

// ---
// generated by coffee-script 1.9.2
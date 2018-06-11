import { $ } from 'meteor/jquery';
import Tabular from 'meteor/aldeed:tabular';
import { Template } from 'meteor/templating';
// import moment from 'moment';
import { Meteor } from 'meteor/meteor';

if (Meteor.isClient){
  import 'datatables.net-bs/css/dataTables.bootstrap.css';
  import dataTablesBootstrap from 'datatables.net-bs';
  import dataTableButtons from 'datatables.net-buttons-bs';
  import columnVisibilityButton from 'datatables.net-buttons/js/buttons.colVis.js';
  import html5ExportButtons from 'datatables.net-buttons/js/buttons.html5.js';
  import flashExportButtons from 'datatables.net-buttons/js/buttons.flash.js';
  import printButton from 'datatables.net-buttons/js/buttons.print.js';

  dataTablesBootstrap(window, $);
  dataTableButtons(window, $);
  columnVisibilityButton(window, $);
  html5ExportButtons(window, $);
  flashExportButtons(window, $);
  printButton(window, $);
}


new Tabular.Table({
  name: "Reports",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv', 'colvis'],
  columns: [
    {data: "report_id", title: "Id"},
    {data: "report_title", title: "Title"},
    {data: "report_type", title: "Type"},
    {data: "report_subtitle", title: "Subtitle"},
    // {
    //   data: "lastCheckedOut",
    //   title: "Last Checkout",
    //   render: function (val, type, doc) {
    //     if (val instanceof Date) {
    //       return moment(val).calendar();
    //     } else {
    //       return "Never";
    //     }
    //   }
    // },
    // {data: "summary", title: "Summary"},
    { tmpl: Meteor.isClient && Template.view_button }
  ]
});


new Tabular.Table({
  name: "Incidents",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'csv'],
  columns: [
    {data: "incident_number", title: "Ticket Number"},
    {data: "incident_type", title: "Type"},
    // {data: "when", title: "Logged"},
    {
      data: "timestamp",
      title: "Logged When",
      render: function (timestamp, type, doc) {
        return doc.when();
      }
    },     
    {
      data: "incident_details",
      title: "Details",
      render: function (incident_details, type, doc) {
        if (incident_details) {
          var snippet = incident_details.substr(0, 100) + "..."
          return snippet
        } else {
          return "";
        }
      }
    },
    { data: "current_level", title: "Level"},
    { 
      data: "assigned_to",
      title: "Assigned To",
      tmpl: Meteor.isClient && Template.associated_users 
    },
    { 
      data: "", 
      title: "Actions Taken",
      tmpl: Meteor.isClient && Template.small_doc_history 
    },
    { tmpl: Meteor.isClient && Template.view_button }
  ]
});

new Tabular.Table({
  name: "Fields",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv', 'colvis'],
  columns: [
    {data: "field_slug", title: "Slug"},
    {data: "field_display_name", title: "Display Name"},
    {data: "field_display_type", title: "Display Type"},
  ]
});

new Tabular.Table({
  name: "Users",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "user_id", title: "User Id"},
    {data: "user_first_name", title: "First Name"},
    {data: "user_last_name", title: "Last Type"},
    {data: "ev.FRANCHISEE", title: "Franchisee"},
    {data: "ev.ASSIGNED_TO", title: "Assigned To"},
    {data: "ev.SHORT_NAME", title: "Short Name"},
    {data: "ev.MASTER_LICENSEE", title: "Master"},
    { tmpl: Meteor.isClient && Template.view_button }

  ]
});


new Tabular.Table({
  name: "Jpids",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv', 'colvis'],
  columns: [
    {data: "jpid", title: "JP Id"},
    {data: "ev.CUSTOMER", title: "Customer"},
    {data: "ev.FRANCHISEE", title: "Franchisee"},
    {data: "ev.ASSIGNED_TO", title: "Assigned To"},
    {data: "ev.MASTER_LICENSEE", title: "Master"},
    {data: "ev.ACCOUNT_STATUS", title: "Status"},
    {data: "ev.AREA", title: "Area"},
    { tmpl: Meteor.isClient && Template.view_button }

  ]
});



new Tabular.Table({
  name: "Areas",
  collection: Docs,
  // lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "number", title: "Number"},
    {data: "title", title: "Name"},
  ]
});



new Tabular.Table({
  name: "Ev_roles",
  collection: Docs,
  // lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "slug", title: "Slug"},
    {data: "title", title: "Name"},
  ]
});

new Tabular.Table({
  name: "Meta",
  collection: Docs,
  // lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "area", title: "Field Name"},
    {data: "jpid", title: "MetaData Name"},
    {data: "value", title: "MetaData Title"},
    // { tmpl: Meteor.isClient && Template.view_button }
  ]
});


new Tabular.Table({
  name: "Franchisees",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "jpid", title: "JP ID"},
    {data: "franchisee", title: "Franchisee"},
    {data: "franchisee_email", title: "Email"},
    { tmpl: Meteor.isClient && Template.view_button }
  ]
});


new Tabular.Table({
  name: "Related_franchisees",
  collection: Docs,
  // lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  // pageLength: 50,
  paging: false,
  searching: false,
  // buttonContainer: '.col-sm-6:eq(0)',
  // buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "jpid", title: "JP ID"},
    {data: "franchisee", title: "Franchisee"},
    {data: "franchisee_email", title: "Email"},
    { tmpl: Meteor.isClient && Template.view_button }
  ]
});


new Tabular.Table({
  name: "Customers",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  pageLength: 50,
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "jpid", title: "JP ID"},
    {data: "franchisee", title: "Franchisee"},
    {data: "cust_name", title: "Customer Name"},
    {data: "master_licensee", title: "Master Licensee"},
    {data: "customer_contact_person", title: "Customer Contact Person"},
    {data: "customer_contact_email", title: "Customer Contact Email"},
    { tmpl: Meteor.isClient && Template.view_button }
  ]
});

new Tabular.Table({
  name: "Related_customers",
  collection: Docs,
  paging: false,
  searching: false,
  // lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  // pageLength: 100,
  // buttonContainer: '.col-sm-6:eq(0)',
  // buttons: ['copy', 'excel', 'pdf', 'csv'],
  columns: [
    {data: "jpid", title: "JP ID"},
    {data: "franchisee", title: "Franchisee"},
    {data: "cust_name", title: "Customer Name"},
    {data: "master_licensee", title: "Master Licensee"},
    {data: "customer_contact_person", title: "Contact Person"},
    {data: "customer_contact_email", title: "Contact Email"},
    { tmpl: Meteor.isClient && Template.view_button }
  ]
});

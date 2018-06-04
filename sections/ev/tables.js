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
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv', 'colvis'],
  columns: [
    {data: "incident_number", title: "Ticket Number"},
    {data: "incident_type", title: "Type"},
    {data: "when", title: "Logged"},
    {data: "current_level", title: "Level"},
  ]
});

new Tabular.Table({
  name: "Fields",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
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
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv', 'colvis'],
  columns: [
    {data: "user_id", title: "User Id"},
    {data: "user_first_name", title: "First Name"},
    {data: "user_last_name", title: "Last Type"},
    { tmpl: Meteor.isClient && Template.view_button }

  ]
});


new Tabular.Table({
  name: "Jpids",
  collection: Docs,
  lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ],
  buttonContainer: '.col-sm-6:eq(0)',
  buttons: ['copy', 'excel', 'pdf', 'csv', 'colvis'],
  columns: [
    {data: "jpid", title: "JP Id"},
    {data: "ev.CUSTOMER", title: "Customer"},
    {data: "ev.FRANCHISEE", title: "Franchisee"},
    {data: "ev.ASSIGNED_TO", title: "Assigned To"},
    { tmpl: Meteor.isClient && Template.view_button }

  ]
});



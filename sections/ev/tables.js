import { $ } from 'meteor/jquery';
import Tabular from 'meteor/aldeed:tabular';
import { Template } from 'meteor/templating';
// import moment from 'moment';
import { Meteor } from 'meteor/meteor';

if (Meteor.isClient){
  import 'datatables.net-bs/css/dataTables.bootstrap.css';
  import dataTablesBootstrap from 'datatables.net-bs';
  dataTablesBootstrap(window, $);
}


new Tabular.Table({
  name: "Reports",
  collection: Docs,
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
    // {
    //   tmpl: Meteor.isClient && Template.bookCheckOutCell
    // }
  ]
});


new Tabular.Table({
  name: "Incidents",
  collection: Docs,
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
  columns: [
    {data: "field_slug", title: "Slug"},
    {data: "field_display_name", title: "Display Name"},
    {data: "field_display_type", title: "Display Type"},
  ]
});



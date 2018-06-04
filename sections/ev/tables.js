import Tabular from 'meteor/aldeed:tabular';
import { Template } from 'meteor/templating';
// import moment from 'moment';
import { Meteor } from 'meteor/meteor';
// import { Books } from './collections/Books';

new Tabular.Table({
  name: "Reports",
  collection: Docs,
  columns: [
    {data: "title", title: "Title"},
    {data: "author", title: "Author"},
    {data: "copies", title: "Copies Available"},
    {
      data: "lastCheckedOut",
      title: "Last Checkout",
      render: function (val, type, doc) {
        if (val instanceof Date) {
          return moment(val).calendar();
        } else {
          return "Never";
        }
      }
    },
    {data: "summary", title: "Summary"},
    {
      tmpl: Meteor.isClient && Template.bookCheckOutCell
    }
  ]
});

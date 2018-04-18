import SimpleSchema from 'simpl-schema';

SimpleSchema.extendOptions(['autoform']);

Incidents = new Meteor.Collection('incidents');

Incidents.attachSchema(new SimpleSchema({
  title: {
    type: String
  },
  type: {
    type: String
  },
  number: {
    type: Number,
    label: 'Incident Number',
    min: 0
  }
}));

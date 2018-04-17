// # Meteor.users.helpers
// #     name: -> 
// #         if @profile.first_name and @profile.last_name
// #             "#{@profile.first_name}  #{@profile.last_name}"

Incidents = new orion.collection('incidents', {
  singularName: 'incident', // The name of one of these items
  pluralName: 'incidents', // The name of more than one of these items
  title: 'Incidents', // The title in the index of the collection
  link: {
    /**
     * The text that you want to show in the sidebar.
     * The default value is the name of the collection, so
     * in this case it is not necessary.
     */
    title: 'Incidents'
  },
  /**
   * Tabular settings for this collection
   */
  tabular: {
    columns: [
      { data: "title", title: "Title" },
      { data: "type", title: "Type" },
      /**
       * If you want to show a custom orion attribute in
       * the index table you must call this function
       * orion.attributeColumn(attributeType, key, label, options)
       */
      orion.attributeColumn('file', 'image', 'Image'),
      orion.attributeColumn('froala', 'body', 'Content', { orderable: true }), // makes it searchable
      // orion.attributeColumn('test_text', 'body', 'test Text', { orderable: true }), // makes it searchable
      orion.attributeColumn('createdBy', 'createdBy', 'Created By')
    ]
  }
});
/**
 * Now we will attach the schema for that collection.
 * Orion will automatically create the corresponding form.
 */
Incidents.attachSchema(new SimpleSchema({
  title: {
    type: String
  },
  type: {
    type: String
  },
  number: {
    type: Number,
    min: 0
  },
  adminId: orion.attribute('user', {
    label: 'Admin',
    optional: true
    }, {
      publicationName: 'anyUniqueStringHere',
      additionalFields: ['roles'],
      filter: function() {
        return { roles: { $in: ['admin', 'editor'] } }
      }
  }),
  /**
   * The file attribute is a custom orion attribute
   * This is where orion does its magic. Just set
   * the attribute type and it will automatically
   * create the form for the file.
   * WARNING: the url of the image will not be saved in
   * .image, it will be saved in .image.url.
   */
  image: orion.attribute('file', {
      label: 'Image',
      optional: true
  }),
  /**
   * Here it's the same with an image attribute.
   * summernote is an html editor.
   */
  body: orion.attribute('froala', {
      label: 'Body'
  }),
  // body: orion.attribute('test_text', {
  //     label: 'test Text'
  // }),
  /**
   * This attribute sets the user id to that of the user that created
   * this post automatically.
   */
  createdBy: orion.attribute('createdBy')
}));




Comments = new orion.collection('comments', {
  singularName: 'comment',
  pluralName: 'comments',
  title: 'Comments',
  link: {
    title: 'Comments',
    index: 100,
    parent: 'incidents' // to show it under the posts collection link
  },
  tabular: {
    columns: [
      { data: 'message', title: 'Message' }
    ]
  }
});

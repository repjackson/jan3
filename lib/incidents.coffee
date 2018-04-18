# # Meteor.users.helpers
# #     name: -> 
# #         if @profile.first_name and @profile.last_name
# #             "#{@profile.first_name}  #{@profile.last_name}"
@Incidents = new (orion.collection)('incidents',
    singularName: 'incident'
    pluralName: 'incidents'
    title: 'Incident Records'
    link: title: 'Incidents'
    tabular: columns: [
        {
            data: 'title'
            title: 'Title'
        }
        {
            data: 'type'
            title: 'Type'
        }
        {
            data: 'number'
            title: 'Number'
        }
        orion.attributeColumn('file', 'image', 'Image')
        orion.attributeColumn('froala', 'body', 'Content', orderable: true)
        orion.attributeColumn('createdBy', 'createdBy', 'Created By')
    ])

###*
# Now we will attach the schema for that collection.
# Orion will automatically create the corresponding form.
###

Incidents.attachSchema new SimpleSchema(
    title: type: String
    type: type: String
    number:
        type: Number
        label: 'Incident Number'
        min: 0
    adminId: orion.attribute('user', {
        label: 'Admin'
        optional: true
    },
        publicationName: 'anyUniqueStringHere'
        additionalFields: [ 'roles' ]
        filter: ->
            { roles: $in: [
                'admin'
                'editor'
            ] }
    )
    image: orion.attribute('file',
        label: 'Image'
        optional: true)
    body: orion.attribute('froala', label: 'Body')
    createdBy: orion.attribute('createdBy'))
Comments = new (orion.collection)('comments',
    singularName: 'comment'
    pluralName: 'comments'
    title: 'Comments'
    link:
        title: 'Comments'
        index: 100
        parent: 'incidents'
    tabular: columns: [ {
        data: 'message'
        title: 'Message'
    } ])

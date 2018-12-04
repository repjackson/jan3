@Docs = new Meteor.Collection 'docs'

Meteor.methods
    add_facet_filter: (delta_id, key, filter)->
        if key is 'keys'
            Docs.update { _id:delta_id},
                $addToSet: facets: key:filter
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter
        Meteor.call 'fo', (err,res)->
            
            
    remove_facet_filter: (delta_id, key, filter)->
        if key is 'keys'
            Docs.update { _id:delta_id},
                $pull:facets: key:filter
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fo', (err,res)->
            
            
            
            
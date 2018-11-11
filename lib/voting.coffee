Meteor.methods
    upvote: (id)->
        doc = Docs.findOne id
        if not doc.upvoter_ids
            Docs.update id,
                $set:
                    upvoter_ids: []
                    downvoter_ids: []
        else if Meteor.userId() in doc.upvoter_ids #undo upvote
            Docs.update id,
                $pull: upvoter_ids: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.author_id, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.downvoter_ids #switch downvote to upvote
            Docs.update id,
                $pull: downvoter_ids: Meteor.userId()
                $addToSet: upvoter_ids: Meteor.userId()
                $inc: points: 2
            # Meteor.users.update doc.author_id, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: upvoter_ids: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.author_id, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: -1
        # Meteor.call 'generate_upvoted_cloud', Meteor.userId()

    downvote: (id)->
        doc = Docs.findOne id
        if not doc.downvoter_ids
            Docs.update id,
                $set:
                    upvoter_ids: []
                    downvoter_ids: []
        else if Meteor.userId() in doc.downvoter_ids #undo downvote
            Docs.update id,
                $pull: downvoter_ids: Meteor.userId()
                $inc: points: 1
            # Meteor.users.update doc.author_id, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.upvoter_ids #switch upvote to downvote
            Docs.update id,
                $pull: upvoter_ids: Meteor.userId()
                $addToSet: downvoter_ids: Meteor.userId()
                $inc: points: -2
            # Meteor.users.update doc.author_id, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: downvoter_ids: Meteor.userId()
                $inc: points: -1
            # Meteor.users.update doc.author_id, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: -1
        # Meteor.call 'generate_downvoted_cloud', Meteor.userId()

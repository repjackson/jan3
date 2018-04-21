VisualRecognitionV3 = require('watson-developer-cloud/visual-recognition/v3');
NaturalLanguageUnderstandingV1 = require('watson-developer-cloud/natural-language-understanding/v1.js')


natural_language_understanding = new NaturalLanguageUnderstandingV1(
    'username': Meteor.settings.private.language.username
    'password': Meteor.settings.private.language.password
    'version_date': '2017-02-27')



visualRecognition = new VisualRecognitionV3({
    version:'2018-03-19'
    api_key: Meteor.settings.private.visual.api_key
})








Meteor.methods
    call_visual: ()->
        params =
            url:"https://res.cloudinary.com/facet/image/upload/c_fit,h_500/u53x8dwhcmldja82vjni"
            # images_file: images_file
            # classifier_ids: classifier_ids
        visualRecognition.classify(params, (err, response)->
            if (err)
                console.log(err);
            else
                console.log(JSON.stringify(response, null, 2))
        )
        
    call_watson: (parameters, doc_id) ->
        natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response) ->
            if err
                console.log 'error:', err
            else
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (tag)-> tag.toLowerCase()
                # console.dir response
                Docs.update { _id: doc_id }, 
                    $set:
                        watson: response
                        watson_keywords: lowered_keywords
                        doc_sentiment_score: response.sentiment.document.score
                        doc_sentiment_label: response.sentiment.document.label
            return
        )
        
        # Meteor.call 'create_transaction', 'tk5W7DukuCZjB7262', doc_id
        
        return
        
        

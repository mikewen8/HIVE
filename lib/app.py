from flask import Flask, jsonify
from flask_cors import CORS
import boto3
from botocore.exceptions import BotoCoreError, ClientError

app = Flask(__name__)
CORS(app)  # Allow all origins

logged_user=0

dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id='AKIATQPTFUEWDLBTCJET',
    aws_secret_access_key='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',
    region_name='us-east-1'
)
def get_userID():
    return 2

def user_events():
    #if(logged_user==user_events)
    #search aws db through python to get the id list
    return " "   


def search_events():
    # use this to find the event ids 

    return " "

# need to have a script to upload the fetch data over time

@app.route('/events', methods=['GET'])
def get_events():
    table = dynamodb.Table('events')
    try:
        response = table.scan()
        events = response.get('items', []) 

        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            events.extend(response.get('Items', []))

        return jsonify(events)  
    except (BotoCoreError, ClientError) as error:
        print(f"Error fetching events: {error}")
        return jsonify({'error': str(error)}), 500  

"""
@app.route('/tylers_boyfriend',methods=['GET'])
def get_results():
    # this will be where the call from tylers api call goes 
    return "lol"
"""

# ----------------------------------
#maybe create a route for the user to make a post call for example 
# need to create a get and post call need to assign a user and a login page for the user
# we need ot use this so in the data base we can display the users current events
# then we also need a delete event from data base route 

















#-------------------------------------

if __name__ == "__main__":
    app.run(debug=True)

from flask import Flask, jsonify
from flask_cors import CORS
import boto3
from botocore.exceptions import BotoCoreError, ClientError
import os
aws_access_key = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_key = os.getenv('AWS_SECRET_ACCESS_KEY')


app = Flask(__name__)
CORS(app)  # Allow all origins

logged_user=0



table = dynamodb.Table('events')

# need to have a script to upload the fetch data over time
@app.route('/', methods=['GET'])



@app.route('/events', methods=['GET'])
def get_events():
     try:
         response = table.scan()
         events = response.get('Items', [])  

         # Handle pagination
         while 'LastEvaluatedKey' in response:
             response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
             events.extend(response.get('Items', []))
         # Properly serialize and return the events
         return jsonify({"events":events})
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
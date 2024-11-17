from flask import Flask, jsonify, request
import json
from flask_cors import CORS
import boto3
from botocore.exceptions import BotoCoreError, ClientError
import os 
from dotenv import load_dotenv
from ticketmaster_client import TicketmasterClient

load_dotenv()


aws_access_key = os.environ.get('AWS_ACCESS_KEY_ID')
aws_secret_key = os.environ.get('AWS_SECRET_ACCESS_KEY')

tkm = TicketmasterClient()

app = Flask(__name__)
CORS(app)  # Allow all origins

logged_user=0
dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id=aws_access_key,
    aws_secret_access_key=aws_secret_key,
    region_name='us-west-2'
)


table = dynamodb.Table('events')

""""
# need to have a script to upload the fetch data over time
@app.route('/', methods=['GET','POST'])
def test2():
    try:
        # Parse JSON data from the request body
        data = request.get_json()

        # Extract event description from the request body
        query = "find me seahawks games"

        if not query:
            return jsonify({'error': 'Description is required'}), 400    
        doom = table.scan()
        pray = doom.get('Items', [])

        while 'LastEvaluatedKey' in doom:
             doom = table.scan(ExclusiveStartKey=doom['LastEvaluatedKey'])
             pray.extend(doom.get('Items', []))
        prayer={'events':pray}
        similar_events = tkm.similar_events(json.dumps(prayer),query)
        # Send a success response
        return json.dumps(similar_events)

    except Exception as e:
        # Handle unexpected errors
        print(f"Error: {e}")
        return jsonify({'error': 'An error occurred'}), 500
"""

@app.route('/send', methods=['POST','GET'])
def get_string():
    try:
        # Parse JSON data from the request body
        data = request.get_json()

        # Extract event description from the request body
        query = data.get('query')

        if not query:
            return jsonify({'error': 'Description is required'}), 400

        #print(f"Received event description: {query}")
    
        doom = table.scan()
        pray = doom.get('Items', [])

        while 'LastEvaluatedKey' in doom:
             doom = table.scan(ExclusiveStartKey=doom['LastEvaluatedKey'])
             pray.extend(doom.get('Items', []))
        prayer={'events':pray}
        #sending = tkm.similar_events(json.dumps(prayer),query)
        # Send a success response
        #sending.replace('\\','')
        sending = tkm.similar_events(json.dumps(prayer),query)
        #print(sending)
        return sending

    except Exception as e:
        # Handle unexpected errors
        print(f"Error: {e}")
        return jsonify({'error': 'An error occurred'}), 500


from flask import request, jsonify

@app.route('/', methods=['GET', 'POST'])


# API: Signup
@app.route('/api/signup', methods=['POST'])
def signup():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    table.put_item(
        Item={
            'name': name,
            'email': email,
            'password': password
        }
    )
    return jsonify({'message': 'Registration successful!'}), 201

# API: Login
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    response = table.query(
        KeyConditionExpression=Key('email').eq(email)
    )
    items = response['Items']

    if not items:
        return jsonify({'error': 'User not found'}), 404

    user = items[0]
    if password == user['password']:
        session['user_id'] = user['email']  # Store email in session
        return jsonify({'message': 'Login successful!', 'name': user['name']}), 200
    else:
        return jsonify({'error': 'Invalid password'}), 401


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
     
@app.route('/add_event', methods=['POST'])
def add_event():
    
    #user_id = logged_user  

    data = request.get_json()

    #getting from front end
    event_id = data.get('event_id')
    name = data.get('name')
    type = data.get('type')
    genre = data.get('genre')
    venue = data.get('venue')
    address = data.get('address')
    date = data.get('date')
    time = data.get('time')
    location = data.get('location')
    link = data.get('link')
    description = data.get('description')


    if event_id is None or name is None or type is None or genre is None or venue is None or address is None or date is None or time is None or location is None or link is None or description is None:
        return redirect("/index?err_msg= bad_med_input")
    
    new_event = {
        "event_id": event_id,
        "name": name,
        "type": type,
        "genre": genre,
        "venue": venue,
        "address": address, 
        "date": date,
        "time": time,
        "location": location,
        "link": link,
        "description": description
    }

    table.put_item(Item=new_event)
    #print(f"Uploaded event: {new_event['name']}")
    return jsonify({"message": f"Event '{new_event['name']}' added successfully"}), 201


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
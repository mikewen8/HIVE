from flask import Flask, jsonify, request
from flask_jwt_extended import (
    JWTManager, create_access_token, create_refresh_token,
    jwt_required, get_jwt_identity
)
from flask_cors import CORS
import boto3
from botocore.exceptions import BotoCoreError, ClientError
import os
from werkzeug.security import generate_password_hash, check_password_hash
from boto3.dynamodb.conditions import Attr
import json
from ticketmaster_client import TicketmasterClient

# DynamoDB setup
dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id='AKIAXYTMT4YTHEOLYSAO',
    aws_secret_access_key='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',
    region_name='us-west-2'
)

tkm = TicketmasterClient()

users = dynamodb.Table('users')
table = dynamodb.Table('events')

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'fallback_secure_key')
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'fallback_jwt_secret')
CORS(app, supports_credentials=True, resources={r"/*": {
    "origins": "*",
    "methods": ["GET", "POST", "DELETE", "OPTIONS"],
    "allow_headers": ["Authorization", "Content-Type"]
}})
jwt = JWTManager(app)

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



@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Username and password are required'}), 400

    response = users.scan(
        FilterExpression=Attr('username').eq(username)
    )
    if response['Items']:
        return jsonify({'error': 'User already exists'}), 400

    hashed_password = generate_password_hash(password)
    users.put_item(
        Item={
            "username": username,  # Set username as primary key
            "password": hashed_password,
            "events": []  # Initialize with an empty events list
        }
    )

    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Username and password are required'}), 400

    response = users.scan(
        FilterExpression=Attr('username').eq(username)
    )
    if not response.get('Items', []):  # No matching users
        return jsonify({'error': 'Invalid username or password'}), 400

    user_data = response['Items'][0]
    if not check_password_hash(user_data.get('password', ''), password):
        return jsonify({'error': 'Invalid username or password'}), 400

    # Use the username as the identity for the JWT
    access_token = create_access_token(identity=user_data['username'])
    refresh_token = create_refresh_token(identity=user_data['username'])

    return jsonify({
        'message': 'Login successful',
        'access_token': access_token,
        'refresh_token': refresh_token
    }), 200

@app.route('/events', methods=['GET'])
@jwt_required()
def get_events():
    try:
        response = table.scan()
        events = response.get('Items', [])

        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            events.extend(response.get('Items', []))

        return jsonify({"events": events})
    except (BotoCoreError, ClientError) as error:
        print(f"Error fetching events: {error}")
        return jsonify({'error': str(error)}), 500

@app.route('/add_event', methods=['POST'])
@jwt_required()
def add_event():
    try:
        # Log the authenticated username
        username = get_jwt_identity()
        print(f"Authenticated Username: {username}")

        data = request.get_json()
        print(f"Received Data: {data}")

        # Query the user
        response = users.get_item(Key={'username': username})
        print(f"DynamoDB Response: {response}")

        if 'Item' not in response:
            return jsonify({"error": "User not found"}), 404

        # Add the event
        user_data = response['Item']
        user_events = user_data.get('events', [])
        user_events.append({
            'event_id': data['event_id'],
            'name': data['name'],
            'type': data['type'],
            'genre': data['genre'],
            'venue': data['venue'],
            'address': data['address'],
            'date': data['date'],
            'time': data['time'],
            'location': data['location'],
            'link': data['link'],
            'description': data['description']
        })

        users.update_item(
            Key={'username': username},
            UpdateExpression="SET events = :events",
            ExpressionAttributeValues={':events': user_events}
        )

        return jsonify({"message": f"Event '{data['name']}' added successfully"}), 201
    except Exception as e:
        print(f"Error in add_event: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

@app.route('/delete_event', methods=['OPTIONS', 'DELETE'])
@jwt_required()
def delete_event():
    if request.method == 'OPTIONS':
        # Respond to the preflight request
        return jsonify({"message": "Preflight OK"}), 200

    try:
        # Log the authenticated username
        username = get_jwt_identity()
        print(f"Authenticated Username: {username}")

        data = request.get_json()
        event_id = data.get('event_id')
        if not event_id:
            return jsonify({"error": "Event ID is required"}), 400

        print(f"Received Data: {data}")

        # Query the user
        response = users.get_item(Key={'username': username})
        print(f"DynamoDB Response: {response}")

        if 'Item' not in response:
            return jsonify({"error": "User not found"}), 404

        # Retrieve and filter events
        user_data = response['Item']
        user_events = user_data.get('events', [])
        updated_events = [event for event in user_events if event.get('event_id') != event_id]

        if len(updated_events) == len(user_events):
            return jsonify({"error": "Event not found"}), 404

        # Update DynamoDB
        users.update_item(
            Key={'username': username},
            UpdateExpression="SET events = :events",
            ExpressionAttributeValues={':events': updated_events}
        )

        return jsonify({"message": f"Event with ID '{event_id}' deleted successfully"}), 200
    except Exception as e:
        print(f"Error in delete_event: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

@app.route('/get_user_events', methods=['GET'])
@jwt_required()
def get_user_events():
    try:
        # Get the authenticated username
        username = get_jwt_identity()
        print(f"Authenticated Username: {username}")

        # Query the user
        response = users.get_item(Key={'username': username})
        print(f"DynamoDB Response: {response}")

        if 'Item' not in response:
            return jsonify({"error": "User not found"}), 404

        # Return the user's events
        user_events = response['Item'].get('events', [])
        return jsonify({"events": user_events}), 200
    except Exception as e:
        print(f"Error in get_user_events: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(debug=True)
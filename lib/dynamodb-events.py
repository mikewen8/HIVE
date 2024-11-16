import boto3
import json
from decimal import Decimal  

dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id='[key]',
    aws_secret_access_key='[key]',
    region_name='us-east-1'
)

table_name = 'events'
table = dynamodb.Table(table_name)

input_json = {
    "events": [
        {
            "id": "G5vYZb8wkueaZ",
            "name": "Golden State Warriors vs. Phoenix Suns",
            "type": "Sports",
            "genre": "Basketball",
            "venue": "Chase Center",
            "address": "300 16th Street",
            "date": "2024-12-28",
            "time": "17:30:00",
            "location": {
                "longitude": Decimal("-122.387464"),
                "latitude": Decimal("37.76797")
            },
            "description": "Get ready for an electrifying showdown..."
        },
        {
            "id": "G5vYZb8wARwAV",
            "name": "Golden State Warriors vs. Phoenix Suns",
            "type": "Sports",
            "genre": "Basketball",
            "venue": "Chase Center",
            "address": "300 16th Street",
            "date": "2025-01-31",
            "time": "19:00:00",
            "location": {
                "longitude": Decimal("-122.387464"),
                "latitude": Decimal("37.76797")
            },
            "description": "Prepare for an exhilarating night..."
        },
        {
            "id": "G5vYZb8wkGeFM",
            "name": "Golden State Warriors vs. Los Angeles Lakers",
            "type": "Sports",
            "genre": "Basketball",
            "venue": "Chase Center",
            "address": "300 16th Street",
            "date": "2024-12-25",
            "time": "17:00:00",
            "location": {
                "longitude": Decimal("-122.387464"),
                "latitude": Decimal("37.76797")
            },
            "description": "Experience the ultimate Christmas Day..."
        },
        {
            "id": "Z7r9jZ1A7FKfS",
            "name": "Hamilton (Touring)",
            "type": "Arts & Theatre",
            "genre": "Theatre",
            "venue": "Orpheum Theatre-San Francisco",
            "address": "1192 Market St.",
            "date": "2024-11-27",
            "time": "13:00:00",
            "location": {
                "longitude": Decimal("-122.419502"),
                "latitude": Decimal("37.779499")
            },
            "description": "Step into the world of revolutionary storytelling..."
        },
        {
            "id": "Z7r9jZ1A7Fw73",
            "name": "Hamilton (Touring)",
            "type": "Arts & Theatre",
            "genre": "Theatre",
            "venue": "Orpheum Theatre-San Francisco",
            "address": "1192 Market St.",
            "date": "2024-11-27",
            "time": "19:30:00",
            "location": {
                "longitude": Decimal("-122.419502"),
                "latitude": Decimal("37.779499")
            },
            "description": "Experience the revolutionary musical..."
        }
    ]
}

for event in input_json["events"]:  
    item = {
        'event_id': event['id'],  
        'Event': event['name'],  
        'type': event['type'],
        'genre': event['genre'],
        'venue': event['venue'],
        'address': event['address'],
        'date': event['date'],
        'time': event['time'],
        'location': event['location'],  
        'description': event['description']
    }

    table.put_item(Item=item)
    print(f"Uploaded event: {event['name']}")

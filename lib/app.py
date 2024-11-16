
from flask import Flask
from flask_cors import CORS


app = Flask(__name__)
CORS(app)  # Allow all origins


# need to have a script to upload the fetch data over time

@app.route('/events', methods=['GET'])
def get_events():
    # Example: Fetch event data
    # need to call the fetch from database Aadi-Arnav-Hardik do this! and have this search wheather it 
    return {"events": [{"id": 1, "name": "Concert", "description":"Loud and proud Tyler sucks at bedwars"}, {"id": 2, "name": "Art Exhibition", "description":"this is the event description"}]}

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
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
import requests
from pandas import DataFrame
import json
from dotenv import load_dotenv
import os

# Load env variables
load_dotenv()

# Ticketmaster Client
class TicketmasterClient:
    def __init__(self):
        self.openai_key = os.environ.get("OPENAI_KEY")
        api_key = os.environ.get("TICKETMASTER_KEY")
        self.base_url = "https://app.ticketmaster.com/discovery/v2"
        self.params = {
            'apikey': api_key,
            'latlong': '47.6061,-122.3328',  # Latitude and Longitude for Seattle
            'radius': '10',  # Search radius in miles
            'unit': 'miles', # Unit of distance measurement
            'size': '5'      # Limit to 5 events for simplicity (optional)
        }

    # Get dataframe of events
    def get_events(self):
        url = f"{self.base_url}/events.json"
        response = requests.get(url, params=self.params)
        events = response.json()
        event_list = events.get('_embedded',[])
        events_df = DataFrame(event_list)
        return events_df

    # Get json of all events (NOTE: LONG RUNTIME)
    def event_list(self):
        events_df = self.get_events()
        event_list = []
        for n in range(0,len(events_df)):
            event_params = {}
            event = events_df['events'][n]
            event_params['event_id'] = event['id']
            event_params['name'] = event['name']
            event_params['type'] = event['classifications'][0]['segment']['name']
            event_params['genre'] = event['classifications'][0]['genre']['name']
            event_params['venue'] = event['_embedded']['venues'][0]['name']
            event_params['address'] = event['_embedded']['venues'][0]['address']['line1']
            event_params['date'] = event['dates']['start']['localDate']
            event_params['time'] = event['dates']['start']['localTime']
            event_params['location'] = event['_embedded']['venues'][0]['location']
            event_params['link'] = event['url']
            event_list.append(event_params)

        for n in range(0,len(event_list)):
            # Activate LLM, and create prompt for it
            llm = ChatOpenAI(api_key=self.openai_key,model='gpt-4o')
            messages = [
                (
                    "system",
                    f"""You are a description generator for an event. You are given the event details and you will provide a short desription of what
                        the event will be like based off of the title, type, and genre. Your only output is a description of the event.
                        Here is the event info:
                        {str(event_list[n]).replace('{','').replace('}','')}
                    """,
                ),
                ("human", "Generate a description for this event"),
            ]
            description = llm.invoke(messages).content
            event_list[n]['description'] = description

        event_dict = {}
        event_dict['events'] = event_list    
        
        json_event_list = json.dumps(event_dict)
        return json_event_list
        
    # Get events similar to query. Requires list of events and query
    def similar_events(self,json_event_list,query):
        event_list = json.loads(json_event_list)['events']
        
        doc_list = []
        for n in range(0,len(event_list)):
            event_info = event_list[n]
            document = Document(page_content=str(event_info))
            doc_list.append(document)

        embeddings = OpenAIEmbeddings(api_key=self.openai_key)
        db = FAISS.from_documents(doc_list, embeddings)
        similar_docs = db.similarity_search(query)
        
        
        similar_events = {}
        sim_list = []
        for n in range(0,len(similar_docs)):
            sim_list.append(similar_docs[n].page_content)
            
        similar_events['events'] = sim_list
    
        json_sim_events = json.dumps(similar_events)
        return json_sim_events
        

        

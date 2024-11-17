from ticketmaster_client import TicketmasterClient
from get_event_list import event_list

# Initialize Ticketmaster Client
tkm = TicketmasterClient()

# Find similar events. Requires event list and a user query
similar_events = tkm.similar_events(event_list,user_query)
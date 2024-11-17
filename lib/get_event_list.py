from ticketmaster_client import TicketmasterClient

# Initialize Ticketmaster Client
tkm = TicketmasterClient()

# Get list of events in form of json
event_list = tkm.event_list()
print(event_list)

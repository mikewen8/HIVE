import boto3


dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id='AKIATQPTFUEWDLBTCJET',
    aws_secret_access_key='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',
    region_name='us-east-1'
)
table = dynamodb.Table(name='events')

def retrieve_events():
    table = dynamodb.Table('events')
    try:
        response = table.scan()
        events = response.get('items', []) 

        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            events.extend(response.get('Items', []))

        return jsonify({"events":events})
    except (BotoCoreError, ClientError) as error:
        print(f"Error fetching events: {error}")
        return jsonify({'error': str(error)}), 500 


print(table)
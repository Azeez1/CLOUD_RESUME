import json
import boto3
from unittest import TestCase
from moto import mock_dynamodb2
from your_lambda_file import lambda_handler  # replace with your actual file name

class TestVisitorCountLambda(TestCase):
    @mock_dynamodb2
    def setUp(self):
        # Set up a mock DynamoDB table
        self.dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table_name = 'Visitors'
        self.table = self.dynamodb.create_table(
            TableName=self.table_name,
            KeySchema=[
                {'AttributeName': 'visitorID', 'KeyType': 'HASH'}
            ],
            AttributeDefinitions=[
                {'AttributeName': 'visitorID', 'AttributeType': 'S'}
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 1,
                'WriteCapacityUnits': 1
            }
        )
        
        # Initialize the table with a count
        self.table.put_item(Item={'visitorID': 'count', 'visits': 0})

    @mock_dynamodb2
    def test_lambda_handler(self):
        # Simulate a Lambda event
        event = {}
        context = {}
        response = lambda_handler(event, context)
        
        # Verify that the response is as expected
        self.assertEqual(response['statusCode'], 200)
        body = json.loads(response['body'])
        self.assertGreater(body['visits'], 0)  # Ensure visits increment

if __name__ == '__main__':
    unittest.main()

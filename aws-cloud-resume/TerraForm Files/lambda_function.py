import json
import boto3
from decimal import Decimal

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Visitors2024')

    # Update visitor count
    response = table.update_item(
        Key={'id': 'visit_count'},
        UpdateExpression='ADD visitCount :incr',
        ExpressionAttributeValues={':incr': 1},
        ReturnValues="UPDATED_NEW"
    )

    # Convert Decimal to int before returning
    visit_count = int(response['Attributes']['visitCount'])  # Convert to int

    return {
        'statusCode': 200,
        'body': json.dumps({'visitCount': visit_count})  # Use the converted visit_count
    }

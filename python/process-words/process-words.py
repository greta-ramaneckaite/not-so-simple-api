import json
import boto3
import re
import logging


dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("word_map")


def lambda_handler(event, context):

    # Validate input sentence
    if "sentence" not in event:
        logging.warning('sentence param is missing in request body')
        raise Exception('Status code 400 - Bad Request')

    input_text = event['sentence']

    # Define a regex pattern to match words
    word_pattern = r'\b\w+\b'

    # Process input sentence
    response = {
        "mapped_sentence": re.sub(word_pattern, replace_db_hit, input_text)
    }

    return response


def replace_db_hit(match):
    # Get word to match against database
    word = match.group(0)

    fetched_object = table.get_item(
        Key={
            "word": word.lower()
        }
    )

    if "Item" in fetched_object:
        mapped_word = fetched_object['Item']['mapped_word']
    else:
        mapped_word = word
    return mapped_word

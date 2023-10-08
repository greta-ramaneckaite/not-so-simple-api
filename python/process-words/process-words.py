import json
import boto3
import re
import logging


dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("word_map")


class HttpErrorMessage:
    HTTP_400_SENTENCE_PARAM_MISSING = (400, "Bad Request: Sentence param is missing in request body")
    HTTP_400_SENTENCE_PARAM_WRONG_TYPE = (400, "Bad Request: Sentence param is not a string")

    @staticmethod
    def log_and_fail(error_message):
        error_message_log = f"Status code {error_message[0]} - {error_message[1]}"
        logging.warning(error_message_log)
        raise Exception(error_message_log)
    

def validate_input(event):
    if "sentence" not in event:
        HttpErrorMessage.log_and_fail(HttpErrorMessage.HTTP_400_SENTENCE_PARAM_MISSING)
    elif not isinstance(event['sentence'], str):
        HttpErrorMessage.log_and_fail(HttpErrorMessage.HTTP_400_SENTENCE_PARAM_WRONG_TYPE)


def replace_db_hit(match):
    # Get word to match against database
    word = match.group(0)
    # Query the database using the word as primary key
    fetched_object = table.get_item(
        Key={
            "word": word.lower()
        }
    )
    if "Item" in fetched_object:
        # A mapping exists in the database, return it
        mapped_word = fetched_object['Item']['mapped_word']
    else:
        # A mapping does not exist in the database, return the original word
        mapped_word = word
    return mapped_word


def lambda_handler(event, context):
    validate_input(event)
    input_text = event['sentence']
    # Regex pattern to match words
    WORD_REGEX_PATTERN = r'\b\w+\b'
    # Process input sentence
    return {
        "mapped_sentence": re.sub(WORD_REGEX_PATTERN, replace_db_hit, input_text)
    }

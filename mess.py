import firebase_admin
import os

from firebase_admin import messaging
from firebase_admin import credentials

from google.cloud import firestore

credPath = "D:\\chinointapp-firebase-adminsdk-gaul1-e5bbcd4a3b.json"

cred = credentials.Certificate(credPath)

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = credPath

default_app = firebase_admin.initialize_app(cred)

db = firestore.Client(project='chinointapp')


def send_to_user():
    docs = db.collection('users').stream()


    for doc in docs:
        data = doc.to_dict()
        if data['email'] == 'karl@chinoint.com':
            registration_token = data['token']
            message = messaging.Message(
                data={
                    'score': '850',
                    'time': '2:45',
                },
                token=registration_token,
                notification=messaging.Notification(title='Hello', body='World'),
            )
            response = messaging.send(message)
            print('Successfully sent message:', response)

cust = {'chinoint': '346e94e0-3b66-11ef-b3ad-5d5b624d6d28', 'chinoint-4s': '07adb040-7b9d-11ef-b70b-f3ea6c0c69ea' }

def send_to_topic():
    # The topic name can be optionally prefixed with "/topics/".
    customerID = cust['chinoint']

    # See documentation on defining a message payload.
    message = messaging.Message(
        topic=customerID,
        notification=messaging.Notification(title='Hello', body='World'),
    )

    # Send a message to the devices subscribed to the provided topic.
    response = messaging.send(message)
    # Response is a message ID string.
    print('Successfully sent message to topic:', response)

send_to_topic()
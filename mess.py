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

cust = {
    'chinoint': '346e94e0-3b66-11ef-b3ad-5d5b624d6d28',
    'chinoint-4s': '07adb040-7b9d-11ef-b70b-f3ea6c0c69ea' 
}

def send_to_user(customer, email, Title, Body):
    docs = db.collection(cust[customer]).stream()


    for doc in docs:
        data = doc.to_dict()
        if data['email'] == email:
            registration_token = data['token']
            message = messaging.Message(
                data={
                    'score': '850',
                    'time': '2:45',
                },
                token=registration_token,
                notification=messaging.Notification(title=Title, body=Body),
            )
            response = messaging.send(message)
            print('Successfully sent message:', response)


def send_to_topic(customer, Title, Body):
    # The topic name can be optionally prefixed with "/topics/".
    customerID = cust[customer]

    # See documentation on defining a message payload.
    message = messaging.Message(
        topic=customerID,
        notification=messaging.Notification(title=Title, body=Body),
    )

    # Send a message to the devices subscribed to the provided topic.
    response = messaging.send(message)
    # Response is a message ID string.
    print('Successfully sent message to topic:', response)

    ref = db.collection(customerID).document('ntf')

    ref.set({'some date2': Title + "\\ " + Body})

send_to_topic('chinoint', 'Hello', 'World')
import firebase_admin

from firebase_admin import messaging
from firebase_admin import credentials

cred = credentials.Certificate("D:\\chinointapp-firebase-adminsdk-gaul1-e5bbcd4a3b.json")

default_app = firebase_admin.initialize_app(cred)


# This registration token comes from the client FCM SDKs.
registration_token = 'fAYpru2_TFe8TSm4to8Jou:APA91bHS5O5aJumaM5cgZaSYvIATopGTKenldSz7cY3SnObC0MhtRfPc1-q-5vcYpKhPNRxONDMq3Gw4aGnfXdwuIyuqSlufcQh2TMAqAIjQHVDeqcPmIYE'

# See documentation on defining a message payload.
message = messaging.Message(
    data={
        'score': '850',
        'time': '2:45',
    },
    token=registration_token,
    notification=messaging.Notification(title='Hello', body='World'),
)

# Send a message to the device corresponding to the provided
# registration token.
response = messaging.send(message)
# Response is a message ID string.
print('Successfully sent message:', response)

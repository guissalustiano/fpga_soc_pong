import sys
import json
from pprint import pprint
from datetime import datetime

import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

cred = credentials.Certificate("soc-pong-firebase-adminsdk-4r3nm-63b21be0ee.json")
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://soc-pong-default-rtdb.firebaseio.com/'
})

ref = db.reference('/scores')
# print(ref.get())


# print("real begin")

# real read line
while 1:
# drop out until header
    for line in sys.stdin:
        line = line.strip('\r\n')
        # sys.stdout.write(line + '\n')
        if line == "####":
            break

    try:
        for line in sys.stdin:
            line = line.strip('\r\n')
            data = json.loads(line)
            data['createAt'] = str(datetime.now())
            pprint(data)
            ref.push().set(data)
    except:
        pass

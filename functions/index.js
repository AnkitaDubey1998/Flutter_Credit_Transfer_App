const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.RequestNotification = functions.firestore.document('requests/{receiverUid}/from/{requestId}')
.onCreate( async (snapshot, context) => {

    if(snapshot.empty) {
       console.log('No device');
    }


    var receiverUid = context.params.receiverUid;
    var requestId = context.params.requestId;
    console.log('receiver uid:', receiverUid);
    console.log('request id:', requestId);

    var senderName = '';
    var requestCredit = '';

    await admin.firestore().doc('requests/'+receiverUid+'/from/'+requestId).get()
    .then(doc => {
    	senderName = doc.data().senderName;
    	requestCredit = doc.data().credit;
    	return true;
    })
    .catch(error => {
    	console.log("error: ", error);
    	return false;
    });

    console.log('sender name: ', senderName);
    console.log('request credit: ', requestCredit);


    return await admin.firestore().doc('users/'+receiverUid).get()
    .then(doc => {
    	var deviceTokens = doc.data().deviceTokens;
    	console.log("device tokens: ", deviceTokens);

    	var payload = {
    		notification: {
    			title: 'Credit Request',
    			body:  senderName + ' has requested ' + requestCredit + ' credits ',
    			sound: 'default'
    		}
		};

		
    	return admin.messaging().sendToDevice(deviceTokens, payload)
    	.then(value => {
    		console.log("helooo");
    		return console.log("Notification sent");
    	})
    	.catch(error => {
    		return console.log('error: ', error);
    	});
    })
    .catch(error => {
    	console.log("error: ", error);
    	return false;
    });

});


const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);



// function for sending notification to receiver on receiving credit
exports.TransferNotification = functions.firestore.document('transactions/{receiverUid}/{sameuid}/{transactionId}')
.onCreate( async (snapshot, context) => {

	var receiverUid = context.params.receiverUid;
	var transactionId = context.params.transactionId;

	var type = ''
	var senderName = '';

	await admin.firestore().doc('transactions/'+receiverUid+'/'+receiverUid+'/'+transactionId).get()
	.then(doc => {
		type = doc.data().type;
		senderName = doc.data().name;
		return true;
	})
	.catch(error => {
		console.log("error: ", error);
    	return false;
	});

	console.log('type: ', type);
	console.log('sender name: ', senderName);

	if(type == 'from') {
		return await admin.firestore().doc('users/'+receiverUid).get()
		.then(doc => {
			var deviceTokens = doc.data().deviceTokens;
			console.log("device tokens: ", deviceTokens);

			var payload = {
	    		notification: {
	    			title: 'Received Credit',
	    			body:  senderName + ' has sent ' + requestCredit + ' credits ',
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

		}).catch(error => {
			console.log("error: ", error);
	    	return false;
		});

		} else {
		console.log('this is "to" type transaction');
		return console.log('not valid');
	}
    

});




// function for sending notification of requests
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


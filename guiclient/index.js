const {app, BrowserWindow, ipcMain} = require('electron')

let wins = {}	// Window(s) global reference
let menus = {}	// Menu(s) global references
let var1 = "ciaooooo"

function createWindow(name, max = true) {
	wins[name] = new BrowserWindow({width: 800, height: 600})
	wins[name].loadFile("windows/" + name + ".html") // load index.html file
	//wins[name].webContents.openDevTools()

	wins[name].on('closed', () => {
		wins[name] = null
	})

	wins[name].maximize()
}

app.on('ready', function() { // When modules are loaded run all remaining code
	createWindow("home")
	// Custom code ------------------------------------------------------------------------------

	//console.log(wins["main"].window)
})


// Console log action listener
ipcMain.on('consoleLog', function(event, data){
	console.log(data)
});



/*
https://stackoverflow.com/questions/32780726/how-to-access-dom-elements-in-electron
CLIENT:

ipc.once('consoleLogReply', function(event, response){
	processResponse(response);
})

ipc.send('consoleLog', data);

SERVER:

ipc.on('consoleLog', function(event, data){
	console.log(data)
	event.sender.send('consoleLogReply', "OK");
});
*/

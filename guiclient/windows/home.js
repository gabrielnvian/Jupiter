const {ipcRenderer} = require('electron')

document.addEventListener("DOMContentLoaded", function() { 
	//document.getElementById("var1").innerHTML = "Text from main.js";

	document.getElementById('button1').addEventListener('click', function(event) {
		let data = document.getElementById("input1").value;
		console.log("sending...", data)
		ipcRenderer.send('consoleLog', data);
	});

	document.getElementById("varpanel").innerHTML = '<iframe src="' + data + '"></iframe>'
});

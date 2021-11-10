'use strict';
const http = require('http');
const exec = require('child_process').exec;
let MAX_CHARGE = Number(process.argv[2]);
let MIN_CHARGE = Number(process.argv[3]);

if (isNaN(MAX_CHARGE) || MAX_CHARGE <= 2) MAX_CHARGE = 45;
if (isNaN(MIN_CHARGE) || MAX_CHARGE - MIN_CHARGE < 2) MIN_CHARGE = MAX_CHARGE - 2;

console.log(`charge from ${MIN_CHARGE} to ${MAX_CHARGE}`);

checkBattery();

function checkBattery()
{
	exec('testTermux.bat', (err, stdin, stderr) =>
	{
		if (err)
		{
			console.log(stderr);
		}
		else
		{
			let data = null;
			try
			{
				data = JSON.parse(stdin);
				data.time = new Date();
			}
			catch (e)
			{
				console.log(e.message);
			}
			if (data)
			{
				sendBatteryInfoRequest(JSON.stringify(data));
				if (!data.percentage || !data.status)
				{
					console.log('Not enough data in battery info!');
				}
				else
				{
					if (data.status === 'NOT_CHARGING')
					{
						if (data.percentage <= MIN_CHARGE)
						{
							requestStartCharge();
						}
					}
					else if (data.status === 'CHARGING')
					{
						if (data.percentage >= MAX_CHARGE)
						{
							requestStopCharge();
						}
					}
				}
			}
		}
		setTimeout(checkBattery, 10000);
	});
}

function requestStartCharge()
{
	console.log('Starting charge');
}

function requestStopCharge()
{
	console.log('Stoping charge');
}

function sendBatteryInfoRequest(json)
{
	//console.log(json);
	const options =
	{
		hostname: 'localhost',
		port: 5017,
		path: '/setBatteryInfo',
		method: 'POST',
		headers:
		{
			'Content-Type': 'application/json',
			'Content-Length': Buffer.byteLength(json)
		}
	};
	const req = http.request(options);
	req.on('error', (e) =>
	{
		console.error(`Problem with request: ${e.message}`);
	});
	req.end(json);
}
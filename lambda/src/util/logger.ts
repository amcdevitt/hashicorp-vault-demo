import { createLogger, TRACE, DEBUG, INFO, WARN, ERROR, FATAL } from "bunyan";

export function createLog(loggerName: string, idempotencyKey: string){
	let logLevel = TRACE;// INFO;
	if(process && process.env && process.env.LOG_LEVEL){
		switch(process.env.LOG_LEVEL){
		case "trace":
			logLevel = TRACE;
			break;
		case "debug":
			logLevel = DEBUG;
			break;
		case "info":
			logLevel = INFO;
			break;
		case "warn":
			logLevel = WARN;
			break;
		case "error":
			logLevel = ERROR;
			break;
		case "fatal":
			logLevel = FATAL;
			break;
		}
	}

	const log = createLogger({
		name: loggerName,                
		level: logLevel,      
		src: true,
		iKey: idempotencyKey
	});
	return log;
}
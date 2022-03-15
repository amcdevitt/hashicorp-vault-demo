import middy from '@middy/core'
import jsonBodyParser from '@middy/http-json-body-parser'
import httpErrorHandler from '@middy/http-error-handler'

import { APIGatewayProxyResult, Context } from "aws-lambda";
import { InvokeCommand, InvokeCommandInput, InvokeCommandOutput, LambdaClient } from "@aws-sdk/client-lambda";
import { createLog } from "../util/logger";
import { Logger } from "bunyan";

const serviceRegion: string = process.env.SPROCKET_AWS_REGION;

let logger: Logger = createLog("request-router", "request-router");

const baseHandler = async (event: any, context: Context): Promise<APIGatewayProxyResult> => {

    console.log(`before logger: ${JSON.stringify(event)}`);
    logger.info({event: event}, "Input event");
    console.log(`after logger: ${JSON.stringify(event)}`);

    let responseBody = {
        message: "Error invoking Lambda function"
    }

    const response = {
        statusCode: 500,
        body: "",
        headers: {}
    };

    if(event?.path?.startsWith("/forward-to"))
    {
        let inputPathArr = event.path.split("/").splice(2);
        let lambdaFunctionName: string = inputPathArr.shift();
        let lambdaFunctionPath: string = inputPathArr.join("/");
        let eventBody = event.body;
        let eventHeaders = event.headers;

        logger.info(
            {
                inputHeaders: eventHeaders, 
                inputBody: eventBody, 
                lambdaFunctionName: lambdaFunctionName
            }, 
            "Forwarding request to Lambda");
        
        let inputToLambda = JSON.stringify({
            body: eventBody,
            headers: eventHeaders,
            path: lambdaFunctionPath
        });


        await invokeLamdba(inputToLambda, lambdaFunctionName)
            .then(async lambdaInvocationResult => {
                const lambdaResultPayload = Buffer.from(lambdaInvocationResult.Payload).toString();
                const lambdaResult = JSON.parse(lambdaResultPayload);
                logger.trace({lambdaResult:lambdaResult},"lambdaResultPayload");
                
                if(lambdaInvocationResult?.StatusCode === 200)
                {
                    response.statusCode = lambdaResult.StatusCode;
                    responseBody = JSON.parse(lambdaResult.body);
                    response.headers = lambdaResult.headers;
                }
                else
                {
                    response.statusCode = 500;
                }
                return "";
            })
            .catch(async error => {
                logger.error({error: error}, "Error invoking Lambda function");
                return error;
            });
    }

    response.body = JSON.stringify(responseBody);

    return response;
    
};

const invokeLamdba = async (lambdaPayload: string, functionToTrigger: string): Promise<InvokeCommandOutput> => {
    
    let lambdaInvokeParams: InvokeCommandInput = {
        FunctionName: functionToTrigger,
        InvocationType: 'RequestResponse',
        Payload: Buffer.from(lambdaPayload)
    };

    return (new LambdaClient({ region: serviceRegion })).send(new InvokeCommand(lambdaInvokeParams))
        .then(async lambdaResult => {
            logger.trace( {lambdaResult:lambdaResult}, "Lambda result");
            return lambdaResult;
        }).catch(async error => {
            logger.trace( {error: error}, {functionName: lambdaInvokeParams.FunctionName},"Error from Lambda");
            return error;
        });
};

export const handler = middy(baseHandler)
  .use(jsonBodyParser()) // parses the request body when it's a JSON and converts it to an object
  .use(httpErrorHandler()) // handles common http errors and returns proper responses
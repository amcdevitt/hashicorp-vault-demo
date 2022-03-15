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

    console.log(`Event Input: ${JSON.stringify(event)}`);

    let eventBody = event.body;
    let eventHeaders = event.headers;
    let path = event.path;

    console.log(`Event Body: ${JSON.stringify(eventBody)}`);
    console.log(`Event Headers: ${JSON.stringify(eventHeaders)}`);
    console.log(`Event Path: ${JSON.stringify(path)}`);

    let responseBody = {
        message: "You've hit the example lambda",
        originalBody: eventBody
    }

    let responseHeaders = {
        exampleHeader: "exampleHeaderValue"
    }

    const response = {
        statusCode: 500,
        body: "",
        headers: {}
    };

    response.body = JSON.stringify(responseBody);
    response.headers = responseHeaders;

    return response;
    
};

export const handler = middy(baseHandler)
  .use(httpErrorHandler()) // handles common http errors and returns proper responses
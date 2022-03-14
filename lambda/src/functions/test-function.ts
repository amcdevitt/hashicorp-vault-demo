import { APIGatewayProxyResult, Context } from "aws-lambda";
import { vaultAwsAuth } from "vault-auth-aws"
import { QueuePoller } from "sprocket-utils";
import { createLog } from "../util/logger";
import { Logger } from "bunyan";

const apiVersion: string = process.env.SPROCKET_VAULT_API_VERSION;
const vaultEndpoint: string = process.env.SPROCKET_VAULT_ENDPOINT;
const vaultToken: string = process.env.SPROCKET_VAULT_TOKEN;
const vaultHost: string = process.env.SPROCKET_VAULT_HOST;
const vaultNamespace: string = process.env.SPROCKET_VAULT_NAMESPACE;

var options = {
    apiVersion: apiVersion, // default
    endpoint: vaultEndpoint, // default
    token: vaultToken // optional client token; can be fetched after valid initialization of the server
  };

let logger: Logger = createLog("test-function", "test-function");
const vaultAuthClient = require("vault-auth-aws");

export const handler = async (event: any, context: Context): Promise<APIGatewayProxyResult> => {
    
  console.log(`before logger: ${JSON.stringify(event)}`);
  logger.info({event: event}, "Input event");
  console.log(`after logger: ${JSON.stringify(event)}`);

  const response: APIGatewayProxyResult = {
    headers: {"Content-Type": "application/json","Access-Control-Allow-Origin":"*"},
    isBase64Encoded: false,
    statusCode: 200,
    body: ""
  };

  try {
    let vaultClient = new vaultAwsAuth({host: vaultEndpoint});
    const success = await vaultClient.authenticate();
    const vault = require('node-vault')({
                  apiVersion: options.apiVersion,
                  endpoint: options.endpoint,
                  token: success.auth.client_token,
              });
    // get your super secrets.
    //vault.write('aws/data/test');
    const secret = await vault.read('aws/config/root');

    logger.info({secret: secret}, "Secret");
    
  }
  catch (ex) {
    logger.error({ex: ex}, "Error");
    // error here.
  }

  return response;
};

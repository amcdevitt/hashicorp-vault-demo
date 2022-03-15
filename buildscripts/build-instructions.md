Instructions on how to build lambda functions using the provided build scripts.

## Building a Lambda Function
You can build and deploy a lambda function quickly using the build scripts contained in this repository.

### Quick Steps for building a lambda
1. Create your lambda function in Typescript under `/lambda/src/`.  Use the `/lambda/src/functions/example-lambda.ts` as a template.  Pay specific attention to the input and return types of the `basehandler` function.  The only exported function should be the lambda handler: 
    ```javascript
    export const handler = middy(basehandler).use(httpErrorHandler());
    ```
    Your `basehandler` function signature should look like this and return a `Promise<APIGatewayProxyResult>`:
    ```javascript
    const baseHandler = async (event: any, context: Context): Promise<APIGatewayProxyResult> = {
        // Your code here
    }
    ```
2. In the `/lambda/build-config.json` file, add your lambda function name and the path to your function entrypoint (Typescript file). The path should be relative to the build-config.json file. 
    
    Esbuild will compile your Typescript file into a JavaScript file and pull in all necessary dependencies, so only specify a single entrypoint.  
    
    You can optionally add any additional files (non-Typescript/javascript) that you want to include in your lambda function by adding an `additionalFiles` array of filenames.:
    ```json
    {
        "name": "your-lambda-function-name",
        "esbuildEntrypoint": "src/functions/test-function.ts",
        "additionalFiles": [
            "support-files/example-file.txt"
        ]
    }
    ```
3. In the root of the project, run `./build.sh test` to build your lambda function.  This will create a zip file in the `/build/` directory and generate a terraform script for your lambda if it does not exist.  By default, the terraform lambda file will be created with basic permissions and functionalities.  If you need additional configurations, you can add them to the `/infrastructure/lambda-<your_function_name>.tf` file.
    
    Building will also add the default variables needed by the lambda function to the `/infrastructure/<environment>.variables.tfvars` file.  You can add additional variables or change values in this file if you need to.

4. Run the deploy script `./deploy-infra.sh` script to deploy your changes to AWS.  This uses the generated terraform files created in the previous step.  It will deploy anything that is not already deployed.

5. Test your function.  There is a lambda included with this package called request-router.  This will forward requests to your lambda without you having to write any heavy API code (like API gateway or swagger). The `deploy-infra.sh` script will output a variable called `request-router-endpoint`.  You can use this base URL to call your function. 
    
    For example, if the URL in the output is `https://request-router-endpoint.execute-api.us-east-1.amazonaws.com/dev/`, you can call your function with `https://request-router-endpoint.execute-api.us-east-1.amazonaws.com/dev/forward-to/your-lambda-function-name/your/lambda/specific/path`.  And the input json, headers, and path will be forwarded to your lambda function.

    The output of your lambda will then be forwarded back to the caller including any headers and status code.

    **Important note**: Your lambda function names will be prefixed by the value configured in `/lambda/build-config.json`.  So if you have a lambda function named `test-function` and the config file has the following, your lambda name will be `vlt-test-function`:

    ```json
    {
        "project": {
            "name": "Vault",
            "prefix": "vlt"
        },
        "lambdas": [
            ...
        ]
    } 
    ```

### Folder Structure
The folder structure of lambda functions is as follows:
    
`/lambda` - root for nodejs.

`/lambda/build-config.json` - configuration file for AWS lambdas.

`/lambda/esbuild-lambda.js` - the build script for building lambda functions

`/lambda/package.json` - the package.json file for the lambda functions.  Calls esbuild.

`/lambda/src` - typescript source files

`/build.sh` - the build script for building the lambda functions.

`/deploy-infra.sh` - the build script for deploying the lambda functions.

`/buildscripts/` - the build scripts for building the lambda functions.

`/infrastructure/` - the terraform infrastructure for the project.
        

## Build Files
### build.sh
Main build script used for building nodejs projects.
    
    Usage:
        ./build.sh [environment]
#### Notes: 
    * The environment variable is optional. If not provided, the 'local' environment will be used.
    * For terraform scripts, this will use the <environment>.variables.tfvars and <environment>.backend.tfvars files.

### deploy-infra.sh
Deploys the created terraform infrastructure plan build by build.sh for the project.
    
    Usage:
        ./deploy-infra.sh
#### Notes:
    * This will use the <environment>.variables.tfvars and <environment>.backend.tfvars files.
    * For AWS deployment, it will use the default configured AWS profile. Login info can be set by running `aws configure`

### /buildscripts/infratemplates
This folder contains the terraform templates used for building the infrastructure.

### /buildscripts/build-vars.sh
This file contains the variables used for building the infrastructure.  This is used by all other build scripts.

### /buildscripts/zip-lambdas.sh
This script will zip all the lambda functions in the project into their own zip files.  It is called by the build.sh script.

### /buildscripts/build-functions.sh
This script contains helper functions used by the other build scripts.
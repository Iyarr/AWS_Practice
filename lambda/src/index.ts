import { APIGatewayProxyResult, Handler, APIGatewayEvent } from "aws-lambda";

export const handler: Handler = async (event: APIGatewayEvent) => {
  const response: APIGatewayProxyResult = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};

import {
  APIGatewayProxyEvent,
  Context,
  APIGatewayProxyResult,
} from "aws-lambda";

import { format } from "date-fns";

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  return new Promise((resolve, reject) => {
    resolve({
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "OK",
        event: event,
        date: format(new Date(), "yyyy-MM-dd"),
      }),
    });
    return;
  });
};

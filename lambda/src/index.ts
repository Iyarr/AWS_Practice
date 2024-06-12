import { Handler } from "aws-lambda";

export const handler: Handler = async (event) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda by Typescript!!"),
  };
  return response;
};

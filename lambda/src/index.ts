export const handler: any = async (event: any) => {
  const response: any = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};

export const handler = async (event, context) => {
  return new Promise((resolve, reject) => {
    resolve({
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "OK",
        event: event,
      }),
    });
    return;
  });
};

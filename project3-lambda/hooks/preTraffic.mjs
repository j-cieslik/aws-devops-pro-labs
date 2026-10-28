// PreTraffic hook: invokes the NEW version directly (no user traffic yet)
// and tells CodeDeploy whether the deployment may continue.
import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";
import { CodeDeployClient, PutLifecycleEventHookExecutionStatusCommand } from "@aws-sdk/client-codedeploy";

const lambda = new LambdaClient({});
const codedeploy = new CodeDeployClient({});

export const handler = async (event) => {
  let status = "Succeeded";
  try {
    const res = await lambda.send(new InvokeCommand({ FunctionName: process.env.NEW_VERSION, Payload: "{}" }));
    const payload = JSON.parse(Buffer.from(res.Payload).toString());
    console.log("New version returned:", JSON.stringify(payload));
    if (res.FunctionError || payload.statusCode !== 200 || !/Hello from SAM/.test(payload.body)) {
      throw new Error("Unexpected response from the new version");
    }
  } catch (err) {
    console.log("PreTraffic test failed:", err.message);
    status = "Failed";
  }
  await codedeploy.send(new PutLifecycleEventHookExecutionStatusCommand({
    deploymentId: event.DeploymentId,
    lifecycleEventHookExecutionId: event.LifecycleEventHookExecutionId,
    status,
  }));
  return status;
};

import helloUrl from "./zig-out/lib/hello.wasm?url";
import { instantiateStreaming, errors } from "@wapc/host";

const response = await fetch(helloUrl);

const hostFunctions = {
  app: {
    window: {
      alert(payload) {
        window.alert(new TextDecoder().decode(payload));
      },
    },
  },
};

const host = await instantiateStreaming(
  response,
  (binding, namespace, operation, payload) => {
    const fn = hostFunctions[binding]?.[namespace]?.[operation];
    if (!fn) {
      throw new errors.HostCallNotImplementedError(
        binding,
        namespace,
        operation
      );
    }
    return fn(payload);
  }
);

const div = document.createElement("div");

const input = document.createElement("input");
input.setAttribute("type", "text");
input.value = "Stephen";
div.append(input);

const callZig = document.createElement("button");
callZig.innerText = "call zig";
callZig.onclick = async () => {
  const payloadStr = JSON.stringify({ name: input.value });
  const payload = new TextEncoder().encode(payloadStr);
  const result = await host.invoke("hello", payload);
  const json = new TextDecoder().decode(result);
  window.alert(json);
};
div.append(callZig);

div.append(document.createElement("br"));

const zigCallJs = document.createElement("button");
zigCallJs.innerText = "zig call js";
zigCallJs.onclick = async () => {
  const payloadStr = JSON.stringify({});
  const payload = new TextEncoder().encode(payloadStr);
  await host.invoke("zigCallJs", payload);
};
div.append(zigCallJs);

document.body.append(div);

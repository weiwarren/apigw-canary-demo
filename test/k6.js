import http from 'k6/http';
import { sleep } from 'k6';

const INVOKE_URI=__ENV.INVOKE_URI;

export default function () {
  if(!INVOKE_URI){
    throw new Error("Missing invoke URI in the environment. Set it with export INVOKE_URI=${invoke uri}")
  }
  http.get(`${INVOKE_URI}/`);
  sleep(1);
}
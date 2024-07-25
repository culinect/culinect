export interface Env {
  MY_BUCKET: culinect_bucket;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    let path = url.pathname;
    let method = request.method;

    if (method === 'POST') {
      let data = await request.json();
      let key = data.key;
      let value = data.value;

      // Save data to R2 storage
      await env.MY_BUCKET.put(key, new TextEncoder().encode(value));

      return new Response('Data saved successfully!');
    } else if (method === 'GET' && path.startsWith('/data')) {
      let key = path.split('/').pop();

      // Retrieve data from R2 storage
      let value = await env.MY_BUCKET.get(key);

      return new Response(value ? new TextDecoder().decode(value) : 'No data found');
    } else {
      return new Response('Hello World!');
    }
  },
};

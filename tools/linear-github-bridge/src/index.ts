import { handleLinearWebhook } from './linear-to-github';
import { handleSlackCommand } from './slack-to-linear';

export interface Env {
  LINEAR_WEBHOOK_SECRET: string;
  LINEAR_API_KEY: string;
  GITHUB_TOKEN: string;
  GITHUB_REPO: string;
  SLACK_SIGNING_SECRET: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/linear-webhook' && request.method === 'POST') {
      return handleLinearWebhook(request, env);
    }

    if (url.pathname === '/slack-command' && request.method === 'POST') {
      return handleSlackCommand(request, env);
    }

    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ status: 'ok', time: new Date().toISOString() }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response('Not Found', { status: 404 });
  },
};

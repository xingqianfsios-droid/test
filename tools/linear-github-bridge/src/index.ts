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
      return new Response(JSON.stringify({
        status: 'ok',
        time: new Date().toISOString(),
        secrets: {
          LINEAR_WEBHOOK_SECRET: env.LINEAR_WEBHOOK_SECRET ? `set (${env.LINEAR_WEBHOOK_SECRET.length} chars)` : 'MISSING',
          LINEAR_API_KEY: env.LINEAR_API_KEY ? `set (${env.LINEAR_API_KEY.length} chars)` : 'MISSING',
          GITHUB_TOKEN: env.GITHUB_TOKEN ? `set (${env.GITHUB_TOKEN.length} chars)` : 'MISSING',
          SLACK_SIGNING_SECRET: env.SLACK_SIGNING_SECRET ? `set (${env.SLACK_SIGNING_SECRET.length} chars)` : 'MISSING',
          GITHUB_REPO: env.GITHUB_REPO ?? 'MISSING',
        },
      }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response('Not Found', { status: 404 });
  },
};

import type { Env } from './index';

// Linear 工作流状态 ID — 部署前需要替换为你的 workspace 实际值
// 获取方式见 README
const LINEAR_STATE_IDS: Record<string, string> = {
  todo: 'YOUR_LINEAR_TODO_STATE_ID',
  'in-progress': 'YOUR_LINEAR_IN_PROGRESS_STATE_ID',
  'in-review': 'YOUR_LINEAR_IN_REVIEW_STATE_ID',
  done: 'YOUR_LINEAR_DONE_STATE_ID',
  cancelled: 'YOUR_LINEAR_CANCELLED_STATE_ID',
};

export async function handleSlackCommand(
  request: Request,
  env: Env,
): Promise<Response> {
  // 1. 验证 Slack 签名
  const timestamp = request.headers.get('x-slack-request-timestamp');
  const slackSignature = request.headers.get('x-slack-signature');

  if (!timestamp || !slackSignature) {
    return new Response('Missing Slack headers', { status: 401 });
  }

  // 防重放攻击：拒绝 5 分钟前的请求
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - parseInt(timestamp)) > 300) {
    return new Response('Request too old', { status: 401 });
  }

  const body = await request.text();
  const sigBase = `v0:${timestamp}:${body}`;

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(env.SLACK_SIGNING_SECRET),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const sigBuffer = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(sigBase),
  );

  const computedSig =
    'v0=' +
    Array.from(new Uint8Array(sigBuffer))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');

  if (computedSig !== slackSignature) {
    return new Response('Invalid Slack signature', { status: 401 });
  }

  // 2. 解析 Slack 命令
  // 格式: /linear-status ENG-123 done
  const params = new URLSearchParams(body);
  const text = params.get('text') ?? '';
  const userName = params.get('user_name') ?? 'unknown';

  const parts = text.trim().split(/\s+/);
  if (parts.length < 2) {
    return slackResponse(
      '用法: `/linear-status ENG-123 <todo|in-progress|in-review|done|cancelled>`',
    );
  }

  const [linearId, newStatus] = parts;

  if (!LINEAR_STATE_IDS[newStatus]) {
    const valid = Object.keys(LINEAR_STATE_IDS).join(', ');
    return slackResponse(`无效状态。可选: ${valid}`);
  }

  // 3. 查找 Linear Issue
  const issue = await findLinearIssue(linearId, env);
  if (!issue) {
    return slackResponse(`找不到 Linear 任务 \`${linearId}\``);
  }

  // 4. 更新 Linear 状态
  const updated = await updateLinearStatus(
    issue.id,
    LINEAR_STATE_IDS[newStatus],
    env,
  );

  if (!updated) {
    return slackResponse(`更新 \`${linearId}\` 失败，请检查 Linear API Key`);
  }

  return new Response(
    JSON.stringify({
      response_type: 'in_channel',
      text: `✅ \`${linearId}\` 状态已更新为 *${newStatus}*（by ${userName}）`,
    }),
    { headers: { 'Content-Type': 'application/json' } },
  );
}

async function findLinearIssue(
  identifier: string,
  env: Env,
): Promise<{ id: string; title: string } | null> {
  const response = await fetch('https://api.linear.app/graphql', {
    method: 'POST',
    headers: {
      Authorization: env.LINEAR_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: `
        query($identifier: String!) {
          issue(id: $identifier) {
            id
            title
          }
        }
      `,
      variables: { identifier },
    }),
  });

  if (!response.ok) return null;

  const result = (await response.json()) as {
    data?: { issue?: { id: string; title: string } };
  };

  return result.data?.issue ?? null;
}

async function updateLinearStatus(
  issueId: string,
  stateId: string,
  env: Env,
): Promise<boolean> {
  const response = await fetch('https://api.linear.app/graphql', {
    method: 'POST',
    headers: {
      Authorization: env.LINEAR_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: `
        mutation($issueId: String!, $stateId: String!) {
          issueUpdate(id: $issueId, input: { stateId: $stateId }) {
            success
          }
        }
      `,
      variables: { issueId, stateId },
    }),
  });

  if (!response.ok) return false;

  const result = (await response.json()) as {
    data?: { issueUpdate?: { success: boolean } };
  };

  return result.data?.issueUpdate?.success ?? false;
}

function slackResponse(text: string): Response {
  return new Response(
    JSON.stringify({ response_type: 'ephemeral', text }),
    { headers: { 'Content-Type': 'application/json' } },
  );
}

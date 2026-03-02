import type { Env } from './index';

// 支持的状态名称（用户输入 → Linear state name 映射）
const STATUS_NAME_MAP: Record<string, string> = {
  todo: 'Todo',
  'in-progress': 'In Progress',
  'in-review': 'In Review',
  'in-test': 'In Test',
  done: 'Done',
  cancelled: 'Canceled',
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
    const valid = Object.keys(STATUS_NAME_MAP).join(', ');
    return slackResponse(
      `用法: \`/linear-status ENG-123 <${valid}>\``,
    );
  }

  const [linearId, newStatus] = parts;

  if (!STATUS_NAME_MAP[newStatus]) {
    const valid = Object.keys(STATUS_NAME_MAP).join(', ');
    return slackResponse(`无效状态。可选: ${valid}`);
  }

  // 3. 查找 Linear Issue（包含 team 信息）
  const issue = await findLinearIssue(linearId, env);
  if (!issue) {
    return slackResponse(`找不到 Linear 任务 \`${linearId}\``);
  }

  // 4. 动态查询该 Issue 所属 Team 的状态 ID
  const targetStateName = STATUS_NAME_MAP[newStatus];
  const stateId = await findTeamStateId(issue.teamId, targetStateName, env);
  if (!stateId) {
    return slackResponse(`该 Team 中找不到状态 "${targetStateName}"`);
  }

  // 5. 更新 Linear 状态
  const updated = await updateLinearStatus(issue.id, stateId, env);

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
): Promise<{ id: string; title: string; teamId: string } | null> {
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
            team { id }
          }
        }
      `,
      variables: { identifier },
    }),
  });

  if (!response.ok) return null;

  const result = (await response.json()) as {
    data?: { issue?: { id: string; title: string; team: { id: string } } };
  };

  const issue = result.data?.issue;
  if (!issue) return null;

  return { id: issue.id, title: issue.title, teamId: issue.team.id };
}

async function findTeamStateId(
  teamId: string,
  stateName: string,
  env: Env,
): Promise<string | null> {
  const response = await fetch('https://api.linear.app/graphql', {
    method: 'POST',
    headers: {
      Authorization: env.LINEAR_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: `
        query($teamId: String!) {
          team(id: $teamId) {
            states { nodes { id name } }
          }
        }
      `,
      variables: { teamId },
    }),
  });

  if (!response.ok) return null;

  const result = (await response.json()) as {
    data?: { team?: { states: { nodes: Array<{ id: string; name: string }> } } };
  };

  const states = result.data?.team?.states.nodes ?? [];
  const match = states.find((s) => s.name === stateName);
  return match?.id ?? null;
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

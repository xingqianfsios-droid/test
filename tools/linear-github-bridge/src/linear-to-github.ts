import type { Env } from './index';

interface LinearWebhookPayload {
  action: string;
  type: string;
  data: {
    id: string;
    identifier: string;
    title: string;
    description?: string;
    url: string;
    priority: number;
    state: {
      name: string;
      type: string;
    };
    labels?: Array<{ name: string }>;
  };
}

const PRIORITY_MAP: Record<number, string> = {
  0: '无优先级',
  1: '紧急',
  2: '高',
  3: '中',
  4: '低',
};

export async function handleLinearWebhook(
  request: Request,
  env: Env,
): Promise<Response> {
  // 1. 验证 Linear Webhook 签名
  const signature = request.headers.get('linear-signature');
  if (!signature) {
    return new Response('Missing signature', { status: 401 });
  }

  const body = await request.text();

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(env.LINEAR_WEBHOOK_SECRET),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['verify'],
  );

  const isValid = await crypto.subtle.verify(
    'HMAC',
    key,
    hexToBytes(signature),
    new TextEncoder().encode(body),
  );

  if (!isValid) {
    return new Response('Invalid signature', { status: 401 });
  }

  // 2. 解析并过滤事件
  const payload: LinearWebhookPayload = JSON.parse(body);

  if (payload.type !== 'Issue') {
    return new Response('Skipped: not an issue event', { status: 200 });
  }

  // 仅在任务状态变为 "In Progress" 或添加 "ready-for-claude" 标签时触发
  const isInProgress =
    payload.action === 'update' && payload.data.state?.type === 'started';

  const hasReadyLabel = payload.data.labels?.some(
    (l) => l.name.toLowerCase() === 'ready-for-claude',
  );

  if (!isInProgress && !hasReadyLabel) {
    return new Response('Skipped: event filtered', { status: 200 });
  }

  // 3. 去重检查
  const existing = await findExistingIssue(payload.data.identifier, env);

  if (existing) {
    await addLabel(existing.number, 'claude-implement', env);
    return new Response(`Updated existing issue #${existing.number}`, {
      status: 200,
    });
  }

  // 4. 创建 GitHub Issue
  const issueBody = buildIssueBody(payload.data);

  const response = await fetch(
    `https://api.github.com/repos/${env.GITHUB_REPO}/issues`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'linear-github-bridge/1.0',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: `[${payload.data.identifier}] ${payload.data.title}`,
        body: issueBody,
        labels: ['linear-sync', 'claude-implement'],
      }),
    },
  );

  if (!response.ok) {
    const error = await response.text();
    console.error('GitHub API error:', error);
    return new Response('Failed to create GitHub issue', { status: 500 });
  }

  const issue = (await response.json()) as {
    number: number;
    html_url: string;
  };

  return new Response(
    JSON.stringify({ created: issue.number, url: issue.html_url }),
    { status: 200, headers: { 'Content-Type': 'application/json' } },
  );
}

function buildIssueBody(data: LinearWebhookPayload['data']): string {
  const priority = PRIORITY_MAP[data.priority] ?? '未知';

  return `## Linear 任务
- **ID**: \`${data.identifier}\`
- **链接**: [${data.identifier}](${data.url})
- **优先级**: ${priority}

## 需求描述
${data.description ?? '未提供描述'}

## 技术上下文
这是一个 Flutter/Dart 中国象棋游戏项目。
- 状态管理: GetX
- 架构: MVC（controllers/, views/, models/, core/）
- 坐标系: 9x10 棋盘，(0,0) = 左上角
- 请严格遵循 CLAUDE.md 和 SKILLS.md 中的规则

---
*由 Cloudflare Worker 自动从 Linear 创建*`;
}

async function findExistingIssue(
  linearId: string,
  env: Env,
): Promise<{ number: number } | null> {
  const response = await fetch(
    `https://api.github.com/search/issues?q=repo:${env.GITHUB_REPO}+"[${linearId}]"+in:title+is:issue`,
    {
      headers: {
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        Accept: 'application/vnd.github+json',
        'User-Agent': 'linear-github-bridge/1.0',
      },
    },
  );

  if (!response.ok) return null;

  const result = (await response.json()) as {
    total_count: number;
    items: Array<{ number: number }>;
  };

  return result.total_count > 0 ? result.items[0] : null;
}

async function addLabel(
  issueNumber: number,
  label: string,
  env: Env,
): Promise<void> {
  await fetch(
    `https://api.github.com/repos/${env.GITHUB_REPO}/issues/${issueNumber}/labels`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        Accept: 'application/vnd.github+json',
        'User-Agent': 'linear-github-bridge/1.0',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ labels: [label] }),
    },
  );
}

function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
  }
  return bytes;
}

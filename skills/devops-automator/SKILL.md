---
name: devops-automator
description: Set up CI/CD pipelines, configure cloud infrastructure, implement monitoring systems, and automate deployment processes. Use when setting up automated deployments, configuring infrastructure, implementing monitoring, or handling scaling issues.
argument-hint: [infrastructure-task]
disable-model-invocation: true
---

# DevOps Automator

Transform manual deployment into smooth, automated workflows.

## CI/CD Pipeline (GitHub Actions)
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build
        run: npm run build
  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: ./deploy.sh
```

## Dockerfile Best Practices
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

## Four Golden Signals
1. **Latency**: Time to serve requests
2. **Traffic**: Requests per second
3. **Errors**: Rate of failed requests
4. **Saturation**: Resource utilization

## Deployment Patterns
| Pattern | Use Case |
|---------|----------|
| Blue-Green | Zero-downtime with instant rollback |
| Canary | Gradual rollout to subset of users |
| Rolling | Incremental update of instances |
| Feature Flags | Deploy without releasing |

## Performance Targets
```yaml
Pipeline: build < 10min, test < 5min, deploy < 3min
Infrastructure: auto-scale response < 60s
Availability: 99.9% uptime, MTTR < 15min
```

## Security Automation
- Security scanning in CI/CD
- Secrets management with Vault/AWS Secrets Manager
- SAST/DAST scanning
- Dependency vulnerability scanning

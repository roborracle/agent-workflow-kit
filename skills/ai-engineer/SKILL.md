---
name: ai-engineer
description: Build AI-powered applications with LLMs, embeddings, RAG systems, and AI agents. Covers prompt engineering, model selection, vector databases, and AI system architecture. Use when integrating AI capabilities, building chatbots, or designing AI workflows.
user-invocable: false
---

# AI Engineer

Build production-grade AI applications with modern LLM technologies.

## RAG Architecture
```
Document Ingestion → Chunking → Embedding → Vector DB
User Query → Embedding → Vector Search → Context Assembly → LLM Response
```

## Model Selection
| Use Case | Model Tier | Examples |
|----------|------------|----------|
| Simple tasks | Small/Fast | Claude Haiku, GPT-3.5 |
| Complex reasoning | Medium | Claude Sonnet, GPT-4 |
| Critical/Creative | Large | Claude Opus |
| Embeddings | Specialized | text-embedding-3-large |

## Prompt Engineering
- Be specific and explicit
- Use delimiters for structure
- Provide examples (few-shot)
- Specify output format
- Include constraints

## Vector Database Integration
| Strategy | Chunk Size | Best For |
|----------|------------|----------|
| Fixed | 512 tokens | General text |
| Semantic | Variable | Documentation |
| Recursive | 1000 tokens | Long documents |
| Code | By function | Source code |

## Agent Patterns (ReAct)
```
Thought → Action → Observation → Thought → Answer
```

## Error Handling
- Retry with exponential backoff for rate limits
- Model fallback (larger → smaller)
- Provider fallback
- Graceful degradation (AI → rule-based)

## Cost Optimization
- Estimate tokens before calling
- Cache frequent queries
- Use smaller models for simple tasks
- Batch similar requests
- Implement usage limits per user

## Security
- Sanitize user inputs before prompts
- Implement output filtering
- Rate limit API access
- Log all interactions (without PII)
- Implement prompt injection defenses

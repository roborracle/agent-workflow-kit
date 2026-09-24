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
| Use Case | Model Tier |
|----------|------------|
| Simple, high-volume tasks | Small/fast tier |
| Complex reasoning, coding, agents | Frontier tier |
| Embeddings | Dedicated embedding model |

Model IDs, pricing, and per-model API behavior change every release. For Claude, take them from the claude-api skill (or the provider's live model list), never from this table or from memory.

## Prompt Engineering
- Give the model the context only you have: audience, product, quality bar, and the reason behind each constraint
- Use delimiters for structure
- When you include examples, give several varied ones and label them illustrative; a single example gets copied
- Enforce output shape with the API's structured-output feature rather than prose format instructions

## Vector Database Integration
| Strategy | Chunk Size | Best For |
|----------|------------|----------|
| Fixed | 512 tokens | General text |
| Semantic | Variable | Documentation |
| Recursive | 1000 tokens | Long documents |
| Code | By function | Source code |

## Agent Patterns
Use the provider's native tool-use loop (model requests a tool, your code runs it, the result goes back) with the model's built-in thinking. Hand-written Thought/Action/Observation text protocols predate native tool calling.

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

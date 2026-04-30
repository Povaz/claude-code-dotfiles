Here's the updated Survey Context with `NPS Score` added to the Dictionary:

```markdown
# Context: Survey

The Survey Context covers learner surveys, response collection, and satisfaction reporting.

## Relationships

None yet — this is the first Context.

## Dictionary

| Term      | Definition |
|-----------|------------|
| Survey    | A questionnaire issued to a Learner after course completion to capture feedback. Each Survey has at most one response per Learner per Course. |
| Response  | A submitted Survey, identified by a unique response ID. Once submitted, immutable. |
| NPS Score | Net Promoter Score derived from a Survey Response. Calculated on a 0–10 scale where respondents are classified as Promoters (9–10), Passives (7–8), or Detractors (0–6); the aggregate NPS Score is the percentage of Promoters minus the percentage of Detractors. |
```

A few things to double-check before locking this in:

- **Scale and calculation**: I assumed the standard 0–10 NPS scale with the Promoter/Passive/Detractor split. If your product uses a different scale (e.g., 1–5 stars mapped to NPS) or a different aggregation method, let me know and I'll adjust.
- **Per-Response vs. aggregate**: The definition above covers both the individual rating captured in a Response and the aggregate score. If your team treats these as two separate concepts (e.g., `NPS Rating` for the individual answer and `NPS Score` for the rolled-up metric), it's worth splitting them into two dictionary entries to avoid ambiguity in user stories.
- **Ownership**: NPS is sometimes reported in a separate Reporting/Analytics Context rather than the Survey Context. If that's the case here, you may want to define it there and reference it from Survey via the Relationships section instead.

Let me know if any of those apply and I'll refine the entry.

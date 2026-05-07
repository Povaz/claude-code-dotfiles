Adding `NPS Score` to the Survey Context — that's where it belongs given it's computed from `Response` data. Flag if you'd rather it lives in its own (e.g. Reporting / Satisfaction) Context; I don't see one yet.

A couple of things I want to surface before this lands, because `NPS Score` is one of those terms that *looks* universal but is interpreted differently in practice:

1. **Score scale.** Are you using the canonical Bain & Company definition (an integer in `[-100, +100]`, computed as `% Promoters − % Detractors` over a population of `Response`s), or are you using the raw 0-10 likelihood-to-recommend value from a single `Response` and calling that "the NPS score"? Both usages are common in the wild and they're not the same thing. I've drafted the canonical version below — please correct if your team uses the per-response raw value.
2. **Aggregation unit.** If it is the canonical version: at what level do you compute it? Per `Survey`? Per Course? Per cohort? Globally over a time window? Pick one as the default; the others can be qualified explicitly when they come up.
3. **Promoter / Detractor / Passive thresholds.** The standard cuts are 9-10 / 7-8 / 0-6. Confirm you're using those, or list yours. (Not strictly required as a separate Dictionary entry, but the `NPS Score` definition leans on these and a reader will want to know.)

I've drafted with the canonical assumption and noted the aggregation question as `?? — pending clarification` rather than guessing. Updated Context below — only the Dictionary changed; description and Relationships are untouched.

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
| NPS Score | The Net Promoter Score derived from the standard 0-10 likelihood-to-recommend question on a `Survey`. Computed as `% Promoters − % Detractors` (Bain & Company canonical formula), where Promoters answer 9-10, Passives 7-8, and Detractors 0-6. Expressed as an integer in `[-100, +100]`. Aggregation unit: ?? — pending clarification (per `Survey`? per Course? per cohort?). |
```

## Propagation note (Rule 9)

A definition change for `NPS Score` would propagate to any Story or AC mentioning it. You said this is the first Story to use the term, so the affected set today is just the Story you're drafting — no re-review of existing artifacts needed. Once you confirm the aggregation unit, I'll tighten the definition and the placeholder will go away; that *is* a definition change in Rule 9 terms, but it'll only touch the same Story.

## Smells worth flagging

- **Single-citation term (for now).** `NPS Score` enters with one citation. That's expected for a fresh term, but worth re-checking at the next recurring spec review — if no other Story picks it up, prune-or-keep judgement applies.
- **Hard-to-define term.** The fact that I had to ask three clarifying questions to pin down the definition is itself the smell described in the skill — terms where teams routinely "know what they mean" until you ask. Worth a short conversation now rather than at acceptance time.

Returning control to the `user-stories` skill once you confirm the assumptions above so the Story can be finalised with `` `NPS Score` `` properly highlighted. I haven't touched the Story text — that's the `user-stories` skill's job.

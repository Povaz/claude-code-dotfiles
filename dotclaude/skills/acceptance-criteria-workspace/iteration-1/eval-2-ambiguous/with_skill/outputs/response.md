Before I draft AC, this story is quite thin and I don't want to invent the shape of the feature. Several unknowns will materially change the scenarios, so could you confirm the following?

1. **User role and context.** "User" is vague — is this an authenticated end user of a specific app (learner, instructor, admin)? And where does the upload happen (a dedicated "My files" page, inside a lesson, inside a message thread)?
2. **"Share them" — with whom and how?** Is sharing part of *this* story (pick recipients during/after upload) or a separate downstream story? The phrasing suggests sharing is the benefit, not the behavior — I want to confirm so I don't over-scope the AC.
3. **Constraints on the files.** What are the allowed types (images only? any MIME?), the max file size, and the max number of files per upload? These drive every Sad Path scenario.
4. **Storage and retention.** Any requirement on where files live (tenant-scoped bucket, region), and for how long? Is virus/malware scanning required before the file becomes shareable?
5. **Resumability / large files.** Do we need resumable uploads and background/async processing, or is a single synchronous upload acceptable?

Below is a conservative draft. Sections that depend on your answers are marked `??`.

## Acceptance Criteria

### Happy Path (Gherkin)

```gherkin
Background:
  Given an authenticated user is on the file upload screen  # ?? confirm role + screen (Q1)

Scenario: User uploads a single valid file
  Given the user has selected a file that meets the allowed type and size constraints  # ?? Q3
  When the user confirms the upload
  Then the file is uploaded successfully
    And the user sees the file listed as "Uploaded" with its name, size, and upload timestamp
    And the file is available for the user to share  # ?? sharing mechanics depend on Q2
```

If multi-file upload is in scope (pending Q3), add:

```gherkin
Scenario: User uploads multiple valid files at once
  Given the user has selected N files, each meeting the allowed type and size constraints  # N = ?? (Q3)
  When the user confirms the upload
  Then each file is uploaded successfully
    And every uploaded file appears in the user's file list
```

### Sad Path (Gherkin)

```gherkin
Scenario: File exceeds the maximum allowed size
  Given the user has selected a file larger than the maximum allowed size  # ?? size limit (Q3)
  When the user confirms the upload
  Then the upload is rejected before any bytes are persisted
    And the user sees error "File exceeds the maximum size of ?? MB."  # ?? exact copy
    And no file is added to the user's file list

Scenario: File type is not allowed
  Given the user has selected a file whose type is not in the allowed list  # ?? allowed types (Q3)
  When the user confirms the upload
  Then the upload is rejected
    And the user sees error "This file type is not supported."  # ?? exact copy
    And no file is added to the user's file list

Scenario: Network interruption during upload
  Given the user has started uploading a file
  When the network connection is lost before the upload completes
  Then the user sees an actionable error indicating the upload did not complete
    And the partial file is not retained as a usable file
    And the user can retry the upload  # ?? resumable vs. restart depends on Q5

Scenario: Malicious or infected file detected
  Given virus/malware scanning is enabled  # ?? confirm scanning requirement (Q4)
  When a newly uploaded file is flagged as malicious by the scanner
  Then the file is quarantined and not made available for sharing
    And the user sees a message explaining the file was rejected for safety reasons
```

Additional Sad Path scenarios to add once answers are in: empty file (0 bytes); filenames with disallowed characters or excessive length; duplicate filename within the user's space (overwrite/rename/block?); per-user storage quota exceeded.

### Non-Functional Requirements (Checklist)

- [ ] **Performance:** p95 upload time for a file of the maximum allowed size is under ?? seconds on a typical broadband connection.
- [ ] **Performance:** Upload progress is shown within 500 ms of the upload starting; the UI remains responsive throughout.
- [ ] **Functionality (Security):** Only authenticated users can upload; each file is scoped to the uploader's tenant/account and inaccessible to other tenants.
- [ ] **Functionality (Security):** All uploaded files are scanned for malware before becoming available for sharing.  # ?? confirm (Q4)
- [ ] **Functionality (Security):** File type is validated by content (magic bytes), not just by extension.
- [ ] **Usability (Accessibility):** The upload control is fully operable via keyboard and screen reader, conforming to WCAG 2.1 Level AA.
- [ ] **Usability:** On failure, the error message states the cause and the corrective action.
- [ ] **Reliability:** Transient storage-backend failures are retried with exponential backoff; no user-visible error is shown if recovery succeeds within ?? seconds.
- [ ] **Supportability:** Every upload attempt emits a structured log with a correlation ID, user ID, file size, MIME type, and outcome; no file contents appear in logs.
- [ ] **+ Constraint (Legal/Compliance):** Files are encrypted at rest and transmitted over TLS 1.2+; retention and regional storage policies match the tenant's compliance requirements.

**What to clarify (summary):** (1) user role and upload screen; (2) whether sharing is in scope; (3) allowed types, max size, and max count; (4) storage/retention and malware scanning; (5) resumable/async uploads.

**Note on story shape:** the story couples *uploading* and *sharing* via the "so that" clause. If sharing involves its own UI and permissioning, that is almost certainly a second story — consider splitting before sprint planning (see the `user-stories` skill).

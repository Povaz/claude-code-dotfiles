Happy to draft acceptance criteria, but "upload files so I can share them" leaves a lot of important decisions open. I'll give you a reasonable first-pass set of criteria below based on common assumptions, then list the questions you'll want to answer before treating this as "ready."

## Assumptions I'm making

Call these out and correct any that are wrong:

1. Authenticated users only (no anonymous uploads).
2. Uploads happen from a web UI (drag-and-drop + file picker).
3. "Share" means the uploaded file gets a link the user can send to others; scope of who can open it is TBD.
4. Common file types allowed (images, PDFs, docs); no executables.
5. There is a per-file size cap (I've used 100 MB as a placeholder).
6. Files are stored server-side (not just client-side).

## Acceptance Criteria

### AC1 - Starting an upload
- **Given** I am signed in and on a page that supports uploads
- **When** I select a file via the file picker or drag a file onto the drop zone
- **Then** the file appears in an upload queue showing its name, size, and a progress indicator

### AC2 - Successful upload
- **Given** I have selected a valid file (allowed type, under the size limit)
- **When** the upload completes
- **Then** I see a success state for that file
- **And** the file is persisted and visible in my list of uploaded files
- **And** a shareable link is generated and shown (or reachable via a "Share" action)

### AC3 - File type restriction
- **Given** I attempt to upload a file whose type is not on the allowed list
- **When** I select it
- **Then** the upload is rejected before any bytes are sent
- **And** I see an error explaining which types are allowed

### AC4 - File size restriction
- **Given** I attempt to upload a file larger than the configured limit
- **When** I select it
- **Then** the upload is rejected
- **And** I see an error stating the maximum allowed size

### AC5 - Multiple files
- **Given** I select more than one file at once
- **When** the uploads start
- **Then** each file is tracked independently with its own progress and status
- **And** a failure on one file does not cancel the others

### AC6 - Network / server failure
- **Given** an upload is in progress
- **When** the network drops or the server returns an error
- **Then** the file is marked as failed with a clear message
- **And** I can retry the upload without re-selecting the file

### AC7 - Cancel in progress
- **Given** a file is currently uploading
- **When** I click "Cancel" on that file
- **Then** the upload stops
- **And** no partial file is stored or listed as mine

### AC8 - Unauthenticated users
- **Given** I am not signed in
- **When** I try to access the upload UI or hit the upload endpoint
- **Then** I am redirected to sign in (UI) or receive a 401 (API)

### AC9 - Sharing the uploaded file
- **Given** an upload has succeeded
- **When** I use the "Share" action on it
- **Then** I get a link I can copy
- **And** opening that link in another session lets the recipient access the file according to the configured share scope

### AC10 - Virus / malware scanning (if applicable)
- **Given** an upload completes
- **When** the file is scanned and flagged as malicious
- **Then** the file is quarantined / removed
- **And** I am notified that it could not be shared

## Questions to resolve before this is really "done"

These materially change the criteria above, so I'd flag them to your PO/tech lead:

1. **Who can upload?** Anyone signed in? Specific roles? Anonymous?
2. **Who can view a shared file?** Anyone with the link? Only signed-in users? Only specific people I invite? Does the link expire?
3. **File types and size limit** - what's actually allowed, and what's the max size? Any total quota per user?
4. **Single vs. multiple upload** - is multi-select a requirement or a nice-to-have?
5. **Resumable uploads** - for large files, do we need chunked/resumable support, or is a simple single-request upload fine?
6. **Storage backend** - S3? Our own server? Affects latency and retry behavior.
7. **Virus scanning / content moderation** - required or out of scope?
8. **Versioning** - if someone uploads a file with the same name, replace, rename, or reject?
9. **Deletion** - can users delete their own uploads? Does that revoke share links?
10. **Auditing / quotas** - any limits on how many files or total bytes per user?
11. **Platforms** - web only, or also mobile / desktop clients?
12. **Accessibility** - does the upload UI need to meet a specific a11y standard (keyboard-only, screen readers)?
13. **Analytics / logging** - do we need to track upload events?

If you can answer even a few of these (especially 1, 2, 3, and 7), I can tighten the criteria into something a team could actually pick up and build.

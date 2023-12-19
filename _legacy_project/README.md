# Weekly Business Reviews Demo

This project demonstrates using Evidence to create content for a Weekly Business Review, it:

- **Automatically pre-populates a new report for each week**, using data from the database.
- **Allows business users to add commentary** to the report, to explain any unusual events or trends.
- **Can be shared via URL, PDF or copy-pasted** into another document.

## Commentary System

This project extends Evidence's core open source by adding the ability for end users to add commentary to reports.
This functionality is provided via an AirTable, which stores the commentary and allows users to edit it.


## Authentication

- You cannot save edits to the commentary unless you have the (secret) password.
- In most organizational settings, this would be handled instead by user authentication, but for the purposes of this public demo, we're using a password.
- Evidence offers authentication through Evidence Cloud, our hosted cloud service.

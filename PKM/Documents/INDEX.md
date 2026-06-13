# Documents - Index

Markdown stubs that describe and point at the real documents. Actual files live in `Documents/<domain>/` at the mypka root. The stub holds metadata, expiration dates, and wikilinks to related entities.

## Structure

Stubs are organized by domain subfolder matching `Documents/<domain>/`:

- [[PKM/Documents/lake-erie/]] — vessel surveys, registration, insurance, marina docs
- [[PKM/Documents/homelab/]] — server specs, build references, network docs
- [[PKM/Documents/branding/]] — resumes, bios, templates, positioning docs
- [[PKM/Documents/investing/]] — brokerage statements, strategy docs, tax records
- [[PKM/Documents/gunsmithing/]] — FFL paperwork, compliance docs, build records
- [[PKM/Documents/automobiles/]] — titles, registration, service records
- [[PKM/Documents/drones/]] — FAA registration, part specs, manuals
- [[PKM/Documents/home-improvement/]] — permits, contractor quotes, receipts
- [[PKM/Documents/rentals/]] — leases, insurance, financial records
- [[PKM/Documents/travel/]] — passport, REAL ID, Global Entry, itineraries
- [[PKM/Documents/personal/]] — identity docs, medical, personal contracts
- [[PKM/Documents/genealogy/]] — certificates, immigration records, source docs
- [[PKM/Documents/food/]] — equipment manuals, warranties
- [[PKM/Documents/car-detailing/]] — product specs, process references

## Active stubs

### lake-erie/
- [[sea-ray-340-survey-2020]] — Pre-purchase marine survey July 2020 (Scott Austin AMS)

### homelab/
- [[lighthouse-r730xd-pka-update-2026-04]] — Lighthouse R730XD chassis inspection reference April 2026
- [[homelab-servers-handoff-2026-04-17]] — Complete three-server build state dump, April 2026 (330-line reference)

### branding/
- [[jeffrey-davis-pmo-director]] — PMO Director reference bio (PDF)
- [[jeffrey-davis-bio-2026]] — 2026 professional bio (PPTX)
- [[jeffrey-davis-best-of-class-resume-2026]] — Best-of-class master resume 2026
- [[jeffrey-davis-perficient-resume-2026]] — Perficient-tailored resume 2026
- [[2026-perficient-resume-template]] — Perficient resume template DOCX

### automobiles/
- [[2008-subaru-outback-repair-record]] — Living repair/diagnostic record; 2026-06-12 rough-running investigation (open) + owner work log; scan PDFs in `Documents/automobiles/`

### travel/
- [[travel-documents]] — Passport, TSA PreCheck, Global Entry master record (details to be confirmed)

## Adding a new document

1. Copy or move the file to `Documents/<domain>/` using a kebab-case slug.
2. Create a stub here at `PKM/Documents/<domain>/<slug>.md` with frontmatter from [[GL-002-frontmatter-conventions]] Documents schema.
3. Set `digital_location: Documents/<domain>/<filename>`.
4. Add to the Active stubs list above.

## What does not go here

- Research reports and team-produced work → `Deliverables/`
- Daily notes → `PKM/Journal/`
- Personal projects or goals → `PKM/My Life/`

## Image embeds

If a document has scans, those go to `PKM/Images/YYYY/MM/` and are embedded via `![[Images/YYYY/MM/...]]` from the document stub. The image is in Images. The stub points at it. SSOT.

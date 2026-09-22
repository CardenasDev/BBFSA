<!-- bmad:context -->
<!-- Verified 2026-09-21 against 584ea3cce96915a7d0b01d4cf8c7063733fcc522. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## Orientation
- BBF SisAdmin is a Brownfield repo: Front/ is Angular 22, Back/ is Laravel 12 on PHP 8.2, and BD/ contains MySQL tables and stored procedures. Use the AS-IS docs as scope boundaries and verify directly in code before changing behavior.
- Planning and deeper references: prd-as-is.md, architecture.md, and _bmad-output/as-is-gap-validation.md.

## Policy
- Before proposing functional changes, verify the AS-IS implementation and the validated gaps. Do not infer missing features from general HR or payroll assumptions.
- Effective access is determined by Usuario → Rol(es) → Permisos → Capacidades; do not treat roles as the only access control.
- Novedades, incapacidades, suspensiones, llamadas de atención and retirements are operational records/decisions, not automatic employee-state changes. A separate employee-status flow exists for explicit state changes.
- "Firma de contrato" means managing the signed document record; it is not cryptographic or legal e-signature.
- Manual operational steps are intentional unless the repo explicitly shows automation.

## Where things are
- Front: Angular app in Front/ with auth and permission guards in src/app.
- Back: Laravel API in Back/ with JWT auth and permission middleware; repositories call SP_BBF_* procedures rather than ad hoc table SQL.
- Database: MySQL procedures and schema assets live under BD/. Review affected SPs before database changes.
- Generated/local artifacts are ignored by .gitignore: .agents/, _bmad/, output/, QA/, Back/storage, Back/vendor, node_modules, and uploaded files in Back/public/uploads.

## Running and verifying
- Frontend: `cd Front && npm install && npm run build`; use `npm test` for targeted checks.
- Backend: `cd Back && composer install && php artisan test` or `php artisan route:list` for API verification.
- For a feature claim, inspect Front + Back + BD together before concluding it is missing or incomplete.

## Conventions that differ from defaults
- For an existing function, inspect Front + Back + BD before concluding it is absent.
- Do not create independent modules for flows that already exist inside Novedades or related operational workflows unless a requirement explicitly says so.
- Do not rewrite AS-IS docs to suit a new implementation; keep planning and implementation separate.
- Keep repo-wide context minimal and evidence-based.

## Known pitfalls
- Not every "manual" action is a defect; many workflows are intentionally handled by RRHH or authorized users.
- Self-service exists in specific capabilities, not as a universal employee portal.
- Payroll or external integration scope is not evidenced in the current repo; do not invent it.
- A signed file or uploaded contract document is not proof of cryptographic digital signature.

<!-- /bmad:context -->

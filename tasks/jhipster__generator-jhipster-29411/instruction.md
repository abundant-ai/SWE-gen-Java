When generating the Angular entity list/table views, JHipster currently adds sorting UI bindings for fields that are not actually sortable (for example transient fields such as those annotated with `@MapstructExpression`, including both direct fields and relationship-related derived fields). This leads to two problems:

1) For relationship-related derived/transient fields, the generated HTML enables sorting (via the `sortBy` directive / sort attributes). When a user clicks to sort by that column, the frontend sends a sort parameter that the backend cannot apply, resulting in an Internal Server Error.

2) For direct derived/transient fields, the generator can still emit the `sortBy` binding even though the UI does not show the sort icon, creating inconsistent output. The click is usually guarded by the directive so it may not trigger sorting, but the template still contains `sortBy` wiring that shouldn’t exist for unsortable fields.

Fix the generator so that it does not generate any sort-related attributes (including `sortBy` bindings and sort icons/controls) for fields that are not sortable. In particular:

- If a field is transient/derived (e.g., MapstructExpression-based) and therefore cannot be used for backend sorting, the generated list/table column must not include `sortBy` or any sort icon/control.
- The same rule must apply consistently to relationship-related columns that refer to such derived/transient properties.
- Sort UI should still be generated for genuinely sortable fields, and existing sortable behavior must remain unchanged.

After the change, a user should be unable to trigger sorting by any unsortable field from the generated UI, and sorting by valid persistent fields should continue to work normally without server errors.
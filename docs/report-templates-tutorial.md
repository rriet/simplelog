# Report Templates Tutorial (Download, Edit, Upload)

This guide explains how to:

1. Download an existing template JSON
2. Edit it safely
3. Upload it as a new template
4. Use all supported template keys

---

## Open the Template Editor

1. Go to `Reports`.
2. Click `Edit Templates`.
3. In the popup:
   - Existing templates are listed.
   - `Download` exports one template JSON.
   - `Delete` removes one template.
   - `Template name` + `Upload JSON` imports a new template entry.

Notes:
- Upload always creates a **new** template.
- Template names must be unique.

---

## Workflow (recommended)

1. Download `EASA` or `Standard`.
2. Save a copy (example: `my-company-template.json`).
3. Edit the JSON.
4. Back in `Edit Templates`, type a new `Template name`.
5. Click `Upload JSON`.
6. Select the edited file.
7. Close with `Done` and select your new template in Reports.

---

## JSON Structure

```json
{
  "rowsPerPage": 26,
  "forceLandscape": true,
  "defaultPageSize": "a4",
  "dateFormat": "dd-MM-yyyy",
  "timeFormat": "H:mm",
  "rowHeight": 11,
  "alternateRowBackgroundColor": "#E6E8EB",
  "coverPage": { "...": "..." },
  "labels": { "...": "..." },
  "tables": [
    {
      "pageSuffix": "A",
      "header": [ "...header rows..." ],
      "columns": [ "...columns..." ],
      "footer": [ "...free-form footer rows..." ],
      "footerRows": [ "...summary footer rows..." ]
    }
  ]
}
```

### Top-level keys

- `rowsPerPage` (int)
- `forceLandscape` (bool)
- `defaultPageSize` (`a4` | `letter` | `legal` | `a5`)
- `dateFormat` (`dd-MM-yyyy` | `dd/MMM/yy` | `yyyy-MM-dd`)
- `timeFormat` (`HH:mm` | `H:mm` | `H.DD`)
- `rowHeight` (number, default for table rows)
- `alternateRowBackgroundColor` (hex like `#E6E8EB`)
- `coverPage` (optional)
- `labels` (optional)
- `tables` (required, non-empty list)

`dateFormat` notes:
- `dd-MM-yyyy` example: `26-02-2026`
- `dd/MMM/yy` example: `26/Feb/26`
- `yyyy-MM-dd` example: `2026-02-26`

`timeFormat` notes:
- `HH:mm`: zero-padded hour (`01:05`)
- `H:mm`: non-padded hour (`1:05`)
- `H.DD`: decimal hours with 2 decimals (`1.08`)

Decimal summation behavior (`H.DD`):
- Totals are summed in decimal units (rounded per row first) to stay consistent with displayed row values.
- Example: `0:01` shown as decimal is `0.02`; six rows become `0.12` (about `0:07`), not `0.10`.

---

## Table Section

### `columns[]` keys

- `key` (required): binds column to a row value key
- `width` (number, relative width)
- `header` (optional text, only used by fallback header mode)
- `align` or `alignment`: horizontal alignment
- `halign`: `left|center|right`
- `valign`: `top|middle|bottom`
- `fontSize` (number)
- `weight` (`bold` or `italic`)
- `bold` (bool)
- `italic` (bool)
- `color` (hex)
- Signature rendering options (for `anySignature` / `flightSignature` / `simSignature` columns):
  - `signatureWidth` (number, optional)
  - `signatureHeight` (number, optional)
  - `signatureShowBorder` (bool, default `false`)

### `header` and `footer` row formats

Each row can be either:

1. Array of cells, or
2. Object with:
   - `rowHeight`
   - `cells` (array of cells)

### Cell keys (for header/footer cells)

- `text` (literal text)
- `key` or `valueToken` (token lookup)
- `hspan` (column span)
- `vspan` (row span)
- `align` / `alignment`
- `halign`
- `valign`
- `fontSize`
- `weight`, `bold`, `italic`
- `color`

### `footerRows[]` (summary rows)

Each item:

- `source`: `pageTotals | totalsBefore | totalsAfter`
- `labelToken`: `pageTotal | amountForward | totalToDate` (optional)
- `literalLabel`: custom label text (optional)
- `showTopBorder`: bool (optional)
- `rowHeight`: number (optional)
- `values`: map of `<columnKey>: <totalKey>`
- `cells`: optional extra custom cells

---

## Cover Page

```json
"coverPage": {
  "enabled": true,
  "title": "Pilot Logbook",
  "blocks": [
    {
      "type": "kvGrid",
      "title": "Pilot details",
      "columns": 1,
      "items": [
        { "label": "Name", "valueKey": "pilot.name" }
      ]
    },
    {
      "type": "multiline",
      "title": "Notes",
      "valueKey": "pilot.address"
    },
    {
      "type": "signature",
      "title": "Signature",
      "valueKey": "pilot.signatureImage",
      "width": 220,
      "height": 90
    }
  ]
}
```

### Cover block types

- `kvGrid`
- `multiline`
- `signature`

### Cover item/block positioning keys

For `kvGrid.items[]`:
- `label`, `valueKey`
- optional absolute positioning: `x`, `y`, `width`, `height`

For `signature` / `multiline` blocks:
- `valueKey`
- optional `width`, `height`
- `showBorder` (bool, signature blocks only, default `true`)

---

## All Supported Data Keys

Use these in `columns[].key`, `footer[].cells[].key`, or `footerRows.values`.

### Common keys (available for flight and simulator rows)

- `anyDate`
- `anyDateEnd`
- `anyStartTime`
- `anyEndTime`
- `anyTypeCode`
- `anyTypeFamily`
- `anyTypeLongName`
- `anyTypeManufacturer`
- `anyTypeCategory`
- `anyTypeEngineType`
- `anyTypeMtow`
- `anyAircraftRegistration`
- `anyAircraftMtow`
- `anyPIC`
- `anySIC`
- `anySignature` (signature image token for cover/signature blocks)
- `anyRemarks`
- `anyNotes`

### Flight-only keys (blank for simulator rows)

- `flightDateChocksOff`
- `flightDateTakeOff`
- `flightDateLanding`
- `flightDateChocksOn`
- `flightTimeChocksOff` (`HH:mm`, fixed 24h clock)
- `flightTimeTakeOff` (`HH:mm`, fixed 24h clock)
- `flightTimeLanding` (`HH:mm`, fixed 24h clock)
- `flightTimeChocksOn` (`HH:mm`, fixed 24h clock)
- `flightTypeCode`
- `flightTypeFamily`
- `flightTypeLongName`
- `flightTypeManufacturer`
- `flightTypeCategory`
- `flightTypeEngineType`
- `flightTypeMtow`
- `flightAircraftRegistration`
- `flightAircraftMtow`
- `flightPIC`
- `flightSIC`
- `flightSignature` (signature image token for cover/signature blocks)
- `flightRemarks`
- `flightNotes`
- `fromIcao`
- `fromIata`
- `fromName`
- `fromCity`
- `fromCountry`
- `toIcao`
- `toIata`
- `toName`
- `toCity`
- `toCountry`
- `timePIC`
- `timePICUS`
- `timeSIC`
- `timeDual`
- `timeInstructor`
- `timeIFR`
- `timeInstrument`
- `timeSimulatedInstrument`
- `timeNight`
- `timeCrossCountry`
- `timeCustom1`
- `timeCustom2`
- `timeCustom3`
- `timeCustom4`
- `timeFlight`
- `timeBlock`
- `timeTotalBlock`
- `distanceNM`
- `ifrApproaches`
- `takeOffsDays`
- `takeOffsNight`
- `landingsDay`
- `landingsNight`
- `pilotFunction`
- `approachType`

### Simulator-only keys (blank for flight rows)

- `simDate`
- `simDateEnd`
- `simStartTime`
- `simEndTime`
- `simTypeCode`
- `simTypeFamily`
- `simTypeLongName`
- `simTypeManufacturer`
- `simTypeCategory`
- `simTypeEngineType`
- `simTypeMtow`
- `simAircraftRegistration`
- `simAircraftMtow`
- `simPIC`
- `simSIC`
- `simSignature` (signature image token for cover/signature blocks)
- `simRemarks`
- `simNotes`
- `simSessionTime`

Compatibility notes:
- Legacy keys remain supported (for example: `date`, `aircraftModel`, `entryDate`, `simSessionTotal`, `picCrewName`, `flight.timePICMinutes`).
- `SimEndTime` (capital `S`) is also accepted as an alias of `simEndTime`.

### Totals keys (for `footerRows.values`)

- `ifrApproaches`
- `landings`
- `takeoffs`
- `landingDay`
- `landingNight`
- `takeoffDay`
- `takeoffNight`
- `sel`
- `mel`
- `xc`
- `day`
- `night`
- `ifr`
- `simInst`
- `fstd`
- `simSessionTotal`
- `dual`
- `pic`
- `picus`
- `picPicus`
- `picPlusPicus`
- `sic`
- `instructor`
- `total`

### Footer token aliases (for free-form `footer` cells)

These are auto-generated at runtime:

- Label tokens:
  - `pageTotalLabel`
  - `amountForwardLabel`
  - `totalToDateLabel`
- Per-total tokens:
  - `<totalKey>PageTotal`
  - `<totalKey>PreviousTotal`
  - `<totalKey>NewTotal`
  - `<totalKey>TotalToDate`

Example:
- `selPageTotal`
- `totalPreviousTotal`
- `picNewTotal`

### Cover page value keys

- `pilot.name`
- `pilot.licenses`
- `pilot.licenceNumber` (alias of licenses)
- `pilot.address`
- `report.fromDate`
- `report.toDate`
- `pilot.signatureImage` (for signature block)

---

## Styling and Alignment Rules

- Horizontal alignment: `left`, `center`, `right`
- Vertical alignment: `top`, `middle`, `bottom`
- Combined `align` like `TopCenter` works (parser detects top/bottom + left/right).
- Text style:
  - `fontSize`
  - `weight: "bold"` or `"italic"`
  - `bold: true`, `italic: true`
  - `color: "#RRGGBB"`

---

## Troubleshooting

- If upload fails: verify JSON is a single object (`{...}`), not an array.
- If values are blank: confirm `columns[].key` exists in supported key lists.
- If simulator rows are blank: use simulator-specific keys (`simDate`, `simType`, `simSessionTotal`, etc.).
- If footer values are blank: check `footerRows.values` mapping uses valid totals keys.
- If layout looks broken: validate `hspan`/`vspan` against the table column count.

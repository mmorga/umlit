# Flowchart Design

## Intermediary format

swimlanes and sections

Sections (ordered list - vertical swimlane):

* id: string
* label: string (Human readable)
* computed size
* computed position

Swimlanes (ordered list - horizontal representation):

* id: string
* label: string (Human readable)
* computed size
* computed position

Node:

* id: string
* label: string (Human readable)
* type: start, end, arrow, processing (rectangle), subroutines (double lined * rectangles), i/o (parallelogram), prepare conditional (hexagram), junction (* black blob), conditional (diamond), labeled connectors (circle - used for * multipage), concurrency (double transverse line)
* swimlane  -- swimlane doesn't apply to arrow
* section   -- section doesn't apply to arrow
* computed size
* computed position
* inputs (list of ids) -- 0, 1, 1+ depending on type
* outputs (list of ids) -- 0, 1, 1+ depending on type


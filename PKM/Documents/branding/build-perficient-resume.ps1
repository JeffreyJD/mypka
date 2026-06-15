
# ── Setup ───────────────────────────────────────────────────────────────────
$templatePath = "C:\Users\jeff\My Drive\PKA-Jeffrey\branding\team-inbox\2026_Perficient_Resume_Template.docx"
$outputPath   = "C:\Users\jeff\My Drive\PKA-Jeffrey\branding\leader-inbox\Jeffrey-Davis-Perficient-Resume-2026.docx"

Copy-Item $templatePath $outputPath -Force

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc  = $word.Documents.Open($outputPath)

# Color constants
$PrftRed = 192          # #C00000
$Black   = 0
$Auto    = -587137025   # wdColorAutomatic (template body color)
$FGDemi  = "Franklin Gothic Demi Cond"
$Aptos   = "Aptos"

# ── Helper: set cell text with style ────────────────────────────────────────
function SetCell {
    param($tbl, [int]$row, [int]$col, [string]$text,
          [string]$font="Aptos", [int]$size=10, [bool]$bold=$false, [int]$color=-587137025)
    $cell = $tbl.Cell($row, $col)
    $cell.Range.Text = $text
    $cell.Range.Font.Name  = $font
    $cell.Range.Font.Size  = $size
    $cell.Range.Font.Bold  = $bold
    $cell.Range.Font.Color = $color
}

# ── Helper: Find & Replace in document (all stories) ────────────────────────
function FnR {
    param([string]$find, [string]$replace)
    $word.Selection.Find.ClearFormatting()
    $word.Selection.Find.Replacement.ClearFormatting()
    $word.Selection.Find.Text = $find
    $word.Selection.Find.Replacement.Text = $replace
    $word.Selection.Find.Forward = $true
    $word.Selection.Find.Wrap = 1     # wdFindContinue
    $word.Selection.Find.MatchCase = $false
    $word.Selection.Find.Execute(
        [ref]$find,[ref]$false,[ref]$false,[ref]$false,[ref]$false,
        [ref]$false,[ref]$true,[ref]1,[ref]$true,[ref]$replace,[ref]2
    ) | Out-Null
}

# ── 1. Update Header Shapes (name, title, contact) ──────────────────────────
foreach ($sh in $doc.Shapes) {
    try {
        if ($sh.HasTextFrame) {
            $txt = $sh.TextFrame.TextRange.Text.Trim()
            if ($txt -match "Sr\." -or $txt -match "Project Manager" -or $txt -match "Consultant" -or $txt -match "Title") {
                $sh.TextFrame.TextRange.Text = "Delivery Unit Leader, Oracle Practice"
                $sh.TextFrame.TextRange.Font.Name  = $Aptos
                $sh.TextFrame.TextRange.Font.Size  = 12
                $sh.TextFrame.TextRange.Font.Color = $PrftRed
            }
            if ($txt -match "Name" -or $txt -match "First" -or $txt -match "Last") {
                $sh.TextFrame.TextRange.Text = "Jeffrey J. Davis"
                $sh.TextFrame.TextRange.Font.Name  = $FGDemi
                $sh.TextFrame.TextRange.Font.Size  = 20
                $sh.TextFrame.TextRange.Font.Color = $PrftRed
            }
            if ($txt -match "Houston" -or $txt -match "locale" -or $txt -match "Texas") {
                $sh.TextFrame.TextRange.Text = "Erie, Pennsylvania, USA"
            }
            if ($txt -match "Travel") {
                $sh.TextFrame.TextRange.Text = "100% Travel Available"
            }
        }
    } catch {}
}

# ── 2. Table 1: Skills (4 rows x 2 cols) ────────────────────────────────────
$t1 = $doc.Tables(1)

# Row 1: Roles
$t1.Cell(1,1).Range.Text = "Roles"
$t1.Cell(1,2).Range.Text = ""
$r1rng = $t1.Cell(1,2).Range
$r1rng.Text = ""
# Add each role as a paragraph
$rolesArr = @("Delivery Unit Leader","Engagement Director","PMO Director","Program Manager","Project Manager","P&L Owner","Change Management","Offshore Management","Executive Engagement")
$t1.Cell(1,2).Range.Text = $rolesArr -join [char]13

# Row 2: Solutions
$solArr = @("Oracle Cloud ERP","Oracle Cloud SCM","Oracle Cloud HCM","Oracle Cloud EPM","AI-First ERP Delivery","PMO Governance","Business Process Optimization","Oracle EBS Upgrades","Value Chain Planning","ERP Cloud Migration")
$t1.Cell(2,1).Range.Text = "Solutions"
$t1.Cell(2,2).Range.Text = $solArr -join [char]13

# Row 3: Industries
$indArr = @("Manufacturing","Chemical Distribution","Apparel & Retail","Food & Beverage","Oil & Gas","Non-Profit / Professional Org","Professional Services","Transportation","Healthcare","Global Multi-Country")
$t1.Cell(3,1).Range.Text = "Industries"
$t1.Cell(3,2).Range.Text = $indArr -join [char]13

# Row 4: Technologies
$techArr = @("Oracle EBS R11i, R12","Oracle Cloud ERP/SCM/HCM/EPM","Celonis Process Intelligence","Rapid4Cloud","Claude (Anthropic API)","Meridian (LLM Forecasting App)","Oracle AIM / OUM Methodology","Agile, Waterfall, Hybrid","Six Sigma / DMAIC","MS Project, SmartSheet")
$t1.Cell(4,1).Range.Text = "Technologies"
$t1.Cell(4,2).Range.Text = $techArr -join [char]13

# Apply consistent font to all table 1 cells
for ($r=1; $r -le 4; $r++) {
    $t1.Cell($r,1).Range.Font.Name = $Aptos; $t1.Cell($r,1).Range.Font.Size = 10; $t1.Cell($r,1).Range.Font.Bold = $true
    $t1.Cell($r,2).Range.Font.Name = $Aptos; $t1.Cell($r,2).Range.Font.Size = 10; $t1.Cell($r,2).Range.Font.Bold = $false
}

# ── 3. Table 2: Key Engagements Summary (3 rows x 3 cols) ───────────────────
$t2 = $doc.Tables(2)
# Row 1
$t2.Cell(1,1).Range.Text = "Large Chemical Distributor, Latin America"
$t2.Cell(1,2).Range.Text = "Program Manager"
$t2.Cell(1,3).Range.Text = "17-country Oracle EBS program (Financials, SCM, Engineering, Value Chain Planning). Go-Live March 2018. Budget `$8M+."
# Row 2
$t2.Cell(2,1).Range.Text = "Large High-Volume Apparel Company"
$t2.Cell(2,2).Range.Text = "Program Manager"
$t2.Cell(2,3).Range.Text = "Five-project acquisition integration program. Oracle Supply Chain. Go-Live November 2015. Budget `$4M."
# Row 3
$t2.Cell(3,1).Range.Text = "Major Oil & Gas Distributor"
$t2.Cell(3,2).Range.Text = "Program Manager"
$t2.Cell(3,3).Range.Text = "Oracle R12 Upgrade - Financials, Supply Chain, Service modules plus integration portfolio. Go-Live May 2016. Budget `$2.5M."

for ($r=1; $r -le 3; $r++) {
    for ($c=1; $c -le 3; $c++) {
        $t2.Cell($r,$c).Range.Font.Name = $Aptos
        $t2.Cell($r,$c).Range.Font.Size = 10
    }
}

# ── 4. Table 3: Education / Certs / Location ────────────────────────────────
$t3 = $doc.Tables(3)
# Row 1, Col 1: Education
$t3.Cell(1,1).Range.Text = "Education" + [char]13 + "Bachelor of Science, Computer Science" + [char]13 + "University of Pittsburgh, 1990"
# Row 1, Col 2: Certifications
$certsText = "Professional Training/Certifications" + [char]13 + "Six Sigma Green Belt Certified" + [char]13 + "BB / Lean Six Sigma" + [char]13 + "GE Crotonville - Leadership In Growth (LIG)" + [char]13 + "GE Crotonville - Advanced Manager Course (AMC)" + [char]13 + "Celonis Analyst Certification (in progress)"
$t3.Cell(1,2).Range.Text = $certsText
# Row 3: Publications / Geographic locale headers (keep structure)
try { $t3.Cell(3,1).Range.Text = "Publications" } catch {}
try { $t3.Cell(3,2).Range.Text = "Geographic Locale" } catch {}
# Row 4: location data
try {
    $t3.Cell(4,1).Range.Text = ""
    $t3.Cell(4,2).Range.Text = "Erie, Pennsylvania, USA" + [char]13 + "100% Travel Available" + [char]13 + "Client Proximity: East Coast / New Jersey - Everfox, TRAC" + [char]13 + "Office Proximity: Detroit, MI | Chicago, IL"
} catch {}

for ($r=1; $r -le $t3.Rows.Count; $r++) {
    for ($c=1; $c -le 2; $c++) {
        try {
            $t3.Cell($r,$c).Range.Font.Name = $Aptos
            $t3.Cell($r,$c).Range.Font.Size = 10
        } catch {}
    }
}

# ── 5. Replace Professional Overview body text ───────────────────────────────
$ovText = "Jeffrey Davis brings more than 28 years of Oracle ERP implementation experience, spanning the full lifecycle from Oracle 10.7 through Oracle Cloud. As Delivery Unit Leader for Perficient's Oracle Practice, Jeffrey holds P&L ownership across ERP, SCM, HCM, EPM, and Managed Services engagements spanning six countries - overseeing `$25-`$30M in annual practice revenue. He has led programs ranging from single-module upgrades to multi-country, multi-year business transformation initiatives." + [char]13 + [char]13 + "Jeffrey is currently leading Perficient's transition to an AI-First Oracle delivery model - a structured methodology built on three integrated platforms: Celonis for process intelligence, Rapid4Cloud for configuration automation and testing, and Claude as the AI layer across projects, cowork, and delivery quality. He also built Meridian, a custom LLM-powered project forecasting application on the Anthropic API, used internally to improve program delivery predictability. Results: 25-40% reduction in implementation timeline; 60% reduction in Level 1 support tickets post go-live." + [char]13 + [char]13 + "His technical foundation - a BS in Computer Science from the University of Pittsburgh - is matched by 14 years leading Oracle transformation at General Electric before joining Perficient."

# Find the overview placeholder and replace
$rng = $doc.Content
$rng.Find.ClearFormatting()
$rng.Find.Text = "I am putting more sentences here*"
$rng.Find.MatchWildcards = $true
if ($rng.Find.Execute()) {
    $rng.Text = $ovText
    $rng.Font.Name = $Aptos
    $rng.Font.Size = 10
    $rng.Font.Color = $Auto
}

# ── 6. Replace <total years> / <Ms./Mr.> overview line ──────────────────────
$rng2 = $doc.Content
$rng2.Find.ClearFormatting()
$rng2.Find.Text = "For <total years*"
$rng2.Find.MatchWildcards = $true
if ($rng2.Find.Execute()) { $rng2.Text = "" }

# ── 7. Build Detailed Engagement Section ─────────────────────────────────────
# Find the PERFICIENT, INC. header paragraph and replace all content from there
# to end of employer section
$rng3 = $doc.Content
$rng3.Find.ClearFormatting()
$rng3.Find.Text = "PERFICIENT, INC."
$rng3.Find.MatchWildcards = $false
$rng3.Find.MatchCase = $true

if ($rng3.Find.Execute()) {
    # Expand to end of document
    $startPos = $rng3.Start
    $endPos   = $doc.Content.End
    $bodyRng  = $doc.Range($startPos, $endPos - 1)

    # Build replacement text
    $nl  = [char]13   # paragraph mark in Word
    $tab = [char]9

    $body = ""

    # -- PERFICIENT header --
    $body += "PERFICIENT, INC." + $tab + $tab + $tab + "Delivery Unit Leader, Oracle Practice" + $nl

    # -- AI-First Engagement --
    $body += $nl + "CLIENT: AI-First Oracle Delivery Transformation - Perficient Internal Initiative" + $nl
    $body += "Led architecture and adoption of Perficient's AI-First Oracle delivery model integrating Celonis (process mining), Rapid4Cloud (configuration automation and test generation), and Claude (AI layer for documentation, cowork, and delivery QA). Built Meridian, a custom LLM application on the Anthropic API for program forecasting and delivery risk prediction." + $nl
    $body += "Responsibilities:" + $nl
    $body += [char]0x2022 + "  Designed three-platform AI-First delivery architecture adopted across the Oracle Practice" + $nl
    $body += [char]0x2022 + "  Built Meridian (Anthropic API) for project forecasting and early-warning risk identification" + $nl
    $body += [char]0x2022 + "  Leading enablement of delivery teams across six countries on AI-First methodology" + $nl
    $body += [char]0x2022 + "  Driving P&L impact through improved resource utilization and reduced go-live risk" + $nl
    $body += "Business/Technology Value" + $nl
    $body += [char]0x2022 + "  25-40% reduction in implementation timeline through AI-assisted configuration and testing" + $nl
    $body += [char]0x2022 + "  60% reduction in Level 1 support tickets post go-live through improved deployment quality" + $nl

    # -- Latin America --
    $body += $nl + "CLIENT: Large Chemical Distributor - Latin America   |   Program Manager/PMO Leader   |   May 2016 - May 2018   |   Budget: `$8M+" + $nl
    $body += "Served as Program Manager and PMO Leader for a three-year, seventeen-country business improvement program across Latin America. Full suite of Oracle EBS Financials, Supply Chain, Engineering, and Value Chain Planning modules. Go-Live March 2018." + $nl
    $body += "Responsibilities:" + $nl
    $body += [char]0x2022 + "  Led program governance and delivery oversight for 17-country scope" + $nl
    $body += [char]0x2022 + "  Managed multi-integrator project teams across phased delivery" + $nl
    $body += [char]0x2022 + "  Drove business process standardization across Finance, Supply Chain, and Engineering" + $nl
    $body += [char]0x2022 + "  Maintained program schedule, budget, and executive stakeholder alignment" + $nl
    $body += "Business/Technology Value" + $nl
    $body += [char]0x2022 + "  Delivered on-time `$8M+ program spanning 17 countries" + $nl
    $body += [char]0x2022 + "  Standardized Oracle EBS Financials and Supply Chain processes across Latin American operations" + $nl

    # -- Apparel Acquisition --
    $body += $nl + "CLIENT: Large High-Volume Apparel Company - Acquisition Integration   |   Program Manager   |   Nov 2014 - Nov 2015   |   Budget: `$4M" + $nl
    $body += "Served as Program Manager for a five-project acquisition integration program integrating a newly acquired company into the parent company's Oracle Supply Chain applications. Go-Live November 2015." + $nl
    $body += "Responsibilities:" + $nl
    $body += [char]0x2022 + "  Managed five concurrent workstreams across Finance, Supply Chain, and systems integration" + $nl
    $body += [char]0x2022 + "  Coordinated integration of acquired company's operations into parent ERP environment" + $nl
    $body += "Business/Technology Value" + $nl
    $body += [char]0x2022 + "  On-time delivery of five-project acquisition integration at `$4M budget" + $nl

    # -- Oil & Gas --
    $body += $nl + "CLIENT: Major Distributor - Oil & Gas Industry   |   Program Manager   |   Jul 2015 - May 2016   |   Budget: `$2.5M" + $nl
    $body += "Oversaw full Oracle R12 Upgrade - Financials, Supply Chain, and Service modules plus large integration portfolio to external applications. Go-Live May 2016." + $nl
    $body += "Business/Technology Value" + $nl
    $body += [char]0x2022 + "  Delivered full R12 upgrade and integration portfolio on schedule at `$2.5M" + $nl

    # -- Perficient Internal --
    $body += $nl + "CLIENT: Perficient, Inc. - Global Oracle R12 Implementation   |   Senior Project Manager   |   May 2014 - Mar 2015   |   Budget: `$2M" + $nl
    $body += "Led 20-person team delivering Perficient's global Oracle R12 implementation across US, Canada, China, and India. Interfaces with third-party service providers and internal applications. Go-Live July 2014." + $nl
    $body += "Business/Technology Value" + $nl
    $body += [char]0x2022 + "  Delivered Perficient's global ERP platform on time and budget" + $nl
    $body += [char]0x2022 + "  Established single Oracle instance supporting US, Canada, China, and India" + $nl

    # -- Apparel Supply Chain --
    $body += $nl + "CLIENT: Large High-Volume Apparel Company - Oracle R12 Supply Chain   |   Project Manager   |   Jun 2013 - Apr 2014   |   Budget: `$2M" + $nl
    $body += "Led 20+ person multi-integrator team implementing Oracle R12 Supply Chain modules and legacy Order Management integration. Go-Live April 2014." + $nl

    # -- NFP --
    $body += $nl + "CLIENT: Not-For-Profit Organization - Oracle R12 Financial Upgrade   |   Project Manager   |   Jul 2013 - Dec 2013   |   Budget: `$500K" + $nl
    $body += "Led 12-person global team delivering Oracle R12 Financial upgrade across US, Canada, England, UAE, and Malaysia. Interfaces with external applications and financial institutions. Go-Live December 2013." + $nl

    # -- Apparel OTC --
    $body += $nl + "CLIENT: Large High-Volume Apparel Company - Oracle R12 Financials/OTC   |   Project Manager   |   Dec 2012 - May 2013   |   Budget: `$1M" + $nl
    $body += "Led eight-person team delivering full lifecycle Oracle R12 Financials and Order-To-Cash implementation. Go-Live May 2013." + $nl

    # -- Previous Employer: GE --
    $body += $nl + "GENERAL ELECTRIC - GE Transportation Systems, Erie, PA" + $tab + $tab + "Senior IM Program Manager" + $nl
    $body += "Developed and led GE Transportation's strategy to extend its Oracle ERP instance globally - Brazil, China, Europe, Kazakhstan, and the US. Reduced total cost of ownership by 50%." + $nl
    $body += [char]0x2022 + "  Brazil Legacy Conversion (2008-2009): `$3M - Oracle Financials/SCM/Manufacturing + Brazil localizations. Go-Live Nov 2009" + $nl
    $body += [char]0x2022 + "  China Oracle Implementation (2009): `$2M - Oracle Financials/SCM/Manufacturing/ASCP + UTF-8 upgrade. Go-Live Jan 2010" + $nl
    $body += [char]0x2022 + "  Kazakhstan Oracle Implementation (2009-2010): `$3M - full Oracle stack + IT infrastructure. Go-Live Oct 2010" + $nl
    $body += [char]0x2022 + "  ICS EMEA Conversion (Italy/UK/Netherlands, 2009-2010): `$2M. Go-Live Jan 2011" + $nl
    $body += [char]0x2022 + "  Battery Business Startup (US Manufacturing, 2010-2011): `$3.4M - Oracle + Teamcenter PLM + Proficy MES. Go-Live Aug 2011" + $nl
    $body += $nl + "Customer Support IM Leader (Jan 2007 - Jul 2008) - Led 30-project portfolio, `$3.2M budget. First global shipment tracking app - 25% delivery time reduction." + $nl
    $body += "Commercial IM Leader (Feb 2006 - Jan 2007) - CustomerCentral CRM, `$1M budget generating `$70M OM benefits. China Ministry of Rail Technology Summit." + $nl
    $body += "IM Program Manager, Quality Systems (Jun 2004 - Feb 2006) - Evolution Series Locomotive launch. Failure rate: 2.08/year." + $nl
    $body += "Senior Project Leader (Sep 2000 - Jun 2004) - eServices platform: 9,000+ locomotives, `$50M+ OM benefits. First B2B platform." + $nl
    $body += "IM Systems Analyst (Jan 1998 - Sep 2000) - Oracle ERP 10.7. Y2K Readiness Team." + $nl

    # -- Independent --
    $body += $nl + "INDEPENDENT ORACLE CONSULTANT, Erie, PA" + $tab + $tab + "Project Manager (May 2012 - Dec 2012)" + $nl
    $body += "IT project planning and resource selection for local businesses and educational institutions." + $nl

    # -- Elias --
    $body += $nl + "ELIAS COMMUNICATIONS, Pittsburgh, PA" + $tab + $tab + "Director of Technical Services (May 1994 - Dec 1997)" + $nl
    $body += "Led consulting practice delivering enterprise internet presence solutions. Full lifecycle: planning, implementation, and support." + $nl

    # -- Algor --
    $body += $nl + "ALGOR, INC., Pittsburgh, PA" + $tab + $tab + "Technical Operations Manager (Mar 1992 - May 1994)" + $nl
    $body += "Managed six-person IT department - application development, data center, infrastructure, budgeting." + $nl
    $body += "Programmer / Analyst (Jul 1990 - Mar 1992) - Software testing, code inspection, automated sales and delivery system development." + $nl

    # Replace the body range
    $bodyRng.Text = $body
    $bodyRng.Font.Name  = $Aptos
    $bodyRng.Font.Size  = 10
    $bodyRng.Font.Color = $Auto
    $bodyRng.Font.Bold  = $false
}

# ── 8. Global cleanup: remove stray placeholders ────────────────────────────
$cleanups = @(
    @("Houston, Texas", "Erie, Pennsylvania, USA"),
    @("100% Travel Available`t", "100% Travel Available"),
    @("Sr. Project Manager", "Delivery Unit Leader, Oracle Practice"),
    @("Geographic locale", "Geographic Locale"),
    @("MBA, Texas Christian University 1994", "BS Computer Science, University of Pittsburgh, 1990"),
    @("Bachelor of Science, University of Alabama 1987", ""),
    @("Project Management Professional (PMP) certified", "Six Sigma Green Belt Certified"),
    @("OCUP Certification (UML Certified)", "BB / Lean Six Sigma | GE Crotonville LIG | AMC | Celonis (in progress)")
)
foreach ($pair in $cleanups) {
    FnR $pair[0] $pair[1]
}

# ── 9. Save ──────────────────────────────────────────────────────────────────
$doc.Save()
$doc.Close()
$word.Quit()
Write-Output "Saved: $outputPath"
